finish " Don't load this; I don't want it.

map <c-]> :call TagFollowSmart()<CR>

function! TagFollowSmart()
  let before = bufname("")
  exe "tag " . expand("<cword>")
  if bufname("") == before
    return
  endif
  pop
  tab split
  exe "tag " . expand("<cword>")
endfunction
