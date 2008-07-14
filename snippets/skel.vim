" GetLatestVimScripts: TODO(SID) 1 :AUTOINSTALL: TODO(Name)

" TODO(Name):  TODO(Desc)
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        TODO(Date)
" Version:     0.1
" History:     TODO(History Link)

" Abort if running in vi-compatible mode or the user doesn't want us.
if &cp || exists('g:TODO(name)_loaded')
  if &cp && &verbose
    echo "Not loading TODO(Name) in compatible mode."
  endif
  finish
endif

let g:TODO(name)_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" Function definitions                                                    {{{1

function! s:TODO(Name)()
endfunction

let &cpo = s:savecpo
unlet s:savecpo

" vim:set sw=2 sts=2:
