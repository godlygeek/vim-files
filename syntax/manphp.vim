" Vim syntax file
"  Language:	Man page syntax for php
"  Maintainer:	Charles E. Campbell, Jr.
"  Last Change:	Dec 29, 2005
"  Version:    	1
syn clear

let b:current_syntax = "manphp"

syn keyword manphpKey			Description Returns
syn match   manphpFunction			"\<\S\+\ze\s*--"	skipwhite nextgroup=manphpDelimiter
syn match   manphpSkip				"^\s\+\*\s*\S\+\s*"
syn match   manphpSeeAlso			"\<See also\>"		skipwhite skipnl nextgroup=manphpSeeAlsoList
syn match   manphpSeeAlsoSep	contained	",\%( and\)\="		skipwhite skipnl nextgroup=manphpSeeAlsoList,manphpSeeAlsoSkip
syn match   manphpSeeAlsoList	contained	"\s*\zs[^,]\+\ze\%(,\%( and \)\=\)"	skipwhite skipnl nextgroup=manphpSeeAlsoSep
syn match   manphpSeeAlsoList	contained  	"\s*\zs[^,.]\+\ze\."
syn match   manphpSeeAlsoSkip	contained	"^\s\+\*\s*\S\+\s*"     skipwhite skipnl nextgroup=manphpSeeAlsoList
syn match   manphpDelimiter	contained	"\s\zs--\ze\s"		skipwhite nextgroup=manphpDesc
syn match   manphpDesc		contained	".*$"
syn match   manphpUserNote			"User Contributed Notes"
syn match   manphpEditor			"\[Editor's Note:.\{-}]"
syn match   manphpUser				"\a\+ at \a\+ dot .*$"
syn match   manphpFuncList			"PHP Function List"

hi link manphpKey		Title
hi link manphpFunction		Function
hi link manphpDelimiter		Delimiter
hi link manphpDesc		manphpFunction
hi link manphpSeeAlso		Title
hi link manphpSeeAlsoList	PreProc
hi link manphpUserNote		Title
hi link manphpEditor		Special
hi link manphpUser		Search
hi link manphpSeeAlsoSkip	Ignore
hi link manphpSkip		Ignore
hi link manphpFuncList		Title

" cleanup
if !exists("g:manphp_nocleanup")
 set mod ma noro
 %s/\[\d\+]//ge
 %s/_\{2,}/__/ge
 %s/\<\%(add a note\)\+\>//ge
 1
 if search('(PHP','W')
  norm! k
  1,.d
 endif
 if search('\<References\>','W')
  /\<References\>/,$d
 endif
 if search('\<Description\>','w')
  exe '%s/^.*\%'.virtcol(".").'v//e'
  g/^\s\s\*\s/s/^.*$//
 endif
 %s/^\s*\(User Contributed Notes\)/\1/e
 %s/^\s*\(Returns\|See also\)\>/\1/e
 $
 if search('\S','bW')
  norm! j
  if line(".") != line("$")
   silent! .,$d
  endif
 endif
 if search('PHP Function List')
  if line(".") != 1
   1,.-1d
  endif
 endif
 set nomod noma ro
endif

" vim:ts=8
