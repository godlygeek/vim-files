" GetLatestVimScripts: 2028 1 :AUTOINSTALL: MarkLines

" MarkLines:  Allows you to toggle highlighting on any number of lines
"             in any number of windows.
" Author:     Matthew Wozniski (mjw@drexel.edu)
" Date:       September 25, 2007
" Version:    1.0
" History:    see :help marklines-history
" License:    BSD.  Completely open source, but I would like to be
"             credited if you use some of this code elsewhere.

" Copyright (c) 2007, Matthew J. Wozniski                                {{{1
" All rights reserved.
" 
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"     * Redistributions of source code must retain the above copyright
"       notice, this list of conditions and the following disclaimer.
"     * Redistributions in binary form must reproduce the above copyright
"       notice, this list of conditions and the following disclaimer in the
"       documentation and/or other materials provided with the distribution.
"     * The names of the contributors may not be used to endorse or promote
"       products derived from this software without specific prior written
"       permission.
" 
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY
" EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
" WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
" DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
" (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
" LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
" ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
" (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
" SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

" Abort if running in vi-compatible mode or the user doesn't want us.    {{{1
if &cp || exists('g:marklines_loaded')
  if &cp && &verbose
    echo "Not loading MarkLines in compatible mode."
  endif
  finish
endif

let g:marklines_loaded = 1

" Choose an operating mode.                                              {{{1
" Normally, we will prefer to use matchadd(), then :2match, then :match, but
" the user may choose to override and choose himself.  Realistically, the user
" should never need to touch this.  matchadd() is indisputably better than the
" others, and I can see no reason why you would ever not want to use it if you
" had it.  However, it might be useful to force us to use :match instead of
" :2match if another plugin is already using :2match.
if ! exists('g:marklines_mode') || g:marklines_mode < 1 || g:marklines_mode > 3
  if exists('*matchadd')
    let g:marklines_mode=3
  elseif exists(':2match')
    let g:marklines_mode=2
  else
    let g:marklines_mode=1
  endif
  if &verbose
    echo "MarkLines will be operating in mode " . g:marklines_mode
  endif
endif

" Define a pair of AddMatch and ClearMatches functions for this mode.    {{{1
" AddMatch adds a new highlight for a window.
" ClearMatches clears all added highlights for a window.
if g:marklines_mode == 3
  " We're using matchadd, so we can create an arbitrary number of different
  " matches in each window, each containing an arbitrary number of lines and
  " each with its own highlight group.  As a result, we need to store a
  " window-local list of match numbers updated by AddMatch, and clear all of
  " those matches for ClearMatches.
  function! s:AddMatch(higrp, linestring)
    let id = matchadd(a:higrp, a:linestring)
    if(id == -1)   " Failed to add the new match.
      return 1     " Alert the caller
    endif
    call add(w:matchnrs, id)
  endfunction

  function! s:ClearMatches()
    if exists('w:matchnrs')
      for match in w:matchnrs
        call matchdelete(match)
      endfor
    endif
    let w:matchnrs = []
  endfunction
elseif g:marklines_mode == 2
  " Only one match at a time.  Just turn it off for ClearMatches
  function! s:AddMatch(higrp, linestring)
    exe '2match ' . a:higrp . ' /' . a:linestring . '/'
    return matcharg(2) == ['','']   " Failed to add the match
  endfunction

  function! s:ClearMatches()
    2match none
  endfunction
else
  " Only one match at a time.  Just turn it off for ClearMatches
  function! s:AddMatch(higrp, linestring)
    exe 'match '  . a:higrp . ' /' . a:linestring . '/'
    return matcharg(1) == ['','']   " Failed to add the match
  endfunction

  function! s:ClearMatches()
    match none
  endfunction
endif

" Define 's:RefreshWindow' for updating the current window's highlight.  {{{1
" Switch to lazy window repainting, clear the existing highlighting, add the
" new highlighting, and change the window repainting method back.
function! s:RefreshWindow()
  let savelz = (&lz ? 'lz' : 'nolz')
  set lz
  call s:ClearMatches()
  call s:UpdateMarkedLines()
  exe 'set ' . savelz
endfunction

" Define 's:RefreshAllWindows' for refreshing every window on a tab.     {{{1
" Restore the current window afterwards.
function! s:RefreshAllWindows()
  let currwin = winnr()
  windo call s:RefreshWindow()
  exe currwin . "wincmd w"
endfunction


" Define 's:UpdateMarkedLines' to call AddMatch once per highlight.      {{{1
" If there are lines to be marked, then mark each of them.  Remove the
" highlight group from the marked lines if adding the match failed, to prevent
" the same error from occurring every time we redraw.
function! s:UpdateMarkedLines()
  if exists('b:match_strings') && len(b:match_strings) != 0
    for key in keys(b:match_strings)
      if strlen(b:match_strings[key])
        let rv = s:AddMatch(key, b:match_strings[key])
        if rv == 1
          let b:marked_lines[key] = []
          let b:match_strings[key] = ""
        endif
      endif
    endfor
  endif
endfunction

" Define 's:SetMarked' to mark or unmark the current line or range.      {{{1
" Chooses a highlight group: either the arg passed in, or the value of
" g:marklines_highlight, or 'MarkedLine', in that order.  If the mode argument
" is zero, unmarks all lines in the range, with the side effect of modifying
" the current highlight color if VIM doesn't support matchadd.  If the mode
" argument is 1, marks all lines in the range.  Otherwise, toggles: If all
" chosen lines are already marked with the chosen highlight group, then unmark
" them all.  Otherwise, mark them all with that highlight group.  Then,
" refresh all windows on this tab, in case the current buffer is shown in
" multiple windows.
function! s:SetMarked(mode, ...) range
  " Choose a highlight color
  if a:0 == 0 && exists('g:marklines_highlight')
    let key = g:marklines_highlight
  elseif a:0 == 0
    let key = 'MarkedLine'
    call s:EnsureMarkedLineHighlight()
  else
    let key = join(a:000, ' ')
  endif

  " Initialize dictionary
  if ! exists('b:marked_lines')
    let b:marked_lines = {}
  endif

  " Initialize array at this key
  if ! exists('b:marked_lines[key]')
    let b:marked_lines[key] = []
  endif

  " Decide if we're turning these lines on or off.
  if a:mode == 1
    let turningoff = 0
  elseif a:mode == 0
    let turningoff = 1
  else
    " If they're all on with this highlight group, off, else on.
    let turningoff=1
    for i in range(a:firstline, a:lastline)
      if index(b:marked_lines[key], i) == -1
        let turningoff=0
        break
      endif
    endfor
  endif

  " Remove these lines from other highlight groups.
  " Then add them to this highlight group unless we're toggling this area off.
  for i in range(a:firstline, a:lastline)
    for k in keys(b:marked_lines)
      if a:mode != 0 || (a:0 == 0 || k == key)
        call filter(b:marked_lines[k], 'v:val != i')
      endif
      if k != key && g:marklines_mode != 3 && !turningoff
        " This is the wrong key, and we can only have one key. Move the vals.
        let b:marked_lines[key] += b:marked_lines[k]
        unlet b:marked_lines[k]
      endif
    endfor

    if !turningoff && i >= 1 && i <= line("$")
      call add(b:marked_lines[key], i)
    endif
  endfor

  " A bit of cleanup: remove empty keys from the dictionary
  call filter(b:marked_lines, 'v:val != []')

  " Create strings suitable as an argument to matchadd from the match numbers
  let b:match_strings = s:GenerateMatchStrings(b:marked_lines)

  " Refresh all windows on this tab page
  call s:RefreshAllWindows()
endfunction

" Define 's:GenerateMatchStrings' to get a matchadd arg from line nums.  {{{1
" The returned dictionary has the same keys as the arg passed in, and the
" values are simply converted from arrays of integers to strings of multi-line
" matches suitable for matchadd().
function! s:GenerateMatchStrings(dict)
  let rv = {}
  if len(a:dict)
    for key in keys(a:dict)
      if len(a:dict[key])
        let rv[key] = '\%' . join(a:dict[key], 'l\|\%') . 'l'
      endif
    endfor
  endif
  return rv
endfunction

" A function to setup the MarkedLine highlight unless already defined.   {{{1
function s:EnsureMarkedLineHighlight()
  if hlID('MarkedLine') == 0 ||
        \ synIDattr(synIDtrans(hlID("MarkedLine")), "bg") == "" &&
        \ synIDattr(synIDtrans(hlID("MarkedLine")), "fg") == "" &&
        \ synIDattr(synIDtrans(hlID("MarkedLine")), "bold") == "" &&
        \ synIDattr(synIDtrans(hlID("MarkedLine")), "italic") == "" &&
        \ synIDattr(synIDtrans(hlID("MarkedLine")), "reverse") == "" &&
        \ synIDattr(synIDtrans(hlID("MarkedLine")), "inverse") == "" &&
        \ synIDattr(synIDtrans(hlID("MarkedLine")), "underline") == ""
    if &bg == 'dark' && &t_Co == 256
      highlight MarkedLine ctermbg=237 guibg=#3a3a3a
    elseif &bg == 'dark'
      highlight MarkedLine ctermbg=8 guibg=#3a3a3a
    elseif &t_Co == 256
      highlight MarkedLine ctermbg=248 guibg=#a8a8a8
    else
      highlight MarkedLine ctermbg=7 guibg=#a8a8a8
    endif
  endif
endfunction

" Define autocommands to refresh windows based on user interaction.      {{{1
" Refresh all windows when switching tab pages.
" Refresh the current window when changing the buffer inside it.
if ! exists('s:autocmds_loaded')
  autocmd BufWinEnter * call <SID>RefreshWindow()
  autocmd TabEnter    * call <SID>RefreshAllWindows()
  let s:autocmds_loaded = 1
endif

" Define ':MarkLinesOn' for unconditionally marking a range.             {{{1
" :MarkLinesOn takes 0 or 1 arg; the optional arg to SetMarked.
" It takes a range, and defaults to the current line if one is not provided.
" It can be followed by another command, and tab-completes highlight groups.
command! -nargs=? -range -bar -complete=highlight MarkLinesOn :<line1>,<line2>call <SID>SetMarked(1, <f-args>)

" Define ':MarkLinesOff' for unconditionally unmarking a range.          {{{1
" :MarkLinesOff takes 0 or 1 arg; the optional arg to SetMarked.
" It takes a range, and defaults to the current line if one is not provided.
" It can be followed by another command, and tab-completes highlight groups.
command! -nargs=? -range -bar -complete=highlight MarkLinesOff :<line1>,<line2>call <SID>SetMarked(0, <f-args>)

" Define ':MarkLinesToggle' for conditionally marking a range.           {{{1
" :MarkLinesToggle takes 0 or 1 arg; the optional highlight group to SetMarked.
" It takes a range, and defaults to the current line if one is not provided.
" It can be followed by another command, and tab-completes highlight groups.
" If all lines in the range are already marked with the chosen highlight
" group, turn unmark them all, else mark them all.
command! -nargs=? -range -bar -complete=highlight MarkLinesToggle :<line1>,<line2>call <SID>SetMarked(2, <f-args>)

" Define functions for MarkLinesOn, MarkLinesOff, and MarkLinesToggle    {{{1
" These wrappers just let us easily call those commands in an expression.
function! MarkLinesOn() range
  exe a:firstline.",".a:lastline."MarkLinesOn"
endfunction

function! MarkLinesOff() range
  exe a:firstline.",".a:lastline."MarkLinesOff"
endfunction

function! MarkLinesToggle() range
  exe a:firstline.",".a:lastline."MarkLinesToggle"
endfunction

" Return a list of the lines in the current buffer that are Marked.      {{{1
" If the optional argument is supplied, it is expected to be a List, and is
" used as a filter - Only lines Marked with a matching highlight group are
" returned.  For convenience, if the optional argument is a String rather than
" a List, we treat it as a list with a single element.
function! MarkLinesList(...)
  if a:0 != 0
    let filter = a:000
    if a:0 == 1 && type(filter[0]) == type([])
      let filter = filter[0]
    endif
  endif
  let rv = []
  for [key, val] in items(b:marked_lines)
    if !exists("filter") || index(filter, key) != -1
      let rv += val
    endif
  endfor
  return sort(rv)
endfunction

" Define convenience maps.                                               {{{1
if ! exists('g:marklines_noautomap') && ! exists('g:marklines_didmap')
  let g:marklines_didmap = 1
  nmap <silent> <unique> <leader>mc :MarkLinesOff<CR>
  nmap <silent> <unique> <leader>ms :MarkLinesOn<CR>
  nmap <silent> <unique> <leader>mt :MarkLinesToggle<CR>
  nmap <silent> <unique> <leader>me :MarkLinesToggle ErrorMsg<CR>
  vmap <silent> <unique> <leader>mc :MarkLinesOff<CR>
  vmap <silent> <unique> <leader>ms :MarkLinesOn<CR>
  vmap <silent> <unique> <leader>mt :MarkLinesToggle<CR>
  vmap <silent> <unique> <leader>me :MarkLinesToggle ErrorMsg<CR>
endif
