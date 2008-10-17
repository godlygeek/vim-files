" Tabular:     Align columnar data using regex-designated column boundaries
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        Thu, 11 Oct 2007 00:35:34 -0400
" Version:     0.1

" Abort if running in vi-compatible mode or the user doesn't want us.
if &cp " || exists('g:tabular_loaded')
  if &cp && &verbose
    echo "Not loading Tabular in compatible mode."
  endif
  finish
endif

let g:tabular_loaded = 1

" Stupid vimscript crap                                                   {{{1
let s:savecpo = &cpo
set cpo&vim

" Function definitions                                                    {{{1

" Align a string within a field                                           {{{2
function! s:Right(string, fieldwidth)
  let spaces = a:fieldwidth - strlen(substitute(a:string, '.', 'x', 'g'))
  return repeat(" ", spaces) . a:string
endfunction

function! s:Left(string, fieldwidth)
  let spaces = a:fieldwidth - strlen(substitute(a:string, '.', 'x', 'g'))
  return a:string . repeat(" ", spaces)
endfunction

function! s:Center(string, fieldwidth)
  let spaces = a:fieldwidth - strlen(substitute(a:string, '.', 'x', 'g'))
  let right = spaces / 2
  let left = right + (right * 2 != spaces)
  return repeat(" ", left) . a:string . repeat(" ", right)
endfunction

" Remove spaces around a string                                           {{{2
function! s:StripTrailingSpaces(string)
  return matchstr(a:string, '^.\{-}\ze\s*$')
endfunction

function! s:StripLeadingSpaces(string)
  return matchstr(a:string, '^\s*\zs.*$')
endfunction

" Split a string into fields and delimiters                               {{{2
" Like split(), but include the delimiters as elements
" All odd numbered elements are delimiters
" All even numbered elements are non-delimiters
function! s:SplitDelim(string, delim)
  let pre  = split(a:string, a:delim, 1)
  let post = []

  let last = 0

  while 1
    let idx = match(a:string, a:delim, last)
    if idx == -1
      break
    endif

    let matchlist = matchlist(a:string, a:delim, last)

    let length = strlen(matchlist[0])

    let matchedgroups = join(matchlist[1:-1], '')
    if strlen(matchedgroups)
      let length = strlen(matchedgroups)
    endif

    let post += [ remove(pre, 0) ]
    let post += [ (strlen(matchedgroups) ? matchedgroups : matchlist[0]) ]
    let last = idx + strlen(matchlist[0])
  endwhile

  let post += [ remove(pre, 0) ]

  if (!empty(pre))
    echoerr "Internal error: Some elements not handled!!"
  endif

  return post
endfunction

" Handle us some tabularizing and padding on a delimiter                  {{{2

function! Tabular(delim, ...) range
  let top = a:firstline
  let bot = a:lastline

  let formatpat = '\%([lrc]\d\+\)'

  if a:0 == 1 && type(a:1) == type({}) && has_key(a:1, 'format')
    " Undocumented forwards compatibility!
    let formatstring = a:1['format']
  elseif a:0 == 1 && type(a:1) == type("")
    let formatstring = a:1
  else
    let formatstring = "l0c0"
  endif

  if formatstring !~? formatpat . '\+'
    echoerr "Invalid format specified!"
    return
  endif

  let format = split(formatstring, formatpat . '\zs')

  " If given one line, pick a reasonable range.
  if top == bot
    if getline(top) !~ a:delim
      return
    endif
    while getline(top-1) =~ a:delim
      let top -= 1
    endwhile
    while getline(bot+1) =~ a:delim
      let bot += 1
    endwhile
  endif

  " If we couldn't find a reasonable range, quit.
  if top == bot
    return
  endif

  let lines = map(range(top, bot), 's:SplitDelim(getline(v:val), a:delim)')

  for line in lines
    let line[0] = s:StripTrailingSpaces(line[0])
    if len(line) >= 3
      for i in range(2, len(line)-1, 2)
        let line[i] = s:StripLeadingSpaces(s:StripTrailingSpaces(line[i]))
      endfor
    endif
  endfor

  let maxes = []
  for line in lines
    for i in range(len(line))
      if i == len(maxes)
        let maxes += [ strlen(line[i]) ]
      else
        if maxes[i] <= strlen(line[i])
          let maxes[i] = strlen(line[i])
        endif
      endif
    endfor
  endfor

  let nr = top

  for line in lines
    for i in range(len(line))
      let how = format[i % len(format)][0]
      let pad = format[i % len(format)][1:-1]

      if how =~? 'l'
        let field = s:Left(line[i], maxes[i])
      elseif how =~? 'r'
        let field = s:Right(line[i], maxes[i])
      elseif how =~? 'c'
        let field = s:Center(line[i], maxes[i])
      endif

      let line[i] = field . repeat(" ", pad)
    endfor

    let newline = join(line, '')

    let endidx = -1
    while newline[endidx : endidx] == ' '
      let endidx -= 1
    endwhile

    let newline = newline[0:endidx]

    call setline(nr, newline)
    let nr += 1
  endfor
endfunction

" Mappings for tabularizing                                               {{{1
nnoremap <silent> <leader>t= :call Tabular('[^!<lt>>=%/*+&<bar>-]\zs\%(<lt><lt>=\<bar>>>=\<bar>%=\<bar>\/=\<bar>\*=\<bar>+=\<bar>-=\<bar><bar>=\<bar>&=\<bar>=\)[=~]\@!', 'l1r1')<CR>
nnoremap <silent> <leader>ts :call Tabular('\(  \)\s*', 'l0r0')<CR>
nnoremap <silent> <leader>t<space> :call Tabular('  ', 'l0r0')<CR>

" Stupid vimscript crap, again                                            {{{1
let &cpo = s:savecpo
unlet s:savecpo

" Examples (may be used for regression tests one day?)                    {{{1

" Press  \t<space>  to see this script in action.  Lovely.
" this is  a quick test  of the capabilities of  my new script
" do you like  the  things  it can do?
" i  do  too  :)

" '\ts' is like '\t ' except that it treats two or more spaces as the
" delimiter, not just two.
" it will     format this        into a much nicer    table
" than it was   when               we                 started

" And \t= should be fun here.
" int x=50;
" string abc+='123';
" string test= '145';
" string a *= '1234';
" Though, the line below here == won't be changed
" since we don't count two = in one line.

" Not automatically aligned with \t=, though they contain =
" a <= b
" a >= b
" a =~ b
" a =~? b
" a =~# b
" a != b
" a == b

" Automatically aligned
" a = b
" a &= b
" a |= b
" a -= b
" a += b
" a *= b
" a /= b
" a %= b
" a <<= b
" a >>= b

" vim:set sw=2 sts=2 fdm=marker:
