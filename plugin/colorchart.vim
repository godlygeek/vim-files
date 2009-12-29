" ColorChart:  Allows users to interactively examine terminal color cubes
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        Fri, 11 Dec 2009 05:51:49 -0500
" Version:     1.0
" History:     :help colorchart-changelog
"
" Long Description:
" Provides an interactive interface for examining the colors of a terminal
" color cube.  Also provides limited support for 8 and 16 color terminals,
" despite their complete lack of a color cube.  The idea behind this plugin is
" that it can allow you to choose a color from a palette, examine how it looks
" as a background and foreground color, learn how different terminals will
" display it, and even re-organize the palette to make it easier to compare
" colors.
"
" License:
" Copyright (c) 2009, Matthew J. Wozniski
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"     * Redistributions of source code must retain the above copyright notice,
"       this list of conditions and the following disclaimer.
"     * Redistributions in binary form must reproduce the above copyright
"       notice, this list of conditions and the following disclaimer in the
"       documentation and/or other materials provided with the distribution.
"     * The names of the contributors may not be used to endorse or promote
"       products derived from this software without specific prior written
"       permission.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
" OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
" OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
" NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT, INDIRECT,
" INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
" LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
" OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
" LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
" NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
" EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if exists('g:ColorChart_loaded')
  finish
endif

if has('gui_running')
  if &verbose
    echomsg 'Not loading ColorChart in GUI vim.'
  endif
  finish
endif

