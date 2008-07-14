function! CountMatches(...)
  try
    if getreg('/') == ''
      return ""
    endif

    let fast = 0

    if a:0 && a:1
      let fast = 1
    endif

    if fast && line('$') > 5000
      return ""
    endif

    let toomany = 0

    let [buf, lnum, cnum, off] = getpos('.')
    call setpos('.', [buf, lnum, cnum, off])

    let above=0
    let below=0

    while 1
      let [l, c] = searchpos(@/, 'bnW')
      if l == 0 && c == 0
        break
      endif

      let above += 1
      call setpos('.', [buf, l, c, 0])
      if above + below > 100
        let toomany = 1
        break
      endif
    endwhile

    call setpos('.', [buf, lnum, cnum, off])

    if toomany
      return ""
    endif

    let [l, c] = searchpos(@/, 'cnW')
    if l == lnum && c == cnum
      let above += 1
    endif

    call setpos('.', [buf, lnum, cnum, off])

    while 1
      let [l, c] = searchpos(@/, 'nW')
      if l == 0 && c == 0
        break
      endif

      let below += 1
      call setpos('.', [buf, l, c, 0])
      if above + below > 100
        let toomany = 1
        break
      endif
    endwhile

    call setpos('.', [buf, lnum, cnum, off])

    if toomany || (above+below) == 0
      return ""
    endif

    return "Match ".above." of ".(below+above)
  catch /.*/
    return ""
  endtry
endfunction
