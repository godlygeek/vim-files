" { 'protocolname' => { 'handlername' => handlerobject }}
let s:handlers = {}

" Register a handler for a given protocol by name.  Associate it with
" a handler object, and a priority (the optional argument, defaulting to 50)
function! netlib#RegisterHandler(protocol, name, handler, ...)
  let prio = (a:0 ? a:1 : 50)

  if !has_key(s:handlers, a:protocol)
    let s:handlers[a:protocol] = {}
  endif

  let s:handlers[a:protocol][a:name] = a:handler

  try
    call netsettings#GetHandlerPriority(a:protocol, a:name)
  catch /^\S\+\.exception:/
    call netsettings#SetHandlerPriority(a:protocol, a:name, prio)
  endtry
endfunction

" Needs work...
let s:tempdir = netlib#utility#tempdir()

augroup NetlibTempfileCleanup
  au!
  autocmd VimLeave * call netlib#utility#deltree(s:tempdir)
augroup END

" Temp file used for all handler operations.
" Rather than returning strings to the core or taking strings as arguments
" from the core, the handlers will read from or write to this temp file.
" Default to unset. Once set, it should always be a subdirectory of s:tempdir
let s:tempfile = ''

" Split the URI 'prot://path' and return [ 'prot', 'path' ]
" If the URI doesn't contain a :// it is invalid; throw.
function! s:ValidateUri(uri)
  let parts = split(a:uri, '://', 1)
  if len(parts) < 2
    throw "netlib.exception: invalid URI"
  endif
  return [ parts[0], join(parts[1:], '://') ]
endfunction

" Given a URI and a handler function name, try to find a handler for the
" protocol associated with that URI and call the handler function on the path.
"
" If the handler returns 0, that handler is not equipped to handle the URI.
"   Another will be tried.
" If the handler returns -1, that URI is not able to have the given function
"   performed upon it.  Consider this a fatal error for this request.
" If the handler returns 1, the path corresponded to a file which was read or
"   written successfully.
" If the handler returns 2, the path corresponded to a directory whose
"   contents were listed successfully.
function! s:Handle(uri, funcname)
  let [ prot, path ] = s:ValidateUri(a:uri)
  let handlers = netsettings#HandlerList(prot)
  for name in handlers
    let rv = call(s:handlers[prot][name][a:funcname], [ path, s:tempfile ], s:handlers[prot][name])
    if rv == 1 || rv == 2
      return
    elseif rv == -1
      throw "netlib.exception: FIXME something went wrong"
    elseif rv == 0
      continue " Handler error, try another one
    endif
  endfor
  throw "netlib.exception: no suitable handler exists"
endfunction

function! s:CallReadHandler(uri)
  call s:Handle(a:uri, 'read')
endfunction

function! s:CallWriteHandler(uri)
  call s:Handle(a:uri, 'write')
endfunction

function! s:ReadFileIntoBuffer(file)
  let savecpo = &cpo
  try
    " Make sure we don't change the file or altfile name...
    set cpo-=a cpo-=A cpo-=f cpo-=F
    try
      exe 'r' v:cmdarg a:file
    catch /^Vim\%((\a\+)\)\=:E325/
      " The user will have already responded to this...
      " There's no reason for us to print (another) message about it.
    endtry
  finally
    let &cpo = savecpo
  endtry
endfunction

function! s:WriteFileFromBuffer(file)
  let savecpo = &cpo
  try
    " Make sure we don't change the file or altfile name...
    set cpo-=a cpo-=A cpo-=f cpo-=F
    exe line("'[") . ',' . line("']") . 'w!' v:cmdarg a:file
  finally
    let &cpo = savecpo
  endtry
endfunction

function! s:AppendFileFromBuffer(file)
  let savecpo = &cpo
  try
    set cpo-=a cpo-=A cpo-=f cpo-=F
    exe line("'[") . ',' . line("']") . 'w!' v:cmdarg '>>' a:file
  finally
    let &cpo = savecpo
  endtry
endfunction

" FIXME: Handle v:cmdbang

" Handle ":e file" as a copy-to-local + read
function! netlib#HandleBufRead(uri)
  let s:tempfile = s:tempdir . 'vim_netlib_read_temp'

  call s:CallReadHandler(a:uri)
  call s:ReadFileIntoBuffer(s:tempfile)
  sil 1d_
  call setpos("']", [ 0, line('$'), 1, 0 ])
  doautocmd BufReadPost
endfunction

" Handle ":r file" as a copy-to-local + read
function! netlib#HandleFileRead(uri)
  let s:tempfile = s:tempdir . 'vim_netlib_read_temp'

  call setpos('.', getpos("'["))
  call s:CallReadHandler(a:uri)
  call s:ReadFileIntoBuffer(s:tempfile)
endfunction

" Handle ":w file" as a write + copy-to-remote
function! netlib#HandleBufWrite(uri)
  let [ tempfile, uri ] = netlib#utility#calculate_src_dest(a:uri)
  let s:tempfile = s:tempdir . tempfile

  call s:WriteFileFromBuffer(s:tempfile)
  call s:CallWriteHandler(uri)
  set nomodified
endfunction

" Handle ":2,$w file" as a write + copy-to-remote
function! netlib#HandleFileWrite(uri)
  let [ tempfile, uri ] = netlib#utility#calculate_src_dest(a:uri)
  let s:tempfile = s:tempdir . tempfile

  call s:WriteFileFromBuffer(s:tempfile)
  call s:CallWriteHandler(uri)
  doautocmd BufWritePost
endfunction

" Handle ":w >>file" as a copy-to-local + append + copy-to-remote
function! netlib#HandleFileAppend(uri)
  let s:tempfile = s:tempdir . 'vim_netlib_read_temp'

  call s:CallReadHandler(a:uri)
  call s:AppendFileFromBuffer(s:tempfile)

  let [ tempfile, uri ] = netlib#utility#calculate_src_dest(a:uri)
  let s:tempfile = s:tempdir . tempfile

  call s:CallWriteHandler(uri)
endfunction

" Handle ":source file" as a copy-to-local + source
function! netlib#HandleSource(uri)
  let s:tempfile = s:tempdir . 'vim_netlib_read_temp'

  call s:CallReadHandler(a:uri)
  exe 'source ' . s:tempfile
endfunction


let s:Generic_Handler = {}

function! s:Generic_Handler.read(path, file) dict
  let path = self.prot . '://' . a:path

  call system(self.installed)

  if v:shell_error > 0 || !len(self.read_command)
    return 0
  endif

  let contents = system(self.read_command . ' >' . a:file . ' ' . shellescape(a:path))
  if v:shell_error > 0
    return -1
  endif

  return 1
endfunction

function! s:Generic_Handler.write(path, file) dict
  let path = self.prot . '://' . a:path

  call system(self.installed)

  if v:shell_error > 0 || !len(self.write_command)
    return -1
  endif

  let contents = system(self.write_command . ' >' . a:file . ' ' . shellescape(a:path))
  if v:shell_error > 0
    return -1
  endif
endfunction

function! netlib#GenericHandler(prot, installed, readcmd, writecmd)
  let rv = copy(s:Generic_Handler)

  let rv.prot          = a:prot
  let rv.installed     = a:installed
  let rv.read_command  = a:readcmd
  let rv.write_command = a:writecmd

  return rv
endfunction
