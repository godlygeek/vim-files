" Vim syntax file
" Language: reStructuredText Documentation Format
" Maintainer: Estienne Swart 
" URL: http://www.sanbi.ac.za/~estienne/vim/syntax/rest.vim
" Latest Revision: 2004-04-26
"
" A reStructuredText syntax highlighting mode for vim.
" (derived somewhat from Nikolai Weibull's <source@p...>
" source)

"TODO:
" 0. Make sure that no syntax highlighting bleeding occurs!
" 1. Need to fix up clusters and contains.
" 2. Need to validate against restructured.txt.gz and tools/test.txt.
" 3. Fixup superfluous matching.
" 4. I need to figure out how to keep a running tally of the indentation in order
" to enable block definitions, i.e. a block ends when its indentation drops
" below that of the existing one.
" 5. Define folding patterns for sections, etc.
" 6. Setup a completion mode for target references to hyperlinks

" Remove any old syntax stuff that was loaded (5.x) or quit when a syntax file
" was already loaded (6.x).
let s:python_contains = ""
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  if b:current_syntax == 'python'
    let s:python_contains = " containedin=pythonString contained"
    let s:python = 1
  else
    finish
  endif
endif

"syn match rstJunk "\\_"

"ReStructuredText Text Inline Markup:
exe 'syn region rstEmphasis start=+\*[^*]+ end=+\*+  ' . s:python_contains
exe 'syn region rstStrongEmphasis start=+\*\*[^*]+ end=+\*\*+  ' . s:python_contains
exe 'syn region rstInterpretedText start=+`[^`]+ end=+`+ contains=rstURL ' . s:python_contains
exe 'syn region rstInlineLiteral start="``" end="``" contains=rstURL ' . s:python_contains
"Using a syn region here causes too much to be highlighted.

exe 'syn region rstSubstitutionReference start=+|\w+ end=+\w|+ skip=+\\|+ ' . s:python_contains
"I'm forcing matching of word characters before and after '|' in order to
"prevent table matching (this causes messy highlighting)

exe 'syn region rstGridTable start=/\n\n\s*+\([-=]\|+\)\+/ms=s+2 end=/+\([-=]\|+\)\+\n\s*\n/me=e-2 ' . s:python_contains

exe 'syn match rstRuler "\(=\|-\|+\)\{3,120}" ' . s:python_contains

exe '" syn match rstInlineInternalTarget "_`\_.\{-}`" ' . s:python_contains
exe 'syn region rstInlineInternalHyperlink start=+_`+ end=+`+ contains=rsturl ' . s:python_contains
" this messes up with InterpretedText

exe 'syn match rstFootnoteReference "\[\%([#*]\|[0-9]\+\|#[a-zA-Z0-9_.-]\+\)\]_" ' . s:python_contains
exe '"syn region rstCitationReference start=+\[+ end=+\]_+ ' . s:python_contains
exe '"syn match rstCitationReferenceNothing +\[.*\]+ ' . s:python_contains
"TODO: fix Citation reference - patterns defined still cause "bleeding"
"if end doesn't get matched, catch it first with another pattern - this is ugly???
exe 'syn match rstURL "\(acap\|cid\|data\|dav\|fax\|file\|ftp\|gopher\|http\|https\|imap\|ldap\|mailto\|mid\|modem\|news\|nfs\|nntp\|pop\|prospero\|rtsp\|service\|sip\|tel\|telnet\|tip\|urn\|vemmi\|wais\):[-./[:alnum:]_~@]\+" ' . s:python_contains
"I need a better regexp for URLs here. This doesn't cater for URLs that are
"broken across lines

" hyperlinks
exe 'syn match rstHyperlinks /`[^`]\+`_/ ' . s:python_contains
"syn region rstHyperlinks start="`\w" end="`_"
exe 'syn match rstExternalHyperlinks "\w\+_\w\@!" ' . s:python_contains
"This seems to overlap with the ReStructuredText comment?!?

"ReStructuredText Sections:
exe 'syn match rstTitle ".\{2,120}\n\(\.\|=\|-\|=\|`\|:\|' . "'" . '\|\"\|\~\|\^\|_\|\*\|+\|#\|<\|>\)\{3,120}" ' . s:python_contains
" [-=`:'"~^_*+#<>]
"for some strange reason this only gets highlighted upon refresh

exe '"syn match rstTitle "\w.*\n\(=\|-\|+\)\{2,120}" ' . s:python_contains

"ReStructuredText Lists:
exe 'syn match rstEnumeratedList "^\s*\d\{1,3}\.\s" ' . s:python_contains

exe 'syn match rstBulletedList "^\s*\([+-]\|\*\)\s" ' . s:python_contains
exe '" syn match rstBulletedList "^\s*[+-]\|\*\s" ' . s:python_contains
"I'm not sure how to include "*" within a range []?!?
" this seems to match more than it should :-(


exe 'syn match rstFieldList ":[^:]\+:\s"me=e-1 contains=rstBibliographicField ' . s:python_contains
exe '"still need to add rstDefinitionList  rstOptionList ' . s:python_contains

