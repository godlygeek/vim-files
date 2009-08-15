" matchparen is great for tracking what part of the code structure your cursor
" is on as you move it, but it can be disorienting when highlights are left in
" multiple windows, or when glancing away for large periods of time.  So,
" tweak matchparen to only show these match highlights in the current window,
" and to have the timeouts turn off after several seconds without moving.
if exists('g:loaded_matchparen_usability')
  finish
endif

let g:loaded_matchparen_usability=1

if exists(':3match')
  au WinLeave,CursorHold,CursorHoldI *
     \ sil! if w:paren_hl_on | 3match none | endif
endif
