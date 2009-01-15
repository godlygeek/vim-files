if exists("g:netplugin_scp_loaded")
  finish
endif

let g:netplugin_scp_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let s:openssh_prio = 90

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

function! s:scp(src, dest)
  if !executable('scp')
    return -1
  endif

  let ver = system('ssh -V')

  if v:shell_error || ver !~# 'OpenSSH'
    return -1
  endif

  echo system('scp ' . shellescape(a:src) . ' ' . shellescape(a:dest))

  if v:shell_error
    return -1
  endif

  return 1
endfunction

let s:handler = {}

function! s:handler.read(path, file) dict
  return s:scp(a:path, a:file)
endfunction

function! s:handler.write(path, file) dict
  return s:scp(a:file, a:path)
endfunction

call netlib#RegisterHandler('scp', 'openssh', s:handler, s:openssh_prio)

unlet s:handler

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let &cpo = s:savecpo
unlet s:savecpo
