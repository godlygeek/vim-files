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
  " We don't want stderr included!
  return '>' . a:name
  "if &shellredir =~ '%s'
  "  return substitute(&shellredir, '%s', a:name, 'g')
  "endif
  "return &shellredir . a:name
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
" Remedy this by ensuring that the tempfile name used matches the filename
" component of the URI given, and then removing that portion from the URI so
" that the URI names a directory (complete with trailing directory separator).
"
" "w scp://foo/bar/baz" -> "scp baz foo:bar/"
"   If "bar" exists and is a directory, this creates "bar/baz", otherwise this
"   is an error.
"
" NOTE: This method assumes that "path" is the entire portion of a URI
"       following the "protocol://" prefix.  It must be of the form
"       [[user@]host[:port](:|/)]path
function! netlib#utility#get_directory_path(path, file)
  let parsed_path = netlib#utility#uri_split(a:path, '@', ':', '[:/]')

  if parsed_path.path =~ '/$'
    throw "netlib.exception: Cannot write to a directory!"
  endif

  if fnamemodify(parsed_path.path, ':t') !=# fnamemodify(a:file, ':t')
    throw "netlib.exception: Suffix doesn't match tempfile!"
  endif

  let parsed_path.path = substitute(parsed_path.path, '[^/]*$', '', '')

  let path = ''
  if has_key(parsed_path, 'user')
    let path .= parsed_path.user . '@'
  endif
  if has_key(parsed_path, 'host')
    let path .= parsed_path.host
  endif
  if has_key(parsed_path, 'port')
    let path .= ':' . parsed_path.port
  endif
  let path .= '/' . parsed_path.path

  return path
endfunction

" Escape a URI to a valid filename, with %-escaped characters.
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