let g:ColorChart_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" Ensure that the globals are set up.
function! s:ColorChartInit()
  if get(s:, 'init_complete')
    return
  endif

  let s:init_complete = 1

  let s:angle = 0
  let s:origin = 0

  let s:last_color = 0

  let s:charts = { 8 : {}, 16 : {}, 88 : {}, 256 : {} }
  let s:origins = { }
  let s:angles = { }

  let s:reds = { }
  let s:greens = { }
  let s:blues = { }

  for i in [ 8, 16, 88, 256 ]
    let s:angles[i]  = (i >= 88 ? range(6) : [0])
    let s:origins[i] = (i >= 88 ? range(8) : [0])

    let s:reds[i] = (i > 88 ? range(6) : i == 88 ? range(4) : [])
    let s:greens[i] = (i > 88 ? range(6) : i == 88 ? range(4) : [])
    let s:blues[i] = (i > 88 ? range(6) : i == 88 ? range(4) : [])
  endfor

  let s:charts.8.ribbon =
      \   "0001020304050607\n"

  let s:charts.16.ribbon =
      \   "0001020304050607\n"
      \ . "08090a0b0c0d0e0f\n"

  let s:charts.88.clouds =
      \   "            25263635\n"
      \ . "          39292a3a        2122        3231\n"
      \ . "                    302010111213233343424140\n"
      \ . "5756555453525150    342414151617273747464544\n"
      \ . "                  48382818191a1b2b3b4b4a49\n"
      \ . "0001020304050607  4c3c2c1c1d1e1f2f3f4f4e4d\n"
      \ . "08090a0b0c0d0e0f    3d2d        2e3e\n"

  let s:charts.88.cows =
      \   "0001020304050607    263635\n"
      \ . "08090a0b0c0d0e0f  292a3a\n"
      \ . "                  25  39\n"
      \ . "5051525354555657\n"
      \ . "                  213141\n"
      \ . "                  22324246\n"
      \ . "    4030201011121323334347\n"
      \ . "  45443424141516172737\n"
      \ . "  4948382818191a1b2b3b\n"
      \ . "  4a  3c2c1c    1f  3f\n"
      \ . "  4b  3d2d1d    2f  3e\n"
      \ . "  4f  4d        2e  4e\n"
      \ . "      4c        1e\n"

  let s:charts.88.ribbon =
      \   "10111213233343424140303132222120\n"
      \ . "14151617273747464544343536262524\n"
      \ . "18191a1b2b3b4b4a494838393a2a2928\n"
      \ . "1c1d1e1f2f3f4f4e4d4c3c3d3e2e2d2c\n"
      \ . "\n"
      \ . "0001020304050607  5051525354555657\n"
      \ . "08090a0b0c0d0e0f\n"

  let s:charts.88.slices =
      \   "10111213  33323130  50  0008\n"
      \ . "14151617  37363534  51  0109\n"
      \ . "18191a1b  3b3a3938  52  020a\n"
      \ . "1c1d1e1f  3f3e3d3c  53  030b\n"
      \ . "2c2d2e2f  4f4e4d4c  54  040c\n"
      \ . "28292a2b  4b4a4948  55  050d\n"
      \ . "24252627  47464544  56  060e\n"
      \ . "20212223  43424140  57  070f\n"

  let s:charts.88.whales =
      \   "3222                        25263635\n"
      \ . "3121                        292a3a39\n"
      \ . "302010111213233343424140\n"
      \ . "342414151617273747464544    5756555453525150\n"
      \ . "382818191a1b2b3b4b4a4948\n"
      \ . "3c2c1c1d1e1f2f3f4f4e4d4c\n"
      \ . "            2e3e            0001020304050607\n"
      \ . "            2d3d            08090a0b0c0d0e0f\n"

  let s:charts.256.clouds =
      \   "0001020304050607          6061        8584\n"
      \ . "08090a0b0c0d0e0f    835f3b3c3d3e6286aaa9a8a7\n"
      \ . "                    896541424344688cb0afaead\n"
      \ . "                  b38f6b4748494a6e92b6b5b4\n"
      \ . "      66678b8a    b995714d4e4f507498bcbbba  e8ff\n"
      \ . "    906c6d91        9672        7397        e9fe\n"
      \ . "                                            eafd\n"
      \ . "              5a5b                7f7e      ebfc\n"
      \ . "    7d59    35363738    5c80    a4a3a2a1    ecfb\n"
      \ . "  a07c5834101112131415395d81a5c9c8c7c6c5c4  edfa\n"
      \ . "  a6825e3a161718191a1b3f6387abcfcecdcccbca  eef9\n"
      \ . "  ac8864401c1d1e1f202145698db1d5d4d3d2d1d0  eff8\n"
      \ . "d6b28e6a462223242526274b6f93b7dbdad9d8d7    f0f7\n"
      \ . "dcb894704c28292a2b2c2d517599bde1e0dfdedd    f1f6\n"
      \ . "e2be9a76522e2f30313233577b9fc3e7e6e5e4e3    f2f5\n"
      \ . "  bf9b7753    5455    567a9ec2    c1c0      f3f4\n"
      \ . "    9c78                799d\n"

  let s:charts.256.cows =
      \   "f4f5f6f7f8f9fafbfcfdfeff      59  a1          678b8a\n"
      \ . "f3f2f1f0efeeedecebeae9e8    365a7ea2c6      6c6d91\n"
      \ . "                            375b7fa3c7cdd3  66  90            6084a8\n"
      \ . "          7d  35            385c80a4c8ced4                    6185a9af\n"
      \ . "    c5c4a07c5834101112131415395d81a5c9cfd5      a7835f3b3c3d3e6286aab0\n"
      \ . "  cccbcaa6825e3a161718191a1b3f6387ab          aead896541424344688c\n"
      \ . "d8d2d1d0ac8864401c1d1e1f202145698db1          b4b38f6b4748494a6e92\n"
      \ . "de  d7d6b28e6a462223242526274b6f93b7db        b5  95714d    50  98\n"
      \ . "    dddcb894704c28292a2b2c2d517599bde1        b6  96724e    74  97\n"
      \ . "    e3e2be9a76522e2f30313233577b9fc3e7        bc  ba        73  bb\n"
      \ . "    e4  bf9b7753            567a    e6            b9        4f\n"
      \ . "    e5  c09c7854            5579    e0\n"
      \ . "    df  c1                    9d    da      0001020304050607\n"
      \ . "    d9  c2                    9e            08090a0b0c0d0e0f\n"

  let s:charts.256.ribbon =
      \   "101112131415395d81a5c9c8c7c6c5c4a07c583435597da1a2a3a4805c38375b7f7e5a36\n"
      \ . "161718191a1b3f6387abcfcecdcccbcaa6825e3a3b5f83a7a8a9aa86623e3d618584603c\n"
      \ . "1c1d1e1f202145698db1d5d4d3d2d1d0ac886440416589adaeafb08c684443678b8a6642\n"
      \ . "2223242526274b6f93b7dbdad9d8d7d6b28e6a46476b8fb3b4b5b6926e4a496d91906c48\n"
      \ . "28292a2b2c2d517599bde1e0dfdedddcb894704c4d7195b9babbbc9874504f739796724e\n"
      \ . "2e2f30313233577b9fc3e7e6e5e4e3e2be9a765253779bbfc0c1c29e7a5655799d9c7854\n"
      \ . "\n"
      \ . "0001020304050607  e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff\n"
      \ . "08090a0b0c0d0e0f\n"

  let s:charts.256.slices =
      \   "101112131415  5d5c5b5a5958  a0a1a2a3a4a5  e8ff  0008\n"
      \ . "161718191a1b  636261605f5e  a6a7a8a9aaab  e9fe  0109\n"
      \ . "1c1d1e1f2021  696867666564  acadaeafb0b1  eafd  020a\n"
      \ . "222324252627  6f6e6d6c6b6a  b2b3b4b5b6b7  ebfc  030b\n"
      \ . "28292a2b2c2d  757473727170  b8b9babbbcbd  ecfb  040c\n"
      \ . "2e2f30313233  7b7a79787776  bebfc0c1c2c3  edfa  050d\n"
      \ . "525354555657  9f9e9d9c9b9a  e2e3e4e5e6e7  eef9  060e\n"
      \ . "4c4d4e4f5051  999897969594  dcdddedfe0e1  eff8  070f\n"
      \ . "464748494a4b  939291908f8e  d6d7d8d9dadb  f0f7\n"
      \ . "404142434445  8d8c8b8a8988  d0d1d2d3d4d5  f1f6\n"
      \ . "3a3b3c3d3e3f  878685848382  cacbcccdcecf  f2f5\n"
      \ . "343536373839  81807f7e7d7c  c4c5c6c7c8c9  f3f4\n"

  let s:charts.256.whales =
      \   "a4805c38                                  8561\n"
      \ . "a37f5b37                                  8460\n"
      \ . "a27e5a36                                  835f3b3c3d3e6286aaa9a8a7\n"
      \ . "a17d5935                                  896541424344688cb0afaead\n"
      \ . "a07c5834101112131415395d81a5c9c8c7c6c5c4  8f6b4748494a6e92b6b5b4b3\n"
      \ . "a6825e3a161718191a1b3f6387abcfcecdcccbca  95714d4e4f507498bcbbbab9\n"
      \ . "ac8864401c1d1e1f202145698db1d5d4d3d2d1d0              7397\n"
      \ . "b28e6a462223242526274b6f93b7dbdad9d8d7d6              7296\n"
      \ . "b894704c28292a2b2c2d517599bde1e0dfdedddc  66678b8a\n"
      \ . "be9a76522e2f30313233577b9fc3e7e6e5e4e3e2  6c6d9190\n"
      \ . "                    567a9ec2\n"
      \ . "                    55799dc1\n"
      \ . "0001020304050607    54789cc0              f3f2f1f0efeeedecebeae9e8\n"
      \ . "08090a0b0c0d0e0f    53779bbf              f4f5f6f7f8f9fafbfcfdfeff\n"
endfunction

" Retrieves a chart by name, transforming it for the chosen angle and origin
function! s:GetChart(name)
  try
    let s:chart = a:name

    let chart = s:charts[&t_Co][a:name]

    if (&t_Co != 88 && &t_Co != 256)
      return chart
    endif

    let transformed = ""

    let max = (&t_Co == 256 ? 6 : 4)

    let amap = [[0,1,2], [1,2,0], [2,0,1], [0,2,1], [1,0,2], [2,1,0]][s:angle]
    let omap = [[1,1,1], [1,1,-1], [1,-1,-1], [1,-1,1],
               \[-1,-1,1], [-1,-1,-1], [-1,1,-1], [-1,1,1]][s:origin]

    for chunk in split(chart, '\(\x\x\|\X\+\)\zs')
      if chunk =~ '\x\x'
        let val = str2nr(chunk, 16)
        if val > 15 && val < max * max * max + 16
          let val -= 16

          let components = [ val / max / max,
                           \ val / max % max,
                           \ val % max ]

          for i in range(len(components))
            if omap[i] < 0
              let components[i] = max - 1 - components[i]
            endif
          endfor

          let r = components[amap[0]]
          let g = components[amap[1]]
          let b = components[amap[2]]

          let chunk = printf("%02x", 16 + (r * max + g) * max + b)
        endif
      endif

      let transformed .= chunk
    endfor

    return transformed
  catch
    return ""
  endtry
