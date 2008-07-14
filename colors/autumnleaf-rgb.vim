" Vim color file
" Maintainer: Anders Korte
" Last Change: 17 Oct 2004

" AutumnLeaf color scheme 1.0

set background=light

hi clear

if exists("syntax_on")
    syntax reset
endif

let colors_name="autumnleaf-rgb"

" Colors for the User Interface.

hi Cursor	ctermbg=#aa7733 guibg=#aa7733   ctermfg=#ffeebb guifg=#ffeebb   cterm=none gui=bold
hi Normal	ctermbg=#fffdfa guibg=#fffdfa	ctermfg=black guifg=black	cterm=none gui=none
hi NonText	ctermbg=#eafaea guibg=#eafaea   ctermfg=#000099 guifg=#000099   cterm=none gui=bold
hi Visual	ctermbg=#fff8cc guibg=#fff8cc   ctermfg=black guifg=black	cterm=none gui=none
" hi VisualNOS

hi Linenr	ctermbg=bg guibg=bg	ctermfg=#999999 guifg=#999999 cterm=none gui=none

" Uncomment these if you use Diff...??
" hi DiffText	ctermbg=#cc0000 guibg=#cc0000	ctermfg=white guifg=white cterm=none gui=none
" hi DiffAdd	ctermbg=#0000cc guibg=#0000cc	ctermfg=white guifg=white cterm=none gui=none
" hi DiffChange	ctermbg=#990099 guibg=#990099	ctermfg=white guifg=white cterm=none gui=none
" hi DiffDelete	ctermbg=#888888 guibg=#888888	ctermfg=#333333 guifg=#333333 cterm=none gui=none

hi Directory	ctermbg=bg guibg=bg	ctermfg=#337700 guifg=#337700   cterm=none gui=none

hi IncSearch	ctermbg=#c8e8ff guibg=#c8e8ff	ctermfg=black guifg=black	cterm=none gui=none
hi Search	ctermbg=#c8e8ff guibg=#c8e8ff	ctermfg=black guifg=black	cterm=none gui=none
hi SpecialKey	ctermbg=bg guibg=bg	ctermfg=fg guifg=fg    	cterm=none gui=none
hi Titled	ctermbg=bg guibg=bg	ctermfg=fg guifg=fg	cterm=none gui=none

hi ErrorMsg	    ctermbg=bg guibg=bg	ctermfg=#cc0000 guifg=#cc0000   cterm=none gui=bold
hi ModeMsg	    ctermbg=bg guibg=bg	ctermfg=#003399 guifg=#003399   cterm=none gui=none
hi link	MoreMsg	    ModeMsg
hi link Question    ModeMsg
hi WarningMsg	    ctermbg=bg guibg=bg	ctermfg=#cc0000 guifg=#cc0000   cterm=none gui=bold

hi StatusLine	ctermbg=#ffeebb guibg=#ffeebb	ctermfg=black guifg=black	cterm=none gui=bold
hi StatusLineNC	ctermbg=#aa8866 guibg=#aa8866	ctermfg=#f8e8cc guifg=#f8e8cc	cterm=none gui=none
hi VertSplit	ctermbg=#aa8866 guibg=#aa8866	ctermfg=#ffe0bb guifg=#ffe0bb	cterm=none gui=none

" hi Folded
" hi FoldColumn
" hi SignColumn


" Colors for Syntax Highlighting.

hi Comment ctermbg=#ddeedd guibg=#ddeedd ctermfg=#002200 guifg=#002200 cterm=none gui=none

hi Constant	ctermbg=bg guibg=bg    ctermfg=#003399 guifg=#003399 cterm=none gui=bold
hi String	ctermbg=bg guibg=bg    ctermfg=#003399 guifg=#003399 cterm=italic gui=italic
hi Character	ctermbg=bg guibg=bg    ctermfg=#003399 guifg=#003399 cterm=italic gui=italic
hi Number	ctermbg=bg guibg=bg    ctermfg=#003399 guifg=#003399 cterm=none gui=bold
hi Boolean	ctermbg=bg guibg=bg    ctermfg=#003399 guifg=#003399 cterm=none gui=bold
hi Float	ctermbg=bg guibg=bg    ctermfg=#003399 guifg=#003399 cterm=none gui=bold

hi Identifier	ctermbg=bg guibg=bg    ctermfg=#003399 guifg=#003399 cterm=none gui=none
hi Function	ctermbg=bg guibg=bg    ctermfg=#0055aa guifg=#0055aa cterm=none gui=bold
hi Statement	ctermbg=bg guibg=bg    ctermfg=#003399 guifg=#003399 cterm=none gui=none

hi Conditional	ctermbg=bg guibg=bg    ctermfg=#aa7733 guifg=#aa7733 cterm=none gui=bold
hi Repeat	ctermbg=bg guibg=bg    ctermfg=#aa5544 guifg=#aa5544 cterm=none gui=bold
hi link	Label	Conditional
hi Operator	ctermbg=bg guibg=bg    ctermfg=#aa7733 guifg=#aa7733 cterm=none gui=bold
hi link Keyword	Statement
hi Exception	ctermbg=bg guibg=bg    ctermfg=#228877 guifg=#228877 cterm=none gui=bold

hi PreProc	    ctermbg=bg guibg=bg	ctermfg=#aa7733 guifg=#aa7733 cterm=none gui=bold
hi Include	    ctermbg=bg guibg=bg	ctermfg=#558811 guifg=#558811 cterm=none gui=bold
hi link Define	    Include
hi link Macro	    Include
hi link PreCondit   Include

hi Type			ctermbg=bg guibg=bg    ctermfg=#007700 guifg=#007700 cterm=none gui=bold
hi link StorageClass	Type
hi link Structure	Type
hi Typedef		ctermbg=bg guibg=bg    ctermfg=#009900 guifg=#009900 cterm=italic gui=italic

hi Special	    ctermbg=bg guibg=bg	    ctermfg=fg guifg=fg	    cterm=none gui=none
hi SpecialChar	    ctermbg=bg guibg=bg	    ctermfg=fg guifg=fg	    cterm=none gui=bold
hi Tag		    ctermbg=bg guibg=bg	    ctermfg=#003399 guifg=#003399   cterm=none gui=bold
hi link Delimiter   Special
hi SpecialComment   ctermbg=#dddddd guibg=#dddddd   ctermfg=#aa0000 guifg=#aa0000   cterm=none gui=none
hi link Debug	    Special

hi Underlined ctermbg=bg guibg=bg ctermfg=blue guifg=blue cterm=underline gui=underline

hi Title    ctermbg=bg guibg=bg	ctermfg=fg guifg=fg    	cterm=none gui=bold
hi Ignore   ctermbg=bg guibg=bg	ctermfg=#999999 guifg=#999999	cterm=none gui=none
hi Error    ctermbg=red guibg=red	ctermfg=white guifg=white	cterm=none gui=none
hi Todo	    ctermbg=bg guibg=bg	ctermfg=#aa0000 guifg=#aa0000   cterm=none gui=none
