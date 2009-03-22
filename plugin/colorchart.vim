function! ColorChart()
  new

  if bufexists("Color Chart")
    exe bufnr("Color Chart") . 'b'
    return
  endif

  setlocal nolist buftype=nofile bufhidden=wipe nomodified noswapfile
  file Color\ Chart

  if &t_Co == 256
    let chart  = "567a9ec2                                  7397\n"
    let chart .= "55799dc1                                  7296\n"
    let chart .= "54789cc0                                  7195b9babbbc9874504f4e4d\n"
    let chart .= "53779bbf                                  6b8fb3b4b5b6926e4a494847\n"
    let chart .= "52769abee2e3e4e5e6e7c39f7b57333231302f2e  6589adaeafb08c6844434241\n"
    let chart .= "4c7094b8dcdddedfe0e1bd9975512d2c2b2a2928  5f83a7a8a9aa86623e3d3c3b\n"
    let chart .= "466a8eb2d6d7d8d9dadbb7936f4b272625242322              8561\n"
    let chart .= "406488acd0d1d2d3d4d5b18d694521201f1e1d1c              8460\n"
    let chart .= "3a5e82a6cacbcccdcecfab87633f1b1a19181716  90916d6c\n"
    let chart .= "34587ca0c4c5c6c7c8c9a5815d39151413121110  8a8b6766\n"
    let chart .= "                    a4805c38\n"
    let chart .= "                    a37f5b37\n"
    let chart .= "0001020304050607    a27e5a36              f3f2f1f0efeeedecebeae9e8\n"
    let chart .= "08090a0b0c0d0e0f    a17d5935              f4f5f6f7f8f9fafbfcfdfeff\n"
  elseif &t_Co == 88
    let chart  = "2e3e                        393a2a29\n"
    let chart .= "2d3d                        35362625\n"
    let chart .= "2c3c4c4d4e4f3f2f1f1e1d1c\n"
    let chart .= "283848494a4b3b2b1b1a1918    5756555453525150\n"
    let chart .= "243444454647372717161514\n"
    let chart .= "203040414243332313121110\n"
    let chart .= "            3222            0001020304050607\n"
    let chart .= "            3121            08090a0b0c0d0e0f\n"
  else
    let chart  = "0001020304050607\n"
    let chart .= "08090a0b0c0d0e0f\n"
  endif

  call setline(2, split(substitute(chart, '\x\x', '::', 'g'), '\n'))

  call append(line('$'), '')
  call append(line('$'), 'Color 0:')
  call append(line('$'), '')
  call append(line('$'), 'Black on color 0      White on color 0')
  call append(line('$'), 'Color 0 on black      Color 0 on white')

  let skip = ' skipwhite skipempty skipnl'

  syn sync fromstart
  exe printf('syn match colorchartStart /^\n/ nextgroup=colorchart%d %s',
           \ str2nr(matchstr(chart, '\x\x'), 16), skip)

  let colors = chart
  while colors =~ '\x\x'
    let color1 = str2nr(matchstr(colors, '\x\x'), 16)
    let colors = substitute(colors, '\x\x', '', '')
    let color2 = str2nr(matchstr(colors, '\x\x'), 16)
    exe printf('syn match colorchart%d /::/ nextgroup=colorchart%d %s', color1, color2, skip)
  endwhile

  for i in range(&t_Co)
    exe printf('syn match colorchart%d_on_0  /\<Color %d on black\>\&.\{1,18\}/', i, i)
    exe printf('syn match colorchart%d_on_15 /\<Color %d on white\>\&.\{1,18\}/', i, i)
    exe printf('syn match colorchart0_on_%d  /\<Black on color %d\>\&.\{1,18\}/', i, i)
    exe printf('syn match colorchart15_on_%d /\<White on color %d\>\&.\{1,18\}/', i, i)
  endfor

  for i in range(&t_Co)
    exe printf('hi colorchart%d ctermbg=%d ctermfg=%d', i, i, i)
    exe printf('hi colorchart%d_on_0  ctermfg=%d ctermbg=0 ', i, i)
    exe printf('hi colorchart%d_on_15 ctermfg=%d ctermbg=15', i, i)
    exe printf('hi colorchart0_on_%d  ctermbg=%d ctermfg=0 ', i, i)
    exe printf('hi colorchart15_on_%d ctermbg=%d ctermfg=15', i, i)
  endfor

  autocmd CursorMoved,CursorMovedI <buffer> call <SID>UpdatePreview()

  1/:/
endfunction

function! s:UpdatePreview()
  let name = synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
  let color = matchstr(name, 'colorchart\zs\d\+')

  if empty(color)
    return
  endif

  if color < 16
    let ansi = [ 'Black',      'Dark Red',     'Dark Green',  'Brown',
               \ 'Dark Blue',  'Purple',       'Cyan',        'Light Grey',
               \ 'Dark Grey',  'Light Red',    'Light Green', 'Yellow',
               \ 'Light Blue', 'Light Purple', 'Light Cyan',  'White'      ]
    let info = 'Color ' . printf('%-5s', color . ': ') . 'ANSI ' . ansi[color]
  elseif &t_Co == 256
    let info = 'Color ' . printf('%-5s', color . ': ')
    if color >= 232
      let info .= '#' . repeat(printf('%02x', (color - 232) * 10 + 0x08), 3)
    else
      let x = [ '00', '5f', '87', 'af', 'd7', 'ff' ]
      let k = [ '00', '33', '66', '99', 'cc', 'ff' ]
      let e = [ '00', '2a', '55', '7f', 'aa', 'd4' ]

      let idx = [ (color - 16) / 36, (color - 16) % 36 / 6, (color - 16) % 6 ]
      let info .= 'xterm clones: #' . x[idx[0]] . x[idx[1]] . x[idx[2]]
      let info .= '  konsole: #' . k[idx[0]] . k[idx[1]] . k[idx[2]]
      let info .= '  eterm: #' . e[idx[0]] . e[idx[1]] . e[idx[2]]
    endif
  else " t_Co=88
    let info = 'Color ' . printf('%-5s', color . ': ')
    if color >= 80
      let g = [ '2e', '5c', '73', '8b', 'a2', 'b9', 'd0', 'e7' ]
      let info .= '#' . repeat(g[color - 80], 3)
    else
      let u = [ '00', '8b', 'cd', 'ff' ]
      let idx = [ (color - 16) / 16, (color - 16) % 16 / 4, (color - 16) % 4 ]
      let info .= '#' . u[idx[0]] . u[idx[1]] . u[idx[2]]
    endif
  endif

  setlocal modifiable

  for line in range(1, line('$'))
    let text = getline(line)
    let text = substitute(text, 'Color \d\+:.*', info, '')
    let text = substitute(text, 'on color \zs\(\d\+\&.\{1,3}\)\ze', printf('%-3s', color), 'g')
    let text = substitute(text, 'Color \d\+ on \(black\|white\)\&.\{1,18}', '\=printf("%-18s", "Color " . color . " on " . submatch(1))', 'g')
    call setline(line, text)
  endfor

  setlocal nomodifiable nomodified
endfunction