endfunction

" Draws the color chart and sets up the highlighting.
function! s:SetupColorChartImpl()
  " First, clear all lines and syntax highlighting
  %d_
  syn clear

  if &t_Co == 256
    let chart = s:GetChart(get(s:, 'chart', 'whales'))
  elseif &t_Co == 88
    let chart = s:GetChart(get(s:, 'chart', 'whales'))
  else
    let chart = s:GetChart(get(s:, 'chart', 'ribbon'))
  endif

  let s:origin_line = 1
  let message = 'Choose viewing origin ({/}): ' . join(s:origins[&t_Co], ' ')
  call setline(1, substitute(message, s:origin, '[\0]', ''))

  let s:angle_line = 2
  let message  = 'Choose viewing angle ([/]):  ' . join(s:angles[&t_Co], ' ')
  call setline(2, substitute(message, s:angle, '[\0]', ''))

  let s:chart_line = 3
  let message = 'Choose chart (-/+):  ' . join(keys(s:charts[&t_Co]), ' ')
  call setline(3, substitute(message, s:chart, '[\0]', ''))

  call setline(4, '')

  let s:red_line = 5
  let s:green_line = 6
  let s:blue_line = 7

  call setline(s:red_line, substitute('  Red:  ' . join(s:reds[&t_Co], ' '), s:red(), '[\0]', ''))
  call setline(s:green_line, substitute('Green:  ' . join(s:greens[&t_Co], ' '), s:green(), '[\0]', ''))
  call setline(s:blue_line, substitute(' Blue:  ' . join(s:blues[&t_Co], ' '), s:blue(), '[\0]', ''))

  " Marker, used by colorchartStart syntax match.
  call setline(8, "\t")

  let s:chart_start = 9
  call setline(9, split(substitute(chart, '\x\x', '__', 'g'), '\n'))
  let s:chart_end = line('$')

  " Ugly hack
  let c = get(s:, 'last_color', 0)
  let i = get(s:, 'last_color_info', 'Color 0:   ANSI Black')

  call append(line('$'), '')
  call append(line('$'), i)
  call append(line('$'), '')
  call append(line('$'), 'Black on color ' .c. '      White on color ' .c. '      Normal on color ' .c. '')
  call append(line('$'), 'Color ' .c. ' on black      Color ' .c. ' on white      Color ' .c. ' on normal')

  let skip = ' skipwhite skipempty skipnl'

  syn sync fromstart
  exe printf('syn match colorchartStart /^\t\n/ nextgroup=colorchart%d %s',
           \ str2nr(matchstr(chart, '\x\x'), 16), skip)

  let colors = chart
  while colors =~ '\x\x'
    let color1 = str2nr(matchstr(colors, '\x\x'), 16)
    let colors = substitute(colors, '\x\x', '', '')
    let color2 = str2nr(matchstr(colors, '\x\x'), 16)
    exe printf('syn match colorchart%d /__/ nextgroup=colorchart%d %s', color1, color2, skip)
  endwhile

  for i in range(&t_Co)
    exe printf('hi colorchart%d ctermbg=%d ctermfg=%d', i, i, i)
  endfor

  syn match colorchart_color_on_0   /\<Color \d\+ on black\>\&.\{1,18\}/
  syn match colorchart_color_on_15  /\<Color \d\+ on white\>\&.\{1,18\}/
  syn match colorchart_color_on_256 /\<Color \d\+ on normal\>\&.\{1,19\}/
  syn match colorchart0_on_color    /\<Black on color \d\+\>\&.\{1,18\}/
  syn match colorchart15_on_color   /\<White on color \d\+\>\&.\{1,18\}/
  syn match colorchart256_on_color  /\<Normal on color \d\+\>\&.\{1,19\}/

  exe printf('hi colorchart_color_on_0   ctermfg=%d ctermbg=0',  c)
  exe printf('hi colorchart_color_on_15  ctermfg=%d ctermbg=15', c)
  exe printf('hi colorchart_color_on_256 ctermfg=%d ctermbg=bg', c)
  exe printf('hi colorchart0_on_color    ctermbg=%d ctermfg=0',  c)
  exe printf('hi colorchart15_on_color   ctermbg=%d ctermfg=15', c)
  exe printf('hi colorchart256_on_color  ctermbg=%d ctermfg=fg', c)

  call s:JumpToColor()
