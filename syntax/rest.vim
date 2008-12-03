" Vim syntax file
" Language: reStructuredText Documentation Format
" Maintainer: Estienne Swart
" URL: http://www.sanbi.ac.za/~estienne/vim/syntax/rest.vim
" Latest Revision: 2004-04-26
"
" A reStructuredText syntax highlighting mode for vim.
" (derived somewhat from Nikolai Weibull's source)

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

" A little encapsulation, so the syn commands below still get proper vim
" syntax highlighting, and don't need manual string escaping...
command -nargs=+ -buffer RestSynCmd :exe <q-args> . " " . s:python_contains

"syn match rstJunk "\\_"

"ReStructuredText Text Inline Markup:
RestSynCmd syn region rstEmphasis start=+\\\@<!\*\%(\_s\|\*\)\@!+ end=+\%(\_s\|\*\)\@<!\*+
RestSynCmd syn region rstEmphasis start=+\\\@<!\*\%(\_s\|\*\)\@!+ end=+\%(\_s\|\*\)\@<!\*+
RestSynCmd syn region rstStrongEmphasis start=+\\\@<!\*\*\%(\_s\|\*\)\@!+ end=+\%(\_s\|\*\)\@<!\*\*+
RestSynCmd syn region rstInterpretedText start=+`[^`]+ end=+`+ contains=rstURL
RestSynCmd syn region rstInlineLiteral start="``" end="``" contains=rstURL
"Using a syn region here causes too much to be highlighted.

RestSynCmd syn region rstSubstitutionReference start=+|\w+ end=+\w|+ skip=+\\|+
"I'm forcing matching of word characters before and after '|' in order to
"prevent table matching (this causes messy highlighting)

RestSynCmd syn region rstGridTable start=/\n\n\s*+\([-=]\|+\)\+/ms=s+2 end=/+\([-=]\|+\)\+\n\s*\n/me=e-2

RestSynCmd syn match rstRuler "\(=\|-\|+\)\{3,120}"

RestSynCmd " syn match rstInlineInternalTarget "_`\_.\{-}`"
RestSynCmd syn region rstInlineInternalHyperlink start=+_`+ end=+`+ contains=rsturl
" this messes up with InterpretedText

RestSynCmd syn match rstFootnoteReference "\[\%([#*]\|[0-9]\+\|#[a-zA-Z0-9_.-]\+\)\]_"
RestSynCmd "syn region rstCitationReference start=+\[+ end=+\]_+
RestSynCmd "syn match rstCitationReferenceNothing +\[.*\]+
"TODO: fix Citation reference - patterns defined still cause "bleeding"
"if end doesn't get matched, catch it first with another pattern - this is ugly???
RestSynCmd syn match rstURL "\(acap\|cid\|data\|dav\|fax\|file\|ftp\|gopher\|http\|https\|imap\|ldap\|mailto\|mid\|modem\|news\|nfs\|nntp\|pop\|prospero\|rtsp\|service\|sip\|tel\|telnet\|tip\|urn\|vemmi\|wais\):[-./[:alnum:]_~@]\+"
"I need a better regexp for URLs here. This doesn't cater for URLs that are
"broken across lines

" hyperlinks
RestSynCmd syn match rstHyperlinks /`\_[^`]\+`_/
"syn region rstHyperlinks start="`\w" end="`_"
RestSynCmd syn match rstExternalHyperlinks "\w\+_\w\@!"
"This seems to overlap with the ReStructuredText comment?!?

"ReStructuredText Sections:

let s:printable_nonalnums = '[^\x00-\x20\x80-\xffA-Za-z0-9 ]'
for i in range(1, (&tw == 0 ? 80 : &tw))
    exe 'syn match rstTitle "^\(' . s:printable_nonalnums . '\)\(\1\{' . (i-1) . '}\)\n.\{1,' . i . '}\n\1\2\n"'
    exe 'syn match rstTitle "^.\{' . i . '}\n\(' . s:printable_nonalnums . '\)\1\{' . (i-1) . ',}\n"'
endfor

"ReStructuredText Lists:
RestSynCmd syn match rstEnumeratedList "^\s*\%(\d\+\|[a-zA-Z#]\)[.)]\s"
RestSynCmd syn match rstEnumeratedList "^\s*(\%(\d\+\|[a-zA-Z#]\))\s"

RestSynCmd syn match rstBulletedList "^\s*[\u2023\u2022\u2043*+-]\s"

" This may have been going a bit overboard, but... the advantage of having
" a DefinitionList syntax group over just a toplevel DefinitionItem group is
" that folding an entire list becomes possible.  Similarly, DefinitionItem
" makes it possible to fold a single definition - which may or may not be
" useful...  The other groups make highlighting of a particular attribute
" easier.

" FIXME Too slow... rethink this.
"syntax cluster rstDefinitionLists contains=rstDefinitionList,rstDefinitionItem,rstDefinitionTerm,rstDefinitionClassifierDelim,rstDefinitionClassifier,rstDefinition
"RestSynCmd syn region rstDefinitionList start="\%(^\n\)\@<=\zs\z(\(\s*\)\)\%(\%(\s:\s\)\@!.\)\+\%(\s:\s\%(\%(\s:\s\)\@!.\)\)*\n\1\s\+\S"
"                                      \ end="^\s\@=\z1\@!"
"                                      \ end="\ze\%(\%(\_^\s*\n\)\+\)\@>.*\%([^ \t]:\|:[^ \t]\)"
"                                      \ end="\ze\%(\%(\_^\s*\n\)\+\)\@>.*\n\%(\z1\)\@!"
"                                      \ fold keepend contains=rstDefinitionItem
"RestSynCmd syn region rstDefinitionItem start="^\ze\z(\s*\)" end="^\ze\z1\s\@!" contains=rstDefinitionTerm contained fold
"RestSynCmd syn match rstDefinitionTerm ".\{-1,}\ze\%(\s:\s\|$\)" contains=ALLBUT,@rstDefinitionLists nextgroup=rstDefinitionClassifierDelim,rstDefinition skipnl contained
"RestSynCmd syn region rstDefinition start="\z(\s*\)\S" skip="^\s*$" end="^\ze\z1\@!" contains=ALLBUT,@rstDefinitionLists contained transparent
"RestSynCmd syn match rstDefinitionClassifierDelim "\s:\s" nextgroup=rstDefinitionClassifier contained
"RestSynCmd syn match rstDefinitionClassifier ".\{-1,}\ze\%( : \|$\)" nextgroup=rstDefinitionClassifierDelim,rstDefinition skipnl contained

RestSynCmd syn match rstFieldList ":[^:]\+:\s"me=e-1 contains=rstBibliographicField
RestSynCmd "still need to add rstDefinitionList  rstOptionList

"ReStructuredText Preformatting:
RestSynCmd syn match rstLiteralBlock "::\s*\n" contains=rstGridTable
RestSynCmd "syn region rstLiteralBlock start=+\(contents\)\@<!::\n+ end=+[^:]\{2}\s*\n\s*\n\s*+me=e-1 contains=rstEmphasis,rstStrongEmphasis,rstInlineLiteral,rstRuler,rstFieldList,rstInlineInternalTargets,rstGridTable transparent
"Add more to allbut?
"This command currently ignores the 'contents::' line that is found in some
"restructured documents.
RestSynCmd "syn region rstBlockQuote start=+\s\n+ end=+[^:]\{2}\s*\n\s*\n\s*+me=e-1 contains=ALLBUT,rstEmphasis,rstStrongEmphasis,rstInlineLiteral,rstRuler
"FIX rstBlockQuote

"syn match rstDocTestBlock
"
"
"RestructureText Targets:
RestSynCmd syn match rstFootnoteTarget "\[\%([#*]\|[0-9]\+\|#[a-zA-Z0-9_.-]\+\)\]" contained
RestSynCmd syn region rstCitationTarget start=+\[+ end=+\]+ contained
"syn region rstInlineInternalTarget start=+_\_s\@!+ end=+\:+ contained
"seems to match things in reagions it should not
RestSynCmd syn match rstDirective +\.\.\s\{-}[^_]\{-}\:\:+ms=s+3 contained

"ReStructuredText Comments:
RestSynCmd syn region rstComment matchgroup=rstComment start="^\s*\.\{2} " end="^\s\@!" contains=rstFootnoteTarget,rstCitationTarget,rstInlineInternalTarget,rstDirective,rstURL
"THIS NEEDS TO BE FIXED TO HANDLE COMMENTS WITH PARAGRAPHS
"It can be modelled on rstBlock (which also needs to be worked)
"It also matches too much :-( e.g. normal ellipsis
"Define fold group for comments?

"ReStructuredText Miscellaneous:

RestSynCmd syn keyword rstBibliographicField contained Author Organization Contact Address Version Status Date Copyright Dedication Abstract Authors
"keyword revison too??? Lower case variants too?

" todo
RestSynCmd syn keyword rstTodo contained FIXME TODO XXX

RestSynCmd syn region rstQuotes start=+\"+ end=+\"+ skip=+\\"+ contains=ALLBUT,@rstDefinitionLists,rstEmphasis,rstStrongEmphasis,rstBibliographicField,rstQuotes

" footnotes
RestSynCmd "syn region rstFootnote matchgroup=rstDirective start="^\.\.\[\%([#*]\|[0-9]\+\|#[a-z0-9_.-]\+\)\]\s" end="^\s\@!" contains=@rstCruft

" citations
RestSynCmd "syn region rstCitation matchgroup=rstDirective start="^\.\.\[[a-z0-9_.-]\+\]\s" end="^\s\@!" contains=@rstCruft

RestSynCmd syn region rstBlock start="::\%(\s*\n\)\{2,}\z(\s\+\)" skip="^$" end="^\z1\@!" fold
"almost perfect
"Still need to get stop on unident correct. Also need to work on recursive
"blocking for proper folding.
"TODO: Define syntax regions for Sections (defined by titles)

if ! exists("s:python")
  syn sync minlines=50 linebreaks=2
endif

hi def link rstBibliographicField Operator
hi def link rstBlock Type
hi def link rstExternalHyperlinks Underlined
hi def link rstHyperlinks Underlined
hi def link rstTitle Constant
hi def link rstRuler Special
hi def link rstURL Underlined
hi def link rstSubstitutionReference Macro
hi def link rstEmphasis Exception
hi def link rstStrongEmphasis Exception
hi def link rstLiteralBlock Type
hi def link rstBlockQuote Type
hi def link rstEnumeratedList Operator
hi def link rstBulletedList Operator
hi def link rstFieldList Label
hi def link rstTodo Todo
hi def link rstComment Comment
hi def link rstGridTable Delimiter
hi def link rstInlineLiteral Function
hi def link rstInterpretedText Keyword
hi def link rstInlineInternalHyperlink Identifier
hi def link rstInlineInternalTarget Identifier
hi def link rstFootnoteReference Identifier
hi def link rstCitationReference Identifier
hi def link rstFootnoteTarget Identifier
hi def link rstCitationTarget Identifier
hi def link rstDirective Underlined

if exists("s:python")
  unlet s:python
endif

if exists("b:current_syntax") && b:current_syntax != ""
  let b:current_syntax = b:current_syntax . ".rest"
else
  let b:current_syntax = "rest"
endif

delcommand RestSynCmd

" vim: set sts=4 sw=4:
