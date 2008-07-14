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
set cpo+=k

function! s:MapAllModes(map)
  exe "map" a:map | exe "map!" a:map
endfunction

function! s:MapArrow(prefix, modifiers)
  let dict = { 'A' : 'up', 'B' : 'down', 'C' : 'right', 'D' : 'left' }
  for l in keys(dict)
    call s:MapAllModes(a:prefix . l . " <" . a:modifiers . dict[l] . ">")
  endfor
endfunction

" All modified arrow keys...
"call s:MapArrow("\<ESC>O", "")
call s:MapArrow("\<ESC>[1;2", "s-")
call s:MapArrow("\<ESC>[1;3", "a-")
call s:MapArrow("\<ESC>[1;4", "a-s-")
call s:MapArrow("\<ESC>[1;5", "c-")
call s:MapArrow("\<ESC>[1;7", "c-a-")
call s:MapArrow("\<ESC>[1;8", "c-a-s-")

" Backspace
call s:MapAllModes("\<C-h> <BS>")
call s:MapAllModes("\<C-?> <BS>")

delfunction s:MapAllModes
delfunction s:MapArrow

let &cpo=savecpo
