if exists("g:netlib_sudo_handler_loaded")
  finish
endif

let g:netlib_sudo_handler_loaded = 1

let s:savecpo = &cpo
set cpo&vim

let s:priority = 50

let s:handler = {}

function! s:handler.read(path, file) dict
  " path with a trailing /
  let dirpath = substitute(a:path, '/\=$', '/', '')

  if getftype(dirpath) ==# 'dir'
    let cmdline = 'sudo ls ' . shellescape(dirpath)

    echo cmdline
    echo ""

    let files = system(cmdline)

    if v:shell_error
      return netlib#handler_error()
    endif

    let file_list = split(files, '\n')

    call map(file_list, '"sudo://" . dirpath . v:val')
    call writefile(file_list, a:file)

    return netlib#directory_read()
  endif

  let cmdline  = 'sudo dd if=' . shellescape(a:path)
  let cmdline .= ' of=' . shellescape(a:file)

  echo cmdline
  echo ""

  call system(cmdline)

  if v:shell_error
    return netlib#handler_error()
  endif

  return netlib#file_read()
endfunction

function! s:handler.write(path, file) dict
  " Handle both dirs and links to dirs
  if getftype(a:path) ==# 'dir' || getftype(a:path . '/') ==# 'dir'
    return netlib#uri_error()
  endif

  let cmdline  = 'sudo dd if=' . shellescape(a:file)
  let cmdline .= ' of=' . shellescape(a:path)

  echo cmdline
  echo ""

  call system(cmdline)

  if v:shell_error
    return netlib#handler_error()
  endif

  return netlib#file_written()
endfunction

call netlib#RegisterHandler('sudo', 'default', s:handler, s:priority)

let &cpo = s:savecpo
unlet s:savecpo
