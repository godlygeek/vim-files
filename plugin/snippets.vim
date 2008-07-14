" Snippets:    Read in files and replace marker text within them.
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        Wed, 10 Oct 2007 17:00:33 -0400
" Version:     0.1
" History:     TODO(History Link)

" Abort if running in vi-compatible mode or the user doesn't want us.     {{{1
if &cp || exists('g:snippets_loaded')
  if &cp && &verbose
    echo "Not loading Snippets in compatible mode."
  endif
  finish
endif

let g:snippets_loaded = 1

" Function definitions                                                    {{{1
let s:savecpo = &cpo
set cpo&vim

function! snippets#c_skel()
  keepjumps 0r ~/.vim/snippets/skel.c
  sil ']d _
  call snippets#ReplaceMarkers()
  sil 1
  call search('\C^.*main(')
endfunction

function! snippets#cpp_skel()
  keepjumps 0r ~/.vim/snippets/skel.cpp
  sil ']d _
  call snippets#ReplaceMarkers()
  sil 1
  call search('\C^.*main(')
endfunction

function! snippets#vim_skel()
  keepjumps 0r ~/.vim/snippets/skel.vim
  sil ']d _
  call snippets#ReplaceMarkers()
  sil 1
  call search('\C^.*fun.*(')
endfunction

function! snippets#bsd()
  keepjumps r ~/.vim/snippets/bsd
  call snippets#ReplaceMarkers()
endfunction

function! snippets#ReplaceMarkers()
  silent! %s/\CTODO(Name)/\=expand('%:p:t:r')/g
  silent! %s/\CTODO(name)/\=tolower(expand('%:p:t:r'))/g
  silent! %s/\CTODO(Date)/\=strftime("%a, %d %b %Y %H:%M:%S %z")/g
  silent! %s/\CTODO(Year)/\=strftime("%Y")/g
endfunction

function! snippets#Skel(...)
  call snippets#{a:0==0?&ft:a:1}_skel()
endfunction

command! -nargs=? Skel :call snippets#Skel(<f-args>)

command! -nargs=0 BSD :call snippets#bsd()

let &cpo = s:savecpo
unlet s:savecpo

" vim:set sw=2 sts=2:
