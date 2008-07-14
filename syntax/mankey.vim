" Vim syntax file
"  Language:	Man keywords page
"  Maintainer:	Charles E. Campbell, Jr.
"  Last Change:	Sep 26, 2005
"  Version:    	1
"    (used by plugin/manpageview.vim)
"
"  History:
"    1:	The Beginning
" ---------------------------------------------------------------------
"  Initialization:
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif
syn clear

" ---------------------------------------------------------------------
"  Highlighting Groups: matches, ranges, and keywords
syn match mankeyTopic	'^\S\+'		skipwhite nextgroup=mankeyType,mankeyBook
syn match mankeyType	'\[\S\+\]'	contained skipwhite nextgroup=mankeySep,mankeyBook contains=mankeyTypeDelim
syn match mankeyTypeDelim	'[[\]]'	contained
syn region mankeyBook	matchgroup=Delimiter start='(' end=')'	contained skipwhite nextgroup=mankeySep
syn match mankeySep		'\s\+-\s\+'	

" ---------------------------------------------------------------------
"  Highlighting Colorizing Links:
if version >= 508 || !exists("did_mankey_syn_inits")
 if version < 508
  let did_mankey_syn_inits = 1
  command! -nargs=+ HiLink hi link <args>
 else
  command! -nargs=+ HiLink hi def link <args>
 endif

 HiLink mankeyTopic		Statement
 HiLink mankeyType		Type
 HiLink mankeyBook		Special
 HiLink mankeyTypeDelim	Delimiter
 HiLink mankeySep		Delimiter

 delc HiLink
endif
let b:current_syntax = "mankey"