"ReStructuredText Preformatting:
exe 'syn match rstLiteralBlock "::\s*\n" contains=rstGridTable ' . s:python_contains
exe '"syn region rstLiteralBlock start=+\(contents\)\@<!::\n+ end=+[^:]\{2}\s*\n\s*\n\s*+me=e-1 contains=rstEmphasis,rstStrongEmphasis,rstInlineLiteral,rstRuler,rstFieldList,rstInlineInternalTargets,rstGridTable transparent ' . s:python_contains
"Add more to allbut?
"This command currently ignores the 'contents::' line that is found in some
"restructured documents.
exe '"syn region rstBlockQuote start=+\s\n+ end=+[^:]\{2}\s*\n\s*\n\s*+me=e-1 contains=ALLBUT,rstEmphasis,rstStrongEmphasis,rstInlineLiteral,rstRuler ' . s:python_contains
"FIX rstBlockQuote

"syn match rstDocTestBlock
"
"
"RestructureText Targets:
exe 'syn match rstFootnoteTarget "\[\%([#*]\|[0-9]\+\|#[a-zA-Z0-9_.-]\+\)\]" contained ' . s:python_contains
exe 'syn region rstCitationTarget start=+\[+ end=+\]+ contained ' . s:python_contains
"syn region rstInlineInternalTarget start=+_\_s\@!+ end=+\:+ contained
exe '"' . s:python_contains
"seems to match things in reagions it should not
exe 'syn match rstDirective +\.\.\s\{-}[^_]\{-}\:\:+ms=s+3 contained ' . s:python_contains

"ReStructuredText Comments:
exe 'syn region rstComment matchgroup=rstComment start="\.\{2} " end="^\s\@!" contains=rstFootnoteTarget,rstCitationTarget,rstInlineInternalTarget,rstDirective,rstURL ' . s:python_contains
"THIS NEEDS TO BE FIXED TO HANDLE COMMENTS WITH PARAGRAPHS
"It can be modelled on rstBlock (which also needs to be worked)
"It also matches too much :-( e.g. normal ellipsis
"Define fold group for comments?

"ReStructuredText Miscellaneous:

exe 'syn keyword rstBibliographicField contained Author Organization Contact Address Version Status Date Copyright Dedication Abstract Authors ' . s:python_contains
"keyword revison too??? Lower case variants too?

" todo
exe 'syn keyword rstTodo contained FIXME TODO XXX ' . s:python_contains

exe 'syn region rstQuotes start=+\"+ end=+\"+ skip=+\\"+ contains=ALLBUT,rstEmphasis,rstStrongEmphasis,rstBibliographicField ' . s:python_contains

" footnotes
exe '"syn region rstFootnote matchgroup=rstDirective start="^\.\.\[\%([#*]\|[0-9]\+\|#[a-z0-9_.-]\+\)\]\s" end="^\s\@!" contains=@rstCruft ' . s:python_contains

" citations
exe '"syn region rstCitation matchgroup=rstDirective start="^\.\.\[[a-z0-9_.-]\+\]\s" end="^\s\@!" contains=@rstCruft ' . s:python_contains

exe 'syn region rstBlock start="::\(\n\s*\)\{-}\z(\s\+\)" skip="^$" end="^\z1\@!" fold contains=ALLBUT,rstInterpretedText,rstFootnoteTarget,rstCitationTarget,rstInlineInternalTarget ' . s:python_contains
"almost perfect
"Still need to get stop on unident correct. Also need to work on recursive
"blocking for proper folding.
"TODO: Define syntax regions for Sections (defined by titles)

if ! exists("s:python")
  syn sync minlines=50
endif

if !exists("did_rst_syn_inits")
    let did_rst_syn_inits = 1
   
    hi link rstBibliographicField Operator
    hi link rstBlock Type
    hi link rstExternalHyperlinks Underlined 
    hi link rstHyperlinks Underlined
    hi link rstTitle Constant
    hi link rstRuler Special
    hi link rstURL Underlined
    hi link rstSubstitutionReference Macro
    hi link rstEmphasis Exception
    hi link rstStrongEmphasis Exception
    hi link rstLiteralBlock Type
    hi link rstBlockQuote Type
    hi link rstEnumeratedList Operator
    hi link rstBulletedList Operator
    hi link rstFieldList Label
    hi link rstTodo Todo
    hi link rstComment Comment
    hi link rstGridTable Delimiter
    hi link rstInlineLiteral Function
    hi link rstInterpretedText Keyword
    hi link rstInlineInternalHyperlink Identifier
    hi link rstInlineInternalTarget Identifier
    hi link rstFootnoteReference Identifier
    hi link rstCitationReference Identifier
    hi link rstFootnoteTarget Identifier
    hi link rstCitationTarget Identifier
    hi link rstDirective Underlined
endif

if exists("s:python")
  unlet s:python
endif

if exists("b:current_syntax") && b:current_syntax != ""
  let b:current_syntax = b:current_syntax . ".rest"
else
  let b:current_syntax = "rest"
endif

" vim: set sts=4 sw=4:
