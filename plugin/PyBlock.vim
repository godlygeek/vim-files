" PyBlock:     Simulate a}/i} text-objects for python
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        Thu, 11 Oct 2007 18:07:51 -0400
" Version:     0.1

" Abort if running in vi-compatible mode or the user doesn't want us.
" if &cp || exists('g:pyblock_loaded')
"   if &cp && &verbose
"     echo "Not loading PyBlock in compatible mode."
"   endif
"   finish
" endif

let g:pyblock_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" Function definitions                                                    {{{1

function! s:PyBlock()
  let line = line('.')
  let last = line('$')

  let i = 0

  for i in range(line, last)
    if match(getline(i), '^\s*$') != 0
      break
    endif
  endfor

  if match(getline(i), '^\s*$') == 0
    return
  endif

  let indent = matchstr(getline(i), '^\s*\ze\S')

  for i in range(line, 1, -1)
    if match(getline(i), '^\(\s*$\|' . indent . '\)') != 0
      break
    endif
  endfor

  if match(getline(i), '^\(\s*$\|' . indent . '\)') != 0
    call setpos("'[", [ bufnr(""), i+1, 0, 0 ])
  else
    call setpos("'[", [ bufnr(""), i, 0, 0 ])
  endif

  for i in range(line, last)
    if match(getline(i), '^\(\s*$\|' . indent . '\)') != 0
      break
    endif
  endfor

  if match(getline(i), '^\(\s*$\|' . indent . '\)') != 0
    call setpos("']", [ bufnr(""), i-1, 0, 0 ])
  else
    call setpos("']", [ bufnr(""), i, 0, 0 ])
  endif

  return "'[V']"
endfunction

" Mappings                                                                {{{1
if ! hasmapto("\<plug>PyBlock")
  map <silent> <leader>pb <plug>PyBlock
endif

noremap <silent> <expr> <plug>PyBlock <SID>PyBlock()

let &cpo = s:savecpo
unlet s:savecpo

" vim:set sw=2 sts=2:
