" IndentSort:  Allows for sorting a visual selection on indent level.
" Author:      Matthew Wozniski (mjw@drexel.edu)
" Usage:       Provides one new command, :IndentSort, which operates on a
"              range.  It finds all items with the smallest indent level, and
"              sorts them, carrying along the lines below with larger indents

" Copyright (c) 2007, Matthew J. Wozniski
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

function! s:CompareLines(l1, l2)
  return a:l1[0] == a:l2[0] ? 0 : a:l1[0] > a:l2[0] ? 1 : -1
endfunction

function! s:IndentSort() range
  let savelz = &lz
  let &lz = 1

  let beg = a:firstline
  let end = a:lastline

  let lines = [ [ "", [] ] ]

  for i in range(beg, end)
    let num=matchend(getline(i), " *")
    if !exists("smallest") || num < smallest
      let smallest = num
    endif
  endfor

  for i in range(beg, end)
    if matchend(getline(i), " *") == smallest
      let lines = lines + [ [ getline(i), [] ] ]
      if len(lines) == 2
        let beg = i
      endif
    else
      call add(lines[-1][1], getline(i))
    endif
  endfor

  let lines = lines[1:]
  call sort(lines, "s:CompareLines")
  " echoerr string(lines)
  
  let i = beg
  for line in lines
    call setline(i, line[0])
    let i = i + 1
    for more in line[1]
      call setline(i, more)
      let i = i + 1
    endfor
  endfor

  let &lz = savelz
endfunction

command! -nargs=0 -range -bar IndentSort :<line1>,<line2>call <SID>IndentSort()
