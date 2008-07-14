if &cp || exists("g:loaded_ZoomWin")
 finish
endif

let s:keepcpo        = &cpo
let g:loaded_ZoomWin = 1
set cpo&vim

function! ZoomWin()
  if exists("s:layout") && !empty(s:layout)
    call windowlayout#SetLayout(s:layout)
    unlet s:layout
  else
    let s:layout = windowlayout#GetLayout()
    wincmd o
  endif
endfunction

nnoremap <silent> <script> <Plug>ZoomWin :call ZoomWin()<CR>
if !hasmapto("<Plug>ZoomWin")
 nmap <unique> <c-w>o  <Plug>ZoomWin
endif
command! ZoomWin :set lz|silent call ZoomWin()|set nolz

let &cpo = s:keepcpo
unlet s:keepcpo