endfunction

" Calls SetupColorChartImpl, while handling saving and restoring options and
" the cursor position
function! s:SetupColorChart()
  "let cursor_pos = getpos('.')
  let old_ei = &ei
  let old_lz = &lz

  try
    set lz ei=all
    setlocal modifiable

    call s:SetupColorChartImpl()
  finally
    setlocal nomodifiable nomodified

    "call setpos('.', cursor_pos)

    let &ei = old_ei
    let &lz = old_lz
  endtry
endfunction

" Main entry point.  Creates a new color chart buffer and sets buffer-local
" options and mappings.
function! ColorChart()
  new

  call s:ColorChartInit()

  if bufexists("Color Chart")
    let i = 2
    while bufexists("Color Chart " . i)
      let i = i+1
    endwhile
    exe 'file Color\ Chart\ ' . i
  else
    file Color\ Chart
  endif

  setlocal nolist buftype=nofile bufhidden=wipe noswapfile tabstop=1 iskeyword+=[,] matchpairs= nocursorline nocursorcolumn

  call s:SetupColorChart()

  nnoremap <buffer> <silent> { :call <SID>ChangeOrigin(-1)<CR>
  nnoremap <buffer> <silent> } :call <SID>ChangeOrigin(1)<CR>

  nnoremap <buffer> <silent> [ :call <SID>ChangeAngle(-1)<CR>
  nnoremap <buffer> <silent> ] :call <SID>ChangeAngle(1)<CR>

  nnoremap <buffer> <silent> - :call <SID>ChangeChart(-1)<CR>
  nnoremap <buffer> <silent> + :call <SID>ChangeChart(1)<CR>

  nnoremap <buffer> <silent> <leader>r :<C-U>call <SID>ChangeColor( 1 * v:count1, 0, 0)<CR>
  nnoremap <buffer> <silent> <leader>R :<C-U>call <SID>ChangeColor(-1 * v:count1, 0, 0)<CR>

  nnoremap <buffer> <silent> <leader>g :<C-U>call <SID>ChangeColor(0,  1 * v:count1, 0)<CR>
  nnoremap <buffer> <silent> <leader>G :<C-U>call <SID>ChangeColor(0, -1 * v:count1, 0)<CR>

  nnoremap <buffer> <silent> <leader>b :<C-U>call <SID>ChangeColor(0, 0,  1 * v:count1)<CR>
  nnoremap <buffer> <silent> <leader>B :<C-U>call <SID>ChangeColor(0, 0, -1 * v:count1)<CR>

  nnoremap <buffer> <silent> gc :<C-U>call <SID>ColorByNumber(v:count, +1)<CR>
  nnoremap <buffer> <silent> gC :<C-U>call <SID>ColorByNumber(v:count, -1)<CR>

  autocmd CursorMoved,CursorMovedI <buffer> nested call <SID>UpdatePreview()
  autocmd ColorScheme <buffer> call <SID>SetupColorChart()
