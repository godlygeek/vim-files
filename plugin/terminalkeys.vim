" terminalkeys:  Adds support for keysyms for a lot of terminal keycodes.
" Maintainer:    Matthew Wozniski (mjw@drexel.edu)
" Date:          Thu, 29 Nov 2007 15:08:36 -0500
" Version:       0.1
" History:       TODO(History Link)

" Abort if running in vi-compatible mode or the user doesn't want us.
if &cp || exists('g:terminalkeys_loaded') || has("gui_running")
  if &cp && &verbose
    echo "Not loading terminalkeys in compatible mode."
  endif
  finish
endif

let g:terminalkeys_loaded = 1

let savecpo=&cpo
set cpo&vim

function! s:FastMap(keycode)
  if !exists("s:fastmap_keys")
    " <F25> through <F37> and <S-F25> through <S-F37>
    let s:fastmap_keys  = map(range(25, 37), '"<F".v:val.">"')
    let s:fastmap_keys += map(copy(s:fastmap_keys), '"<S-F".v:val[2:]')
  endif

  if empty(s:fastmap_keys)
    throw "No function keys remaining!"
  endif

  let key = remove(s:fastmap_keys, 0)
  exe 'set '.key.'='.a:keycode
  return key
endfunction

function! s:MapAllModes(map)
  exe "map" a:map | exe "map!" a:map
endfunction

function! s:MapArrowKeys()
  let dict = { 'A' : 'up', 'B' : 'down', 'C' : 'right', 'D' : 'left' }

  for [ letter, dir ] in items(dict)
    exe "set <" . dir . ">=\e[1;*" . letter
    call s:MapAllModes(s:FastMap("\eO".letter) . " <" . dir . ">")
    call s:MapAllModes(s:FastMap("\e[".letter) . " <" . dir . ">")
  endfor
endfunction

function! s:MapFunctionKeys()
  for i in range(4)
    exe "set <F" . (i+1) . ">=\e[1;*" . nr2char(80+i)
    call s:MapAllModes(s:FastMap("\eO" . nr2char(80+i)) . " <F" . (i+1) . ">")
  endfor

  exe "set  <F5>=\e[15;*~"

  exe "set  <F6>=\e[17;*~"
  exe "set  <F7>=\e[18;*~"
  exe "set  <F8>=\e[19;*~"
  exe "set  <F9>=\e[20;*~"
  exe "set <F10>=\e[21;*~"

  exe "set <F11>=\e[23;*~"
  exe "set <F12>=\e[24;*~"
endfunction

function! s:MapOthers()
  " <BS>
  exe "set <BS>=\<C-?>"
  call s:MapAllModes("\<C-h> <BS>")

  " <Home>/<End>
  exe "set <Home>=\<Esc>[1;*H"
  exe "set <End>=\<Esc>[1;*F"
  call s:MapAllModes(s:FastMap("\e[H")  . " <Home>")
  call s:MapAllModes(s:FastMap("\e[F")  . " <End>")
  call s:MapAllModes(s:FastMap("\e[1~") . " <Home>")
  call s:MapAllModes(s:FastMap("\e[4~") . " <End>")

  " <Insert>/<Del>/<PageUp>/<PageDown>
  exe "set <Insert>=\<Esc>[2;*~"
  exe "set <Del>=\<Esc>[3;*~"
  exe "set <PageUp>=\<Esc>[5;*~"
  exe "set <PageDown>=\<Esc>[6;*~"

  " <S-Tab>
  exe "set <S-Tab>=\<Esc>[Z"
endfunction

try
  call s:MapArrowKeys()
  call s:MapFunctionKeys()
  call s:MapOthers()
finally
  let &cpo=savecpo
endtry
