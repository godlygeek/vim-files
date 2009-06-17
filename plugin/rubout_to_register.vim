" CSApprox:    Store words deleted by <C-U> or <C-W> in a register
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        Wed, 17 Jun 2009 11:18:10 -0400
"
" Long Description:
" Readline stores text deleted by <C-u> or <C-w> in a register, and allows you
" to retrieve it later using <C-y>.  I missed this behavior in vim, so
" implemented it with one small tweak - since <C-y> is already used in Vim, in
" both insert mode and command line mode, I chose to use <C-r><C-y> to insert
" this register instead.  <C-r> is the normal method of inserting a register's
" contents in Vim, anyway.
"
" The deleted text is actually stored in @- so if you'd rather not use
" <C-r><C-y>, you can always just use <C-r>-
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

if exists('g:rubout_to_register_loaded') || &compatible
  finish
endif

let g:rubout_to_register_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" Return the number of bytes in a string after expanding tabs to spaces.
" This expansion is done based on the current value of 'tabstop'
function! s:Strlen(string)
  let rv = 0
  let i = 0

  for char in split(a:string, '\zs')
    if char == "\t"
      let rv += &ts - i
      let i = 0
    else
      let rv += 1
      let i = (i + 1) % &ts
    endif
  endfor

  return rv
endfunction

" Comparator for a pair of integers, intentionally reversing them.
function! s:ReverseIntegerSort(i1, i2)
  return a:i1 == a:i2 ? 0 : a:i1 < a:i2 ? 1 : -1
endfunction

" Set up the b:can_join_deletes variable for a small state machine.
"
" When 0, two deletes cannot be joined.
" When 1, the current delete is allowed to be joined
" When 2, the next delete is allowed to be joined
function! s:PrepareForDelete()
  if !exists("b:can_join_deletes") || b:can_join_deletes != 2
    let b:can_join_deletes = 0
  else
    let b:can_join_deletes = 1
  endif
endfunction

" Store the place where insert mode started, prep the FSM
augroup RuboutToRegister
  au!
  autocmd InsertEnter * let b:last_insert_pos = getpos('.')
  autocmd InsertEnter,CursorMovedI * call s:PrepareForDelete()
augroup END

" Handle <C-w> and <C-u> in insert mode
function! RuboutToRegisterI(retval)
  let col = col('.')
  let line = line('.')

  let stop_positions = [ 1 ]

  "echomsg "Before any return's"

  " Erasing EOL
  if col == 1 && (line == 1 || (&backspace == 0 && &backspace !~ 'eol'))
    " At BOL and can't erase EOL
    return a:retval
  endif

  let stop_positions += [ s:Strlen(matchstr(getline('.'), '^\s*')) + 1 ]

  if col > 1 && col == stop_positions[-1]
    \ && (&backspace == 0 && &backspace !~ 'indent')
    " At indentation and can't delete further
    return a:retval
  endif

  if col > stop_positions[-1] && line == b:last_insert_pos[1]
    let stop_positions += [ b:last_insert_pos[2] ]
    if col == stop_positions[-1] && (&backspace < 2 && &backspace !~ 'start')
      " At start-of-insert and can't delete further.
      return a:retval
    endif
  endif

  let stop_positions = sort(stop_positions, function("s:ReverseIntegerSort"))
  "echomsg "cursor col is " . col . ", stop positions are " . string(stop_positions)

  let stop_pos = -1
  for pos in stop_positions
    if pos < col
      let stop_pos = pos
      break
    endif
  endfor

  "echomsg "Choosing to stop at " . stop_pos

  if stop_pos == -1
    " Erasing EOL
    let delete = "\n"
  else
    let delete = matchstr(getline('.'), printf('\%%%dc.*\%%%dc', stop_pos, col))
    "echomsg "Delete is " . string(delete)
    if a:retval == "\<C-w>"
      let delete = matchstr(delete, '\k*\s*$')
    endif
  endif

  if b:can_join_deletes
    let @- = delete . @-
  else
    let @- = delete
  endif

  let b:can_join_deletes = 2

  "echomsg "Deleted " . string(@-)

  return a:retval
endfunction

" Handle <C-w> and <C-u> in command-line mode
function! RuboutToRegisterC(key)
  let cmdline = getcmdline()
  let col = getcmdpos()
  let type = getcmdtype()
  let histnr = histnr(type)

  if !(exists('s:cmdtype') && s:cmdtype == type
      \ && exists('s:histnr') && s:histnr == histnr
      \ && exists('s:cmdline') && s:cmdline == cmdline
      \ && exists('s:cmdpos') && s:cmdpos == col)
    " Not deleting again after the last delete
    let @- = ''
  endif

  if a:key == "\<C-w>"
    let pattern = '\k*\s*'
  else
    let pattern = '.*'
  endif

  let delete = matchstr(cmdline, pattern . '\%' . col . 'c')

  let cmdline = substitute(cmdline, pattern . '\%' . col . 'c', '', '')

  let @- = delete . @-

  let s:cmdtype = type
  let s:histnr = histnr
  let s:cmdline = cmdline
  let s:cmdpos = col - strlen(delete)

  return a:key
endfunction

inoremap <expr> <C-w> RuboutToRegisterI("\<C-w>")
inoremap <expr> <C-u> RuboutToRegisterI("\<C-u>")
inoremap <C-r><C-y> <C-r>-

cnoremap <expr> <C-w> RuboutToRegisterC("\<C-w>")
cnoremap <expr> <C-u> RuboutToRegisterC("\<C-u>")
cnoremap <C-r><C-y> <C-r>-

let &cpo = s:savecpo