endfunction

function! s:red()
    let cube_size = (&t_Co == 88 ? 4 : 6)
    if s:last_color < 16 || s:last_color >= 16 + cube_size * cube_size * cube_size
        return -1
    endif
    return (s:last_color - 16) / (cube_size * cube_size)
endfunction

function! s:green()
    let cube_size = (&t_Co == 88 ? 4 : 6)
    if s:last_color < 16 || s:last_color >= 16 + cube_size * cube_size * cube_size
        return -1
    endif
    return (s:last_color - 16) / cube_size % cube_size
endfunction

function! s:blue()
    let cube_size = (&t_Co == 88 ? 4 : 6)
    if s:last_color < 16 || s:last_color >= 16 + cube_size * cube_size * cube_size
        return -1
    endif
    return (s:last_color - 16) % cube_size
endfunction

function! s:ColorByNumber(count, direction)
    let color = a:count

    if !color
        let color = s:last_color + a:direction
    endif

    if color < 0
        let color = 0
    elseif color > &t_Co - 1
        let color = &t_Co - 1
    endif

    call s:JumpToColor(color)
endfunction

function! s:ChangeColor(rdelta, gdelta, bdelta)
  let color = get(s:, 'last_color', 0)
  let cube_size = (&t_Co == 88 ? 4 : 6)

  let delta = [ a:rdelta, a:gdelta, a:bdelta ]

  "echomsg "Color before: " . color

  if color >= 16 && color < 16 + cube_size * cube_size * cube_size
    let rgb = [ (color - 16) / cube_size / cube_size,
              \ (color - 16) / cube_size % cube_size,
              \ (color - 16) % cube_size ]

    "echomsg "color components before: " . string(rgb)

    for i in range(len(rgb))
      let rgb[i] += delta[i]

      if rgb[i] < 0
        let rgb[i] = 0
      endif

      if rgb[i] > cube_size - 1
        let rgb[i] = cube_size - 1
      endif
    endfor

    "echomsg "color components after: " . string(rgb)

    let color = rgb[0] * cube_size * cube_size
            \ + rgb[1] * cube_size
            \ + rgb[2]
            \ + 16

    call s:JumpToColor(color)
  endif

  "echomsg "Color after: " . color
endfunction

