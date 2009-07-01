" Insecure on Windows
" Secure on Unix
function! netlib#utility#tempdir()
  let name = tempname()
  call mkdir(name, 0700)
  return name . '/'
endfunction

" Recursively remove a directory tree.
function! netlib#utility#deltree(dir)
  if has('unix')
    call system('rm -rf ' . shellescape(a:dir))
  elseif has('win32') || has('win64')
    if executable('deltree')
      call system('deltree ' . shellescape(a:dir))
    else
      call system('rmdir /S ' . shellescape(a:dir))
    endif
  endif
endfunction

" Interpolate a file name into 'shellredir'
function! netlib#utility#redir_to(name)
  if &shellredir =~ '%s'
    return substitute(&shellredir, '%s', a:name, 'g')
  endif
  return &shellredir . a:name
endfunction

" Provided for symmetry with redir_to, but for input redirection
function! netlib#utility#redir_from(name)
  return '<' . a:name
endfunction

" Many protocols (ftp, scp, sftp) interpret "put foo bar" differently
" depending on whether or not "bar" is a directory.  If so, they create the
" remote file "bar/foo" whose contents match the local file "foo", and if not
" they create or replace the remote file "bar".  This means that we can't use
" any arbitrary temp file name since, eg, "scp /tmp/v12345/0 host:bar" could
" clobber the file "bar/0" on the remote instead of nicely failing.
"
" Remedy this by calculating appropriate strings to use as both the source and
" destination.
"
" If the file already has a name,
"   use that name as the source name, and don't change the URI.
"   ( for instance, ":w scp:///tmp" in buffer "foo" becomes "scp foo /tmp" )
"
" If the URI ends with a directory separator,
"   abort; the user explicitly tried to write an unnamed buffer as a folder.
"   ( ":w scp:///tmp/" in an unnamed buffer; no filename provided )
"
" Otherwise,
"   use the last non-directory-separator part of the URI as the source name,
"   and remove that name from the end of the URI
"   ( ":w scp://host:test" becomes "scp test host:" )
"   ( ":w scp:///tmp/test/foo" becomes "scp foo /tmp/test/")
function! netlib#utility#calculate_src_dest(uri)
  let uri = a:uri

  if expand('%') !=# uri && strlen(expand('%'))
    " File has an actual name; use it.
    return [ expand('%:t'), a:uri ]
  endif

  if uri[-1] =~ '[/\\]'
    " URI ends with directory separator
    throw "netlib.exception: No filename given"
  endif

  " Unnamed buffer (% == ''), or first time saving (% == uri)
  try
    let [ prot, path ] = split(uri, '://', 1)
  catch
    throw "netlib.exception: invalid URI"
  endtry

  " Last contiguous chunk of non-directory separators
  let filename = matchstr(path, '[^/\\]*$')

  " Everything but the filename
  let path = substitute(path, '[^/\\]*$', '', '')

  return [ filename, prot . '://' . path ]
endfunction

function! netlib#utility#uri_escape(uri)
  return substitute(a:uri, '[^A-Za-z0-9.~_-]',
                  \ '\="%" . printf("%02x", char2nr(submatch(0)))', 'g')
endfunction

" Parse some URI like "[[userX]host[Yport]Z]path" into separate user, host,
" port, and path components.  X Y and Z are separators; they must be valid
" regexes that match exactly the separator.  Each will be evaluated with the
" default magic-ness (that is, \m).
function! netlib#utility#uri_split(uri, x, y, z)
  let rv = {}

  let x = '%(\m' . a:x . '\v)'
  let y = '%(\m' . a:y . '\v)'
  let z = '%(\m' . a:z . '\v)'

  let not_xyz = printf('%%(.%%(%s|%s|%s)@<!)', x, y, z)

  let userre = '(' . not_xyz . '+)%(' . x . ')'
  let hostre = '(' . not_xyz . '+)'
  let portre = '%(' . y . ')(\d+)'

  let re = printf('\v%%(%%(%s)=%%(%s)%%(%s)=%%(%s))=(.*)', userre, hostre, portre, z)

  let list = matchlist(a:uri, re)

  if empty(list)
    throw "netlib.exception: Cannot split URI"
  endif

  if len(list[1])
    let rv['user'] = list[1]
  endif
  if len(list[2])
    let rv['host'] = list[2]
  endif
  if len(list[3])
    let rv['port'] = list[3]
  endif
  let rv['path'] = list[4]

  return rv
endfunction
