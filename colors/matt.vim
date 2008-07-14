" matt.vim: a new colorscheme by godlygeek
" Written By: Charles E. Campbell, Jr.'s ftplugin/hicolors.vim
" Date: Sat May 27 17:49:28 2006

" ---------------------------------------------------------------------
" Standard Initialization:
set bg=light
hi clear
if exists( "syntax_on")
 syntax reset
endif
let g:colors_name="matt"

" ---------------------------------------------------------------------
" Highlighting Commands:
hi SpecialKey     term=bold ctermfg=18 guifg=#000087
hi NonText        term=bold cterm=bold ctermfg=22 guifg=#005f00 ctermbg=231 guibg=#ffffff
hi Directory      term=bold ctermfg=18 guifg=#000087
hi ErrorMsg       term=standout ctermfg=15 guifg=#FFFFFF ctermbg=9 guibg=#FF5555
hi IncSearch      cterm=bold ctermfg=160 guifg=#d70000 ctermbg=15 guibg=#FFFFFF
hi Search         term=reverse ctermfg=0 guifg=#000000 ctermbg=11 guibg=#FFFF55
hi MoreMsg        term=bold cterm=bold ctermfg=29 guifg=#00875f
hi ModeMsg        term=bold cterm=bold
hi LineNr         term=underline ctermfg=55 guifg=#5f00af ctermbg=255 guibg=#eeeeee
hi Question       term=standout cterm=bold ctermfg=10 guifg=#5FAF00
hi StatusLine     term=bold,reverse cterm=reverse ctermfg=68 guifg=#5f87d7
hi StatusLineNC   term=reverse cterm=reverse ctermbg=188 guibg=#d7d7d7
hi VertSplit      term=bold cterm=bold
hi Title          term=bold cterm=bold ctermfg=18 guifg=#000087
hi Visual         term=reverse cterm=bold ctermfg=88 guifg=#870000 ctermbg=7 guibg=#B4B4B4
hi VisualNOS      term=bold,underline cterm=bold,underline
hi WarningMsg     term=standout ctermfg=9 guifg=#FF5555
hi WildMenu       term=standout ctermfg=0 guifg=#000000 ctermbg=11 guibg=#FFFF55
hi Folded         term=standout ctermfg=18 guifg=#000087 ctermbg=252 guibg=#d0d0d0
hi FoldColumn     term=standout ctermfg=18 guifg=#000087 ctermbg=250 guibg=#bcbcbc
hi DiffAdd        term=bold ctermbg=18 guibg=#000087
hi DiffChange     term=bold ctermbg=90 guibg=#870087
hi DiffDelete     term=bold cterm=bold ctermfg=21 guifg=#0000ff ctermbg=30 guibg=#008787
hi DiffText       term=reverse cterm=bold ctermbg=9 guibg=#FF5555
hi SignColumn     term=standout ctermfg=4 guifg=#3030FF ctermbg=248 guibg=#a8a8a8
if version > 700
hi SpellBad       term=reverse ctermbg=224 guibg=#ffd7d7
hi SpellCap       term=reverse ctermbg=81 guibg=#5fd7ff
hi SpellRare      term=reverse ctermbg=225 guibg=#ffd7ff
hi SpellLocal     term=underline ctermbg=14 guibg=#55FFFF
endif
hi Pmenu          ctermbg=225 guibg=#ffd7ff
hi PmenuSel       ctermbg=7 guibg=#B4B4B4
hi PmenuSbar      ctermbg=248 guibg=#a8a8a8
hi PmenuThumb     cterm=reverse
hi TabLine        term=underline cterm=underline ctermfg=0 guifg=#000000 ctermbg=7 guibg=#B4B4B4
hi TabLineSel     term=bold cterm=bold
hi TabLineFill    term=reverse cterm=reverse
hi CursorColumn   term=reverse ctermbg=7 guibg=#B4B4B4
hi CursorLine     term=underline cterm=underline
hi Cursor         ctermfg=0 guifg=#000000 ctermbg=0 guibg=#000000
hi lCursor        ctermfg=0 guifg=#000000 ctermbg=14 guibg=#55FFFF
hi MatchParen     term=reverse ctermfg=54 guifg=#5f0087 ctermbg=152 guibg=#afd7d7
hi Normal         ctermfg=0 guifg=#000000 ctermbg=15 guibg=#FFFFFF
hi Comment        term=bold ctermfg=21 guifg=#0000ff
hi Constant       term=underline ctermfg=18 guifg=#000087 ctermbg=15 guibg=#FFFFFF
hi Special        term=bold ctermfg=18 guifg=#000087 ctermbg=15 guibg=#FFFFFF
hi Identifier     term=underline ctermfg=6 guifg=#28B4B4
hi Statement      term=bold cterm=bold ctermfg=18 guifg=#000087
hi PreProc        term=underline ctermfg=5 guifg=#903090
hi Type           term=underline ctermfg=2 guifg=#32C832
hi Underlined     term=underline cterm=underline ctermfg=5 guifg=#903090
hi Ignore         ctermfg=7 guifg=#B4B4B4
hi Error          term=reverse ctermfg=15 guifg=#FFFFFF ctermbg=9 guibg=#FF5555
hi Todo           term=standout ctermfg=0 guifg=#000000 ctermbg=11 guibg=#FFFF55
hi String         ctermfg=22 guifg=#005f00
hi Label          cterm=bold ctermfg=18 guifg=#000087
hi WriteColorscheme ctermfg=15 guifg=#FFFFFF
