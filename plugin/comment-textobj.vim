function! s:VAC()
  if search('\m\%#/\*', 'bcnW') || search('\m/\%#\*', 'bcnW')
    " On /*
    return ']*o]*[*o'
  elseif search('\m/\*\%(\%(\*/\)\@!\_.\)*\%#\_.\{-}\%(\*/\)', 'bcnW')
    \ || search('\m\%#\*/', 'bnW') || search('\m\*\%#/', 'bnW')
    " Between /* and */, or on a */
    return '[*o[*]*'
  endif
  " Return to normal mode and sound a bell.
  return "\<C-\>\<C-n>\<Esc>"
endfunction

function! s:VIC()
  let vac = s:VAC()
  if vac !~ '\m[\x1b]' " If the result contains an <Esc>, not in a comment
    return vac . 'owoge'
  endif
  return vac
endfunction

vnoremap <expr> ac <SID>VAC()
vnoremap <expr> ic <SID>VIC()
onoremap ac :normal vac<CR>
onoremap ic :normal vic<CR>
