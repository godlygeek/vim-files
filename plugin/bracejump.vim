function! s:PrevBeginBrace()
  call search('\s*{', 'besW')
endfunction

function! s:PrevEndBrace()
  call s:PrevBeginBrace()
  norm %
endfunction

function! s:NextBeginBrace()
endfunction

function! s:NextEndBrace()
endfunction

function! s:VAC()
  let which = search('\(/\*\)\|\(//\)', 'bcpW')
  let lnum1 = line('.')
  let cnum1 = col('.')
  let move1 = (cnum1-1 ? (cnum1-1)."l" : "")
  if which == 3 " linewise comment
    return "\<ESC>" . lnum1 . "G$" . mode() . "0" . move1 . "o"
  elseif which == 2 " block comment
    let goto1 = lnum1 . "G0" . move1
    call search('\*/', 'ecW')
    let goto2 = line('.') . "G0" . (col('.')-1 ? (col('.') - 1) . "l" : "")
    return "\<ESC>" . goto1 . mode() . goto2
  endif
endfunction

function! s:VIC()
  let which = search('\(/\*\+\%(\_s\|\*\)*.\)\|\(//\s*.\)', 'becpW')
  let lnum1 = line('.')
  let cnum1 = col('.')
  let move1 = (cnum1-1 ? (cnum1-1)."l" : "")
  if which == 3 " linewise comment
    return "\<ESC>" . lnum1 . "G$" . mode() . "0" . move1 . "o"
  elseif which == 2 " block comment
    let goto1 = lnum1 . "G0" . move1
    call search('.\_s*\*/', 'cW')
    let goto2 = line('.') . "G0" . (col('.')-1 ? (col('.') - 1) . "l" : "")
    return "\<ESC>" . goto1 . mode() . goto2
  endif
endfunction

vnoremap <expr> ac <SID>VAC()
vnoremap <expr> ic <SID>VIC()
onoremap ac :normal vac<CR>
onoremap ic :normal vic<CR>
