if exists("g:netplugin_rsync_loaded")
  \ || empty(system('rsync --version')) || v:shell_error > 0
  finish
endif

let g:netplugin_rsync_loaded = 1

let s:savecpo = &cpo
set cpo&vim

let s:rsync_prio = 50

let s:handler = {}

function! s:handler.read(path, file) dict
  let [ path, file ] = [ 'rsync://' . a:path, a:file ]
  echo system('rsync ' . shellescape(path) . ' ' . shellescape(file))
  return v:shell_error ? -1 : 1
endfunction

function! s:handler.write(path, file) dict
  let [ path, file ] = [ 'rsync://' . a:path, a:file ]
  echo system('rsync ' . shellescape(file) . ' ' . shellescape(path))
  return v:shell_error ? -1 : 1
endfunction

call netlib#RegisterHandler('rsync', 'generic', s:handler, s:rsync_prio)

unlet s:handler

let &cpo = s:savecpo
unlet s:savecpo
