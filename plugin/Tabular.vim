" Tabular:     Align columnar data using regex-designated column boundaries
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        Thu, 11 Oct 2007 00:35:34 -0400
" Version:     0.1

" Abort if running in vi-compatible mode or the user doesn't want us.
if &cp || exists('g:tabular_loaded')
  if &cp && &verbose
    echo "Not loading Tabular in compatible mode."
  endif
  finish
endif

let g:tabular_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" Function definitions                                                    {{{1

" General tabularizing functions                                          {{{2

function! s:PadLeft(string, fieldwidth)
  return repeat(" ", a:fieldwidth - strlen(a:string)) . a:string
endfunction

function! s:PadRight(string, fieldwidth)
  return a:string . repeat(" ", a:fieldwidth - strlen(a:string))
endfunction

" Currently unused.
function! s:PadBoth(string, fieldwidth)
  let spaces = fieldwidth - strlen(string)
  let right = spaces / 2
  let left = right + (right * 2 != spaces)
  return repeat(" ", left) . a:string . repeat(" ", right)
endfunction

" Utility functions                                                       {{{2

" Takes an array of strings and an array of numbers.  If the length of
" strings[i] is greater than the value at numbers[i], assigns the length of
" strings[i] to numbers[i].
function! s:UpdateLongest(numbers, strings)
  while len(a:numbers) < len(a:strings)
    call add(a:numbers, 0)
  endwhile

  for i in range(len(a:strings))
    if len(a:strings[i]) > a:numbers[i]
      let a:numbers[i] = len(a:strings[i])
    endif
  endfor
endfunction

" Like split(), but store the delims rather than the text between them.
function! s:RevSplit(string, delim)
  let rv1 = []
  let rv2 = []
  let idx = 0
  while 1
    let x = matchlist(a:string, a:delim, idx)
    if x == []
      break
    endif

    let idx = match(a:string, a:delim, idx) + strlen(x[0])
    "echo 'idx=' . idx
    "echo 'mtchlst:'
    "echo x

    if x[1] == "" && x[2] == ""
      let rv1 += [ "" ]
      let rv2 += [ x[0] ]
    else
      let rv1 += [ x[1] ]
      let rv2 += [ x[2] ]
    endif
  endwhile
  "echo 'rv1:'
  "echo rv1
  "echo 'rv2:'
  "echo rv2
  return [ rv1, rv2 ]
endfunction

" Handle us some tabularizing and padding on a delimiter                  {{{2

function! Tabular(delim, d_left_extra, d_right_extra) range
  let longest   = []
  let longestd1 = []
  let longestd2 = []
  let splits    = []
  let delims1   = []
  let delims2   = []

  let beg = a:firstline
  let end = a:lastline

  if beg == end
    if getline(beg) !~ a:delim
      return
    endif
    while getline(beg-1) =~ a:delim
      let beg -= 1
    endwhile
    while getline(end+1) =~ a:delim
      let end += 1
    endwhile
  endif
  "echohl error
  "echo "beg=" . beg . " end=" . end
  "echohl none

  if beg == end
    return
  endif

  let oldlz = (&lz ? "lz" : "nolz")
  set lz

  for i in range(beg, end)
    if getline(i) !~ a:delim
      call add(splits,  [])
      call add(delims1, [])
      call add(delims2, [])
      let i = i + 1
      continue
    endif
    let splitline = split(getline(i), a:delim, 1)
    let splitdelim = s:RevSplit(getline(i), a:delim)

    call s:UpdateLongest(longest,  splitline)
    call s:UpdateLongest(longestd1, splitdelim[0])
    call s:UpdateLongest(longestd2, splitdelim[1])
    call add(splits, splitline)
    call add(delims1, splitdelim[0])
    call add(delims2, splitdelim[1])
  endfor

  for i in range(len(splits))
    if splits[i] == []
      continue
    endif

    let line = ""
    for j in range(len(splits[i]))
      let fl = longest[j]
      if j < len(splits[i]) - 1
        let line .= s:PadRight(splits[i][j], longest[j])

        let line .= s:PadLeft(delims1[i][j], longestd1[j] + a:d_left_extra)
        let line .= s:PadRight(delims2[i][j], longestd2[j] + a:d_right_extra)
      else
        let line .= splits[i][j]
      endif
    endfor
    call setline(beg + i, line)
  endfor

  exe "set " . oldlz

  "echo beg
  "echo end
  "echo splits
  "echo longestd1
  "echo delims1
  "echo longestd2
  "echo delims2
endfunction

" Mappings for tabularizing                                               {{{1

let s:equals_match_expr = '\%([!<>=]\)\@<!\s*\([+-/*.]\?\)\(=\)\s*\%([=~]\)\@!'

exe "nnoremap <silent> <leader>t= :call Tabular(\'" . s:equals_match_expr . "\', 1, 1)<CR>"
nnoremap <silent> <leader>t<space> :call Tabular('  ', 0, 0)<CR>
nnoremap <silent> <leader>ts :call Tabular('\(  \)\s*', 0, 0)<CR>

" Handling of AutoAlign while typing                                      {{{1

if 0
if &bs " We require backspacing (<C-u>) to delete BOL for our AutoAlign maps.
       " Couldn't find a way around it.

  let s:one_equals = '^[^=]*=[^=]*$'

  function! s:AutoAlignEquals()
    " Don't do this in a plain text file..
    " We should really handle the mapping dynamically with autocmds.
    if &ft == ""
      return
    endif

    call Tabular(s:equals_match_expr, 1, 1)
  endfunction

  " For this to work, backspacing must be allowed to move over BOL
  function! s:AutoAlignAfterCarriageReturn()
    if synIDattr(synIDtrans(synID(197,66,1)), "name") == "Comment"
      return ""
    endif

    let SID  = matchstr(expand('<sfile>'), '<SNR>\d\+_\zeAutoAlignAfterCarriageReturn$')
    let line = line('.')

    return "\<up>\<C-r>=" . SID . "AutoAlignEquals()\<CR>\<BS>\<down>\<C-u>"
       \ . "\<C-r>=line('.') == " . line . " ? " . '"\<C-u>"' . " : ''\<CR>"
       \ . "\<C-r>=line('.') == " . line . " ? " . '"\<C-u>"' . " : ''\<CR>\<CR>"
  endfunction

  " Can't be an inoremap or abbreviation expansion on <CR> fails
  imap <silent> <CR> <CR><plug>AutoAlignAfterCarriageReturn

  " Has to be a separate map because it needs <expr>
  inoremap <silent> <expr> <plug>AutoAlignAfterCarriageReturn <SID>AutoAlignAfterCarriageReturn()

endif
endif

" End AutoAlign                                                            }}}

let &cpo = s:savecpo
unlet s:savecpo

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

" vim:set sw=2 sts=2 fdm=marker:
