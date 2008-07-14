function! EatCharAndExeIf(...)
  if a:0 < 2 || a:0 / 2 * 2 != a:0
    throw "Invalid arguments!"
  endif

  for i in range(a:0 / 2)
    if nr2char(getchar(1)) =~ a:000[2*i]
      call getchar(0)
      exe "norm! " . a:000[2*i+1]
      return i
    endif
  endfor

  return -1
endfunction

inoremap { <C-\><C-o>i{
iabbr { {<C-r>=EatCharAndExeIf('\t', 'i}', '[\r\n]', 'o}') == 1 ? "\<lt>C-o>O" : ''<CR>
inoremap <expr> } getline('.')[col('.')-1] == '}' ? "\<lt>del>}" : "}"

" inoremap ( <C-\><C-o>i(
" iabbr ( (<C-r>=EatCharAndExeIf('\t', 'i)') ? '' : ''<CR>
" inoremap <expr> ) getline('.')[col('.')-1] == ')' ? "\<lt>del>)" : ")"
"
" inoremap [ <C-\><C-o>i[
" iabbr [ [<C-r>=EatCharAndExeIf('\t', 'i]') ? '' : ''<CR>
" inoremap <expr> ] getline('.')[col('.')-1] == ']' ? "\<lt>del>]" : "]"
