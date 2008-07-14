" SyntaxAttr:  Get syntax attributes of character under cursor
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        Fri, 23 Nov 2007 16:04:35 -0500
" Version:     0.1
" History:     TODO(History Link)

" Abort if running in vi-compatible mode or the user doesn't want us.
if &cp " || exists('g:syntaxattr_loaded')
  if &cp && &verbose
    echo "Not loading SyntaxAttr in compatible mode."
  endif
  finish
endif

let g:syntaxattr_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" Function definitions                                                    {{{1

function! SyntaxAttr()
  let output = ""
  let id1 = synID(line("."), col("."), 1)
  let id2 = synIDtrans(id1)

  let name1 = synIDattr(id1, "name")
  let name2 = synIDattr(id2, "name")

  if name1 == ""
    let name1 = "Normal"
  endif

  if name2 == ""
    let name2 = "Normal"
  endif

  redir =>hl
  sil exe 'sil! hi' name2
  redir END
  redraw

  let output .= name1
  if id1 != id2
    let output .= ' -> ' . name2
  endif

  exe 'echohl' name2
  echon "xxx"
  echohl None
  echon "  " . output
  echon "  " . join(split(hl, '\_s\+')[2:-1])
endfunction

nmap <silent> <F1> :call SyntaxAttr()<CR>

let &cpo = s:savecpo
unlet s:savecpo

" vim:set sw=2 sts=2:
