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

" Return value for a handler encountering an invalid URI; fatal error.
function! netlib#uri_error()
  return -1
endfunction

" Return value for a handler that is misconfigured or unable to function.
" Another handler will be tried when this value is returned.
function! netlib#handler_error()
  return 0
endfunction

" Return value for a handler that has successfully written a file.
function! netlib#file_written()
  return 1
endfunction

" Return value for a handler that has successfully read a file.
function! netlib#file_read()
  return 1
endfunction

" Return value for a handler that has successfully read a directory listing.
function! netlib#directory_read()
  return 2
endfunction

" Given a URI and a handler function name, try to find a handler for the
" protocol associated with that URI and call the handler function on the path.
" Multiple handlers may be tried if the highest priority handler returns
" netlib#handler_error().
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
      exe 'r' v:cmdarg fnameescape(a:file)
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
    exe line("'[") . ',' . line("']") . 'w!' v:cmdarg fnameescape(a:file)
  finally
    let &cpo = savecpo
  endtry
endfunction

function! s:AppendFileFromBuffer(file)
  let savecpo = &cpo
  try
    set cpo-=a cpo-=A cpo-=f cpo-=F
    exe line("'[") . ',' . line("']") . 'w!' v:cmdarg '>>' fnameescape(a:file)
  finally
    let &cpo = savecpo
  endtry
endfunction

function! s:SetTempfile(uri)
  if g:netlib_operation ==# 'source'
    " Need an identifiable name for display in :scriptnames
    let name = netlib#utility#uri_escape(a:uri)
    let name = substitute(name, '\c%2f', '/', 'g')
    let name = substitute(name, '\c%3a//', '//', '')
  elseif g:netlib_operation ==# 'read'
    " Any name should do just fine
    let name = 'read_temp'
  else
    " Want to use the last component of the path part of the URI so that
    " writing to "scp://user@host:bar" does "scp bar user@host:"
    let name = matchstr(a:uri,
                      \ '^.\{-}://[^:/]*\(:\d\+/\|[:/]\)\([^/]*/\)*\zs.*')
    if empty(name)
      let name = 'write_temp'
    endif
  endif

  let s:tempfile = s:tempdir . name

  sil! call mkdir(fnamemodify(s:tempfile, ":h"), "p")
  if !isdirectory(fnamemodify(s:tempfile, ":h"))
    throw "netlib.exception: cannot create temp directory!"
  endif
endfunction

" FIXME: Handle v:cmdbang

" Handle ":e file" as a copy-to-local + read
function! netlib#HandleBufRead(uri)
  let g:netlib_operation = 'read'
  try
    call s:SetTempfile(a:uri)
    call s:CallReadHandler(a:uri)
    call s:ReadFileIntoBuffer(s:tempfile)
    sil 1d_
    call setpos("']", [ 0, line('$'), 1, 0 ])
    doautocmd BufReadPost
  finally
    unlet g:netlib_operation
  endtry
endfunction

" Handle ":r file" as a copy-to-local + read
function! netlib#HandleFileRead(uri)
  let g:netlib_operation = 'read'
  try
    call setpos('.', getpos("'["))
    call s:SetTempfile(a:uri)
    call s:CallReadHandler(a:uri)
    call s:ReadFileIntoBuffer(s:tempfile)
  finally
    unlet g:netlib_operation
  endtry
endfunction

" Handle ":w file" as a write + copy-to-remote
function! netlib#HandleBufWrite(uri)
  let g:netlib_operation = 'write'
  try
    call s:SetTempfile(a:uri)
    call s:WriteFileFromBuffer(s:tempfile)
    call s:CallWriteHandler(a:uri)
    set nomodified
  finally
    unlet g:netlib_operation
  endtry
endfunction

" Handle ":2,$w file" as a write + copy-to-remote
function! netlib#HandleFileWrite(uri)
  let g:netlib_operation = 'write'
  try
    call s:SetTempfile(a:uri)
    call s:WriteFileFromBuffer(s:tempfile)
    call s:CallWriteHandler(a:uri)
    doautocmd BufWritePost
  finally
    unlet g:netlib_operation
  endtry
endfunction

" Handle ":w >>file" as a copy-to-local + append + copy-to-remote
function! netlib#HandleFileAppend(uri)
  let g:netlib_operation = 'append'
  try
    call s:SetTempfile(a:uri)
    call s:CallReadHandler(a:uri)
    call s:AppendFileFromBuffer(s:tempfile)
    call s:SetTempfile(a:uri)
    call s:CallWriteHandler(a:uri)
  finally
    unlet g:netlib_operation
  endtry
endfunction

" Handle ":source file" as a copy-to-local + source
function! netlib#HandleSource(uri)
  let g:netlib_operation = 'source'
  try
    call s:SetTempfile(a:uri)
    call s:CallReadHandler(a:uri)
    exe 'source ' . fnameescape(s:tempfile)
  finally
    unlet g:netlib_operation
  endtry
endfunction

" Provide a prototype for a generic handler that only wraps some shell
" commands.  It assumes that many protocols can be adequately handled by
" simple handlers with only 4 properties:
"
"   A protocol which it can speak
"
"   A vimscript expession that can determine if all of the tools it requires
"   to work are available
"
"   A shell command that accepts a URI on the command line and writes the
"   contents of the file at that URI to standard output
"
"   A shell command that accepts a URI on the command line and writes the
"   contents of standard input to the file at that URI
let s:Generic_Handler = {}

" If this handler's prerequisites are available, and this handler has
" a command associated with it for reading, call
"    read_command foo://bar/baz
" with stdout redirected to the temp file being read.
function! s:Generic_Handler.read(path, file) dict
  if empty(self.read_command)
    " This handler cannot handle this request
    return 0
  endif

  if !empty(self.installed) && !eval(self.installed)
    " This handler is missing some runtime dependency
    return 0
  endif

  let path = shellescape(self.prot . '://' . a:path)
  let redir = netlib#utility#redir_to(a:file)

  echo self.read_command . ' ' . path . redir
  call system(self.read_command . ' ' . path . redir)

  if v:shell_error > 0
    " Something went wrong; assume no handler can handle this URI
    return -1
  endif

  " Successfully operated on this URI
  return 1
endfunction

" If this handler's prerequisites are available, and this handler has
" a command associated with it for writing, call
"    write_command foo://bar/baz
" with stdin redirected from the temp file being written.
function! s:Generic_Handler.write(path, file) dict
  if empty(self.write_command)
    " This handler cannot handle this request
    return 0
  endif

  if !empty(self.installed) && !eval(self.installed)
    " This handler is missing some runtime dependency
    return 0
  endif

  let path = shellescape(self.prot . '://' . a:path)
  let redir = netlib#utility#redir_from(a:file)

  echo self.write_command . ' ' . path . redir
  call system(self.write_command . ' ' . path . redir)

  if v:shell_error > 0
    " Something went wrong; assume no handler can handle this URI
    return -1
  endif

  " Successfully operated on this URI
  return 1
endfunction

" Create an instance of GenericHandler that uses the given protocol, and the
" given commands for checking if the tools it needs are installed, for
" reading, and for writing.
"
" The "prot" parameter must not be an empty string.
" If "installed" is an empty string, no check for prerequisites is performed
" If "readcmd" is an empty string, this handler cannot read
" If "writecmd" is an empty string, this handler cannot write
function! netlib#GenericHandler(prot, installed, readcmd, writecmd)
  if empty(a:prot)
    throw "netlib.exception: No protocol provided for handler!"
  endif

  let rv = copy(s:Generic_Handler)

  let rv.prot = substitute(a:prot, '://$', '', '')

  let rv.installed     = a:installed
  let rv.read_command  = a:readcmd
  let rv.write_command = a:writecmd

  return rv
endfunction
