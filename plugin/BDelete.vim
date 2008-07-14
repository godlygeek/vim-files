function! s:BDelete(bang, ...)
  let tabpagenum = tabpagenr()

  let bufnums = deepcopy(a:000)
  if bufnums == []
    call add(bufnums, bufnr(""))
  endif
  tabdo call s:MoveAll(bufnums)
  exe "bd " . join(bufnums)

  exe "tabn " . tabpagenum
endfunction

function! s:MoveAll(numbers)
  let currwin = winnr()
  windo call s:Blank(a:numbers)
  exe currwin . "wincmd w"
endfunction

function! s:Blank(numbers)
  if count(a:numbers, bufnr("")) != 0
    let prev = bufnr("#")
    if prev > 0 && buflisted(prev) && count(a:numbers, prev) == 0
      b #
    else
      bn
      if count(a:numbers, bufnr("")) != 0
        enew
      endif
    endif
  endif
endfunction

command! -nargs=* -complete=buffer -bang -bar BD :call <SID>BDelete(<q-bang>, <f-args>)
