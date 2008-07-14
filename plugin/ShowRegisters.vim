function! s:GetRegisters()
  let regs = ""

  redir => regs
  silent registers
  redir END

  return regs
endfunction

function! s:CookRegisters(regs)
  let split = split(a:regs, '\n')
  for i in range(len(split))
    let split[i] = substitute(split[i], '^"\(.\) ', '\1:', '')
    let split[i] = substitute(split[i], '\(.\{36\}\).*', '\1...', '')
  endfor
  let split = split[1:]

  let rv = []
  for i in range(len(split))
    if i % 2 == 0
      call add(rv, split[i] . repeat(' ', 40 - len(split[i])))
    else
      let rv[-1] .= "  " . split[i]
    endif
  endfor

  return rv
endfunction

function! s:RegisterRegisterAutocmds()
  augroup RegisterWindow
    au!
    au CursorHold  * call <SID>UpdateRegisterWindow()
    au CursorMoved * call <SID>UpdateRegisterWindow()
  augroup END
endfunction

function! s:UnregisterRegisterAutocmds()
  augroup RegisterWindow
    au!
  augroup END
endfunction

function! s:SavePreviousWindow()
  winc p
  let s:bufprev = bufnr("")
  winc p
  let s:bufcurr = bufnr("")
endfunction

function! s:RestorePreviousWindow()
  let orig_switchbuf = &switchbuf
  set switchbuf=useopen
  exe "sbuffer " . s:bufprev
  exe "sbuffer " . s:bufcurr

  let &switchbuf = orig_switchbuf
endfunction

function! s:RegisterRegisterWindow()
  call s:SavePreviousWindow()

  try
    silent! winc P
  catch /E441:/
  endtry

  if ! &previewwindow
    8new
    setlocal previewwindow

    if &previewwindow
      setlocal nomodifiable
      setlocal bufhidden=wipe
      setlocal nobuflisted
      setlocal noswapfile
      setlocal buftype=nofile
      setlocal nolist
      setlocal nowrap
      setlocal winfixheight

      call matchadd('ModeMsg', '.*')
      call matchadd('Comment', '\%1c\|\%2c\|\%43c\|\%44c')
    endif
  endif

  call s:RegisterRegisterAutocmds()
  call s:RestorePreviousWindow()

  if exists("s:regs")
    unlet s:regs
  endif

  let s:regs=""
  call s:UpdateRegisterWindow()
endfunction

function! s:UnregisterRegisterWindow()
  try
    winc P
    call s:UnregisterRegisterAutocmds()
    bd!
  catch /E441:/
  endtry
endfunction

function! s:UpdateRegisterWindow()
  if &previewwindow
    return
  endif

  let regs = s:GetRegisters()

  if regs == s:regs
    return
  endif

  let s:regs = regs

  call s:SavePreviousWindow()
  winc P
  setlocal modifiable
  silent 1,$d _
  call setline(1, s:CookRegisters(regs))
  setlocal nomodifiable
  setlocal nomodified
  call s:RestorePreviousWindow()
endfunction

command! -nargs=0 RO :call <SID>RegisterRegisterWindow()
command! -nargs=0 RC :call <SID>UnregisterRegisterWindow()
