if exists("g:netlib_file_handler_loaded")
  finish
endif

let g:netlib_file_handler_loaded = 1

let s:savecpo = &cpo
set cpo&vim

let s:priority = 50

let s:handler = {}

" If there is a error with this handler, but another handler might succeed,
"   return 0.  Another handler will be tried, instead.
" If 'path' is a file, copy its data into 'file', and return 1
" If 'path' is a directory, put a directory listing in 'file', and return 2
" If an unrecoverable error occurs that no other handler could handle better
"   (file doesn't exist, isn't readable, etc) return -1
function! s:handler.read(path, file) dict
  let path = a:path

  let type = getftype(path)

  if type == 'dir'
    if path[-1] != '/'
      let path .= '/'
    endif

    let files  = split(glob(path . '.*'), '\n')
    let files += split(glob(path . '*'), '\n')
    call writefile(files, a:file)
    return 2
  else
    call writefile(readfile(path, 'b'), a:file, 'b')
    return 1
  endif

  return 0
endfunction

function! s:handler.write(path, file) dict
  let type = getftype(a:path)

  if type ==# 'dir'
    return -1
  endif

  call writefile(readfile(a:file, 'b'), a:path, 'b')
endfunction

call netlib#RegisterHandler('file', 'default', s:handler, s:priority)

let &cpo = s:savecpo
unlet s:savecpo