" Update the preview based on the cursor's movement, assuming that it has
" moved onto a "sensitive" part of the buffer.
function! s:UpdatePreview()
  if line('.') == s:angle_line
    let word = expand("<cword>")
    if word =~ '^\d\+$' && word != s:angle
      let s:angle = word
      call s:SetupColorChart()
    endif

    return
  endif

  if line('.') == s:origin_line
    let word = expand("<cword>")
    if word =~ '^\d\+$' && word != s:origin
      let s:origin = word
      call s:SetupColorChart()
    endif

    return
  endif

  if line('.') == s:chart_line
    let word = expand("<cword>")
    if index(keys(s:charts[&t_Co]), word) >= 0 && word !=# s:chart
      let s:chart = word
      call s:SetupColorChart()
    endif

    return
  endif

  let red = s:red()
  let green = s:green()
  let blue = s:blue()

  for colorname in [ 'red', 'green', 'blue' ]
    if line('.') == get(s:, colorname . '_line')
      let word = expand("<cword>")
      if word =~ '^\d\+$' && word != get(l:, colorname)

        if l:red == -1
            let l:red = 0
        endif

        if l:green == -1
            let l:green = 0
        endif

        if l:blue == -1
            let l:blue = 0
        endif

        let l:[colorname] = word

        let cube_size = (&t_Co == 88 ? 4 : 6)

        let jump_to_color = 1
        let color = (l:red * (cube_size * cube_size)
                \ +  l:green * (cube_size)
                \ +  l:blue
                \ +  16)
      endif
    endif
  endfor

  if !exists('color')
    if line('.') < s:chart_start || line('.') > s:chart_end
      " Not in the chart, no possible redraw
      return
    endif

    let name = synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
    let color = matchstr(name, 'colorchart\zs\d\+')

    if empty(color)
      return
    endif
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

  let s:last_color = color
  let s:last_color_info = info

  setlocal modifiable

  for line in range(1, line('$'))
    let text = getline(line)
    let text = substitute(text, 'Color \d\+:.*', info, '')
    let text = substitute(text, 'on color \zs\(\d\+\&.\{1,3}\)\ze', printf('%-3s', color), 'g')
    let text = substitute(text, 'Color \d\+ on \(black\|white\)\&.\{1,18}', '\=printf("%-18s", "Color " . color . " on " . submatch(1))', 'g')
    let text = substitute(text, 'Color \d\+ on \(normal\)\&.\{1,19}', '\=printf("%-19s", "Color " . color . " on " . submatch(1))', 'g')

    call setline(line, text)
  endfor

  call setline(s:red_line, substitute('  Red (\R \r):  ' . join(s:reds[&t_Co], ' '), s:red(), '[\0]', ''))
  call setline(s:green_line, substitute('Green (\G \g):  ' . join(s:greens[&t_Co], ' '), s:green(), '[\0]', ''))
  call setline(s:blue_line, substitute(' Blue (\B \b):  ' . join(s:blues[&t_Co], ' '), s:blue(), '[\0]', ''))

  exe printf('hi colorchart_color_on_0   ctermfg=%d ctermbg=0',  color)
  exe printf('hi colorchart_color_on_15  ctermfg=%d ctermbg=15', color)
  exe printf('hi colorchart_color_on_256 ctermfg=%d ctermbg=bg', color)
  exe printf('hi colorchart0_on_color    ctermbg=%d ctermfg=0',  color)
  exe printf('hi colorchart15_on_color   ctermbg=%d ctermfg=15', color)
  exe printf('hi colorchart256_on_color  ctermbg=%d ctermfg=fg', color)

  setlocal nomodifiable nomodified

  if get(l:, 'jump_to_color', 0)
    call s:JumpToColor()
  endif
endfunction

function! s:JumpToColor(...)
  let s:jump_count = get(s:, 'jump_count', 0) + 1

  if a:0
    let color = a:1
  else
    let color = get(s:, 'last_color', 0)
  endif

  if &t_Co == 256
    let chartstr = s:GetChart(get(s:, 'chart', 'whales'))
  elseif &t_Co == 88
    let chartstr = s:GetChart(get(s:, 'chart', 'whales'))
  else
    let chartstr = s:GetChart(get(s:, 'chart', 'ribbon'))
  endif

  let chart = split(chartstr, "\n")

  for i in range(len(chart))
    let col = match(chart[i], '\<\%(\x\x\)*\zs' . printf("%02x", color))
    if col != -1
      call cursor(s:chart_start + i, col+1)
      return
    endif
  endfor

  echoerr "JumpToColor failed!"
endfunction

" Cycle to another origin
function! s:ChangeOrigin(direction)
  let idx = (index(s:origins[&t_Co], s:origin) + a:direction)
  let idx = idx % len(s:origins[&t_Co])
  let s:origin = s:origins[&t_Co][idx]
  call s:SetupColorChart()
endfunction

" Cycle to another angle
function! s:ChangeAngle(direction)
  let idx = (index(s:angles[&t_Co], s:angle) + a:direction)
  let idx = idx % len(s:angles[&t_Co])
  let s:angle = s:angles[&t_Co][idx]
  call s:SetupColorChart()
endfunction

" Cycle to another chart
function! s:ChangeChart(direction)
  let idx = (index(keys(s:charts[&t_Co]), s:chart) + a:direction)
  let idx = idx % len(s:charts[&t_Co])
  let s:chart = keys(s:charts[&t_Co])[idx]
  call s:SetupColorChart()
endfunction

command! ColorChart :call ColorChart()
