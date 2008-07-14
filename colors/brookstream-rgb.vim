"--------------------------------------------------------------------
" Name Of File: brookstream.vim.
" Description: Gvim colorscheme, works best with version 6.1   cterm .
" Maintainer: Peter Bäckström.
" Creator: Peter Bäckström.
" URL: http://www.brookstream.org (Swedish).
" Credits: Inspiration from the darkdot scheme.
" Last Change: Friday, April 13, 2003.
" Installation: Drop this file in your $VIMRUNTIME/colors/ directory.
"--------------------------------------------------------------------

set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="brookstream-rgb"

"--------------------------------------------------------------------

hi Normal           gui=none  cterm=none  ctermbg=#000000 guibg=#000000  ctermfg=#bbbbbb guifg=#bbbbbb
hi Cursor                                 ctermbg=#44ff44 guibg=#44ff44  ctermfg=#000000 guifg=#000000
hi Directory                                                             ctermfg=#44ffff guifg=#44ffff
hi DiffAdd                                ctermbg=#080808 guibg=#080808  ctermfg=#ffff00 guifg=#ffff00
hi DiffDelete                             ctermbg=#080808 guibg=#080808  ctermfg=#444444 guifg=#444444
hi DiffChange                             ctermbg=#080808 guibg=#080808  ctermfg=#ffffff guifg=#ffffff
hi DiffText                               ctermbg=#080808 guibg=#080808  ctermfg=#bb0000 guifg=#bb0000
hi ErrorMsg                               ctermbg=#880000 guibg=#880000  ctermfg=#ffffff guifg=#ffffff
hi Folded                                                                ctermfg=#000088 guifg=#000088
hi IncSearch                              ctermbg=#000000 guibg=#000000  ctermfg=#bbcccc guifg=#bbcccc
hi LineNr                                 ctermbg=#050505 guibg=#050505  ctermfg=#4682b4 guifg=#4682b4
hi ModeMsg                                                               ctermfg=#ffffff guifg=#ffffff
hi MoreMsg                                                               ctermfg=#44ff44 guifg=#44ff44
hi NonText                                                               ctermfg=#4444ff guifg=#4444ff
hi Question                                                              ctermfg=#ffff00 guifg=#ffff00
hi SpecialKey                                                            ctermfg=#4444ff guifg=#4444ff
hi StatusLine       gui=none  cterm=none  ctermbg=#2f4f4f guibg=#2f4f4f  ctermfg=#ffffff guifg=#ffffff
hi StatusLineNC     gui=none  cterm=none  ctermbg=#bbbbbb guibg=#bbbbbb  ctermfg=#000000 guifg=#000000
hi Title                                                                 ctermfg=#ffffff guifg=#ffffff
hi Visual           gui=none  cterm=none  ctermbg=#bbbbbb guibg=#bbbbbb  ctermfg=#000000 guifg=#000000
hi WarningMsg                                                            ctermfg=#ffff00 guifg=#ffff00

" syntax highlighting groups ----------------------------------------

hi Comment                                                               ctermfg=#696969 guifg=#696969
hi Constant                                                              ctermfg=#00aaaa guifg=#00aaaa
hi Identifier                                                            ctermfg=#00e5ee guifg=#00e5ee
hi Statement                                                             ctermfg=#00ffff guifg=#00ffff
hi PreProc                                                               ctermfg=#8470ff guifg=#8470ff
hi Type                                                                  ctermfg=#ffffff guifg=#ffffff
hi Special          gui=none  cterm=none                                 ctermfg=#87cefa guifg=#87cefa
hi Underlined       gui=bold  cterm=bold                                 ctermfg=#4444ff guifg=#4444ff
hi Ignore                                                                ctermfg=#444444 guifg=#444444
hi Error                                  ctermbg=#000000 guibg=#000000  ctermfg=#bb0000 guifg=#bb0000
hi Todo                                   ctermbg=#aa0006 guibg=#aa0006  ctermfg=#fff300 guifg=#fff300
hi Operator         gui=none  cterm=none                                 ctermfg=#00bfff guifg=#00bfff
hi Function                                                              ctermfg=#1e90ff guifg=#1e90ff
hi String           gui=none  cterm=none                                 ctermfg=#4682b4 guifg=#4682b4
hi Boolean                                                               ctermfg=#9bcd9b guifg=#9bcd9b
