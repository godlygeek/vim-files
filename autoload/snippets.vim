function! snippets#bsd()
  keepjumps 0r ~/.vim/snippets/bsd
  keepjumps call setline(1, substitute(getline(1), ',' , strftime('%Y') . ',', ''))
endfunction
