" This scheme was created by CSApproxSnapshot
" on Fri, 06 Nov 2009

hi clear
if exists("syntax_on")
    syntax reset
endif

if v:version < 700
    let g:colors_name = expand("<sfile>:t:r")
    command! -nargs=+ CSAHi exe "hi" substitute(substitute(<q-args>, "undercurl", "underline", "g"), "guisp\\S\\+", "", "g")
else
    let g:colors_name = expand("<sfile>:t:r")
    command! -nargs=+ CSAHi exe "hi" <q-args>
endif

if 0
elseif has("gui_running") || (&t_Co == 256 && (&term ==# "xterm" || &term =~# "^screen") && exists("g:CSApprox_konsole") && g:CSApprox_konsole) || &term =~? "^konsole"
    CSAHi Normal term=NONE cterm=NONE ctermbg=231 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Underlined term=underline cterm=underline ctermbg=231 ctermfg=21 gui=underline guibg=#fffdfa guifg=#0013ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=231 ctermfg=145 gui=NONE guibg=#fffdfa guifg=#999999
    CSAHi Error term=reverse cterm=NONE ctermbg=196 ctermfg=231 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi Todo term=NONE cterm=NONE ctermbg=231 ctermfg=124 gui=NONE guibg=#fffdfa guifg=#aa0000
    CSAHi String term=NONE cterm=NONE ctermbg=231 ctermfg=25 gui=italic guibg=#fffdfa guifg=#003399
    CSAHi Character term=NONE cterm=NONE ctermbg=231 ctermfg=25 gui=italic guibg=#fffdfa guifg=#003399
    CSAHi Number term=NONE cterm=NONE ctermbg=231 ctermfg=25 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Boolean term=NONE cterm=NONE ctermbg=231 ctermfg=25 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Float term=NONE cterm=NONE ctermbg=231 ctermfg=25 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Function term=NONE cterm=NONE ctermbg=231 ctermfg=31 gui=bold guibg=#fffdfa guifg=#0055aa
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=231 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi NonText term=bold cterm=NONE ctermbg=231 ctermfg=19 gui=bold guibg=#eafaea guifg=#000099
    CSAHi Directory term=bold cterm=NONE ctermbg=231 ctermfg=64 gui=NONE guibg=#fffdfa guifg=#337700
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=231 ctermfg=160 gui=bold guibg=#fffdfa guifg=#cc0000
    CSAHi IncSearch term=reverse cterm=NONE ctermbg=226 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi Search term=reverse cterm=NONE ctermbg=186 ctermfg=16 gui=NONE guibg=#d7d75f guifg=#000000
    CSAHi MoreMsg term=bold cterm=NONE ctermbg=231 ctermfg=72 gui=bold guibg=bg guifg=#2e8b57
    CSAHi ModeMsg term=bold cterm=NONE ctermbg=231 ctermfg=25 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi LineNr term=underline cterm=NONE ctermbg=231 ctermfg=145 gui=NONE guibg=#fffdfa guifg=#999999
    CSAHi Titled term=NONE cterm=NONE ctermbg=231 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=225 ctermfg=16 gui=NONE guibg=#ffbbff guifg=fg
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=250 ctermfg=16 gui=NONE guibg=#c0c0c0 guifg=fg
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=250 ctermfg=16 gui=NONE guibg=#c0c0c0 guifg=fg
    CSAHi PmenuThumb term=NONE cterm=NONE ctermbg=16 ctermfg=231 gui=reverse guibg=bg guifg=fg
    CSAHi TabLine term=underline cterm=underline ctermbg=252 ctermfg=16 gui=underline guibg=#d3d3d3 guifg=fg
    CSAHi TabLineSel term=bold cterm=NONE ctermbg=231 ctermfg=16 gui=bold guibg=bg guifg=fg
    CSAHi TabLineFill term=reverse cterm=NONE ctermbg=16 ctermfg=231 gui=reverse guibg=bg guifg=fg
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=254 ctermfg=16 gui=NONE guibg=#e5e5e5 guifg=fg
    CSAHi CursorLine term=underline cterm=NONE ctermbg=254 ctermfg=16 gui=NONE guibg=#e5e5e5 guifg=fg
    CSAHi Cursor term=NONE cterm=NONE ctermbg=137 ctermfg=230 gui=bold guibg=#aa7733 guifg=#ffeebb
    CSAHi Conditional term=NONE cterm=NONE ctermbg=231 ctermfg=137 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Repeat term=NONE cterm=NONE ctermbg=231 ctermfg=137 gui=bold guibg=#fffdfa guifg=#aa5544
    CSAHi Operator term=NONE cterm=NONE ctermbg=231 ctermfg=137 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Exception term=NONE cterm=NONE ctermbg=231 ctermfg=72 gui=bold guibg=#fffdfa guifg=#228877
    CSAHi Include term=NONE cterm=NONE ctermbg=231 ctermfg=106 gui=bold guibg=#fffdfa guifg=#558811
    CSAHi Question term=NONE cterm=NONE ctermbg=231 ctermfg=72 gui=bold guibg=bg guifg=#2e8b57
    CSAHi StatusLine term=reverse,bold cterm=NONE ctermbg=230 ctermfg=16 gui=bold guibg=#ffeebb guifg=#000000
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=144 ctermfg=230 gui=NONE guibg=#aa8866 guifg=#f8e8cc
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=144 ctermfg=224 gui=NONE guibg=#aa8866 guifg=#ffe0bb
    CSAHi Title term=bold cterm=NONE ctermbg=231 ctermfg=16 gui=bold guibg=#fffdfa guifg=#000000
    CSAHi Visual term=reverse cterm=NONE ctermbg=217 ctermfg=16 gui=NONE guibg=#ffaaaa guifg=#000000
    CSAHi VisualNOS term=bold,underline cterm=underline ctermbg=231 ctermfg=16 gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=231 ctermfg=160 gui=bold guibg=#fffdfa guifg=#cc0000
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=226 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi Folded term=NONE cterm=NONE ctermbg=252 ctermfg=19 gui=NONE guibg=#d3d3d3 guifg=#00008b
    CSAHi lCursor term=NONE cterm=NONE ctermbg=16 ctermfg=231 gui=NONE guibg=#000000 guifg=#fffdfa
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=51 ctermfg=16 gui=NONE guibg=#00ffff guifg=fg
    CSAHi Comment term=bold cterm=NONE ctermbg=194 ctermfg=22 gui=NONE guibg=#ddeedd guifg=#002200
    CSAHi Constant term=underline cterm=NONE ctermbg=231 ctermfg=25 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Special term=bold cterm=NONE ctermbg=231 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Identifier term=underline cterm=NONE ctermbg=231 ctermfg=25 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi Statement term=bold cterm=NONE ctermbg=231 ctermfg=25 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi PreProc term=underline cterm=NONE ctermbg=231 ctermfg=137 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Type term=underline cterm=NONE ctermbg=231 ctermfg=28 gui=bold guibg=#fffdfa guifg=#007700
    CSAHi Typedef term=NONE cterm=NONE ctermbg=231 ctermfg=34 gui=italic guibg=#fffdfa guifg=#009900
    CSAHi Tag term=NONE cterm=NONE ctermbg=231 ctermfg=25 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi SpecialChar term=NONE cterm=NONE ctermbg=231 ctermfg=16 gui=bold guibg=#fffdfa guifg=#000000
    CSAHi SpecialComment term=NONE cterm=NONE ctermbg=253 ctermfg=124 gui=NONE guibg=#dddddd guifg=#aa0000
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=250 ctermfg=19 gui=NONE guibg=#c0c0c0 guifg=#00008b
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=153 ctermfg=16 gui=NONE guibg=#add8e6 guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=225 ctermfg=16 gui=NONE guibg=#ffbbff guifg=fg
    CSAHi DiffDelete term=bold cterm=NONE ctermbg=195 ctermfg=21 gui=bold guibg=#e0ffff guifg=#0013ff
    CSAHi DiffText term=reverse cterm=NONE ctermbg=196 ctermfg=16 gui=bold guibg=#ff0000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=250 ctermfg=19 gui=NONE guibg=#c0c0c0 guifg=#00008b
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=231 ctermfg=196 gui=undercurl guibg=bg guifg=fg guisp=Red
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=231 ctermfg=21 gui=undercurl guibg=bg guifg=fg guisp=Blue
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=231 ctermfg=201 gui=undercurl guibg=bg guifg=fg guisp=Magenta
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=231 ctermfg=37 gui=undercurl guibg=bg guifg=fg guisp=DarkCyan
elseif has("gui_running") || (&t_Co == 256 && (&term ==# "xterm" || &term =~# "^screen") && exists("g:CSApprox_eterm") && g:CSApprox_eterm) || &term =~? "^eterm"
    CSAHi Normal term=NONE cterm=NONE ctermbg=255 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Underlined term=underline cterm=underline ctermbg=255 ctermfg=21 gui=underline guibg=#fffdfa guifg=#0013ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=255 ctermfg=246 gui=NONE guibg=#fffdfa guifg=#999999
    CSAHi Error term=reverse cterm=NONE ctermbg=196 ctermfg=255 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi Todo term=NONE cterm=NONE ctermbg=255 ctermfg=160 gui=NONE guibg=#fffdfa guifg=#aa0000
    CSAHi String term=NONE cterm=NONE ctermbg=255 ctermfg=26 gui=italic guibg=#fffdfa guifg=#003399
    CSAHi Character term=NONE cterm=NONE ctermbg=255 ctermfg=26 gui=italic guibg=#fffdfa guifg=#003399
    CSAHi Number term=NONE cterm=NONE ctermbg=255 ctermfg=26 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Boolean term=NONE cterm=NONE ctermbg=255 ctermfg=26 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Float term=NONE cterm=NONE ctermbg=255 ctermfg=26 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Function term=NONE cterm=NONE ctermbg=255 ctermfg=32 gui=bold guibg=#fffdfa guifg=#0055aa
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=255 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi NonText term=bold cterm=NONE ctermbg=255 ctermfg=20 gui=bold guibg=#eafaea guifg=#000099
    CSAHi Directory term=bold cterm=NONE ctermbg=255 ctermfg=70 gui=NONE guibg=#fffdfa guifg=#337700
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=255 ctermfg=196 gui=bold guibg=#fffdfa guifg=#cc0000
    CSAHi IncSearch term=reverse cterm=NONE ctermbg=226 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi Search term=reverse cterm=NONE ctermbg=228 ctermfg=16 gui=NONE guibg=#d7d75f guifg=#000000
    CSAHi MoreMsg term=bold cterm=NONE ctermbg=255 ctermfg=72 gui=bold guibg=bg guifg=#2e8b57
    CSAHi ModeMsg term=bold cterm=NONE ctermbg=255 ctermfg=26 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi LineNr term=underline cterm=NONE ctermbg=255 ctermfg=246 gui=NONE guibg=#fffdfa guifg=#999999
    CSAHi Titled term=NONE cterm=NONE ctermbg=255 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=225 ctermfg=16 gui=NONE guibg=#ffbbff guifg=fg
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=250 ctermfg=16 gui=NONE guibg=#c0c0c0 guifg=fg
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=250 ctermfg=16 gui=NONE guibg=#c0c0c0 guifg=fg
    CSAHi PmenuThumb term=NONE cterm=NONE ctermbg=16 ctermfg=255 gui=reverse guibg=bg guifg=fg
    CSAHi TabLine term=underline cterm=underline ctermbg=231 ctermfg=16 gui=underline guibg=#d3d3d3 guifg=fg
    CSAHi TabLineSel term=bold cterm=NONE ctermbg=255 ctermfg=16 gui=bold guibg=bg guifg=fg
    CSAHi TabLineFill term=reverse cterm=NONE ctermbg=16 ctermfg=255 gui=reverse guibg=bg guifg=fg
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=254 ctermfg=16 gui=NONE guibg=#e5e5e5 guifg=fg
    CSAHi CursorLine term=underline cterm=NONE ctermbg=254 ctermfg=16 gui=NONE guibg=#e5e5e5 guifg=fg
    CSAHi Cursor term=NONE cterm=NONE ctermbg=179 ctermfg=230 gui=bold guibg=#aa7733 guifg=#ffeebb
    CSAHi Conditional term=NONE cterm=NONE ctermbg=255 ctermfg=179 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Repeat term=NONE cterm=NONE ctermbg=255 ctermfg=174 gui=bold guibg=#fffdfa guifg=#aa5544
    CSAHi Operator term=NONE cterm=NONE ctermbg=255 ctermfg=179 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Exception term=NONE cterm=NONE ctermbg=255 ctermfg=73 gui=bold guibg=#fffdfa guifg=#228877
    CSAHi Include term=NONE cterm=NONE ctermbg=255 ctermfg=106 gui=bold guibg=#fffdfa guifg=#558811
    CSAHi Question term=NONE cterm=NONE ctermbg=255 ctermfg=72 gui=bold guibg=bg guifg=#2e8b57
    CSAHi StatusLine term=reverse,bold cterm=NONE ctermbg=230 ctermfg=16 gui=bold guibg=#ffeebb guifg=#000000
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=180 ctermfg=231 gui=NONE guibg=#aa8866 guifg=#f8e8cc
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=180 ctermfg=230 gui=NONE guibg=#aa8866 guifg=#ffe0bb
    CSAHi Title term=bold cterm=NONE ctermbg=255 ctermfg=16 gui=bold guibg=#fffdfa guifg=#000000
    CSAHi Visual term=reverse cterm=NONE ctermbg=224 ctermfg=16 gui=NONE guibg=#ffaaaa guifg=#000000
    CSAHi VisualNOS term=bold,underline cterm=underline ctermbg=255 ctermfg=16 gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=255 ctermfg=196 gui=bold guibg=#fffdfa guifg=#cc0000
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=226 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi Folded term=NONE cterm=NONE ctermbg=231 ctermfg=19 gui=NONE guibg=#d3d3d3 guifg=#00008b
    CSAHi lCursor term=NONE cterm=NONE ctermbg=16 ctermfg=255 gui=NONE guibg=#000000 guifg=#fffdfa
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=51 ctermfg=16 gui=NONE guibg=#00ffff guifg=fg
    CSAHi Comment term=bold cterm=NONE ctermbg=231 ctermfg=22 gui=NONE guibg=#ddeedd guifg=#002200
    CSAHi Constant term=underline cterm=NONE ctermbg=255 ctermfg=26 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Special term=bold cterm=NONE ctermbg=255 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Identifier term=underline cterm=NONE ctermbg=255 ctermfg=26 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi Statement term=bold cterm=NONE ctermbg=255 ctermfg=26 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi PreProc term=underline cterm=NONE ctermbg=255 ctermfg=179 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Type term=underline cterm=NONE ctermbg=255 ctermfg=34 gui=bold guibg=#fffdfa guifg=#007700
    CSAHi Typedef term=NONE cterm=NONE ctermbg=255 ctermfg=40 gui=italic guibg=#fffdfa guifg=#009900
    CSAHi Tag term=NONE cterm=NONE ctermbg=255 ctermfg=26 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi SpecialChar term=NONE cterm=NONE ctermbg=255 ctermfg=16 gui=bold guibg=#fffdfa guifg=#000000
    CSAHi SpecialComment term=NONE cterm=NONE ctermbg=253 ctermfg=160 gui=NONE guibg=#dddddd guifg=#aa0000
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=250 ctermfg=19 gui=NONE guibg=#c0c0c0 guifg=#00008b
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=195 ctermfg=16 gui=NONE guibg=#add8e6 guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=225 ctermfg=16 gui=NONE guibg=#ffbbff guifg=fg
    CSAHi DiffDelete term=bold cterm=NONE ctermbg=231 ctermfg=21 gui=bold guibg=#e0ffff guifg=#0013ff
    CSAHi DiffText term=reverse cterm=NONE ctermbg=196 ctermfg=16 gui=bold guibg=#ff0000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=250 ctermfg=19 gui=NONE guibg=#c0c0c0 guifg=#00008b
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=255 ctermfg=196 gui=undercurl guibg=bg guifg=fg guisp=Red
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=255 ctermfg=21 gui=undercurl guibg=bg guifg=fg guisp=Blue
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=255 ctermfg=201 gui=undercurl guibg=bg guifg=fg guisp=Magenta
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=255 ctermfg=37 gui=undercurl guibg=bg guifg=fg guisp=DarkCyan
elseif has("gui_running") || &t_Co == 256
    CSAHi Normal term=NONE cterm=NONE ctermbg=231 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Underlined term=underline cterm=underline ctermbg=231 ctermfg=21 gui=underline guibg=#fffdfa guifg=#0013ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=231 ctermfg=246 gui=NONE guibg=#fffdfa guifg=#999999
    CSAHi Error term=reverse cterm=NONE ctermbg=196 ctermfg=231 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi Todo term=NONE cterm=NONE ctermbg=231 ctermfg=124 gui=NONE guibg=#fffdfa guifg=#aa0000
    CSAHi String term=NONE cterm=NONE ctermbg=231 ctermfg=24 gui=italic guibg=#fffdfa guifg=#003399
    CSAHi Character term=NONE cterm=NONE ctermbg=231 ctermfg=24 gui=italic guibg=#fffdfa guifg=#003399
    CSAHi Number term=NONE cterm=NONE ctermbg=231 ctermfg=24 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Boolean term=NONE cterm=NONE ctermbg=231 ctermfg=24 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Float term=NONE cterm=NONE ctermbg=231 ctermfg=24 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Function term=NONE cterm=NONE ctermbg=231 ctermfg=25 gui=bold guibg=#fffdfa guifg=#0055aa
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=231 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi NonText term=bold cterm=NONE ctermbg=194 ctermfg=18 gui=bold guibg=#eafaea guifg=#000099
    CSAHi Directory term=bold cterm=NONE ctermbg=231 ctermfg=64 gui=NONE guibg=#fffdfa guifg=#337700
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=231 ctermfg=160 gui=bold guibg=#fffdfa guifg=#cc0000
    CSAHi IncSearch term=reverse cterm=NONE ctermbg=226 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi Search term=reverse cterm=NONE ctermbg=185 ctermfg=16 gui=NONE guibg=#d7d75f guifg=#000000
    CSAHi MoreMsg term=bold cterm=NONE ctermbg=231 ctermfg=29 gui=bold guibg=bg guifg=#2e8b57
    CSAHi ModeMsg term=bold cterm=NONE ctermbg=231 ctermfg=24 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi LineNr term=underline cterm=NONE ctermbg=231 ctermfg=246 gui=NONE guibg=#fffdfa guifg=#999999
    CSAHi Titled term=NONE cterm=NONE ctermbg=231 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=219 ctermfg=16 gui=NONE guibg=#ffbbff guifg=fg
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=250 ctermfg=16 gui=NONE guibg=#c0c0c0 guifg=fg
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=250 ctermfg=16 gui=NONE guibg=#c0c0c0 guifg=fg
    CSAHi PmenuThumb term=NONE cterm=NONE ctermbg=16 ctermfg=231 gui=reverse guibg=bg guifg=fg
    CSAHi TabLine term=underline cterm=underline ctermbg=252 ctermfg=16 gui=underline guibg=#d3d3d3 guifg=fg
    CSAHi TabLineSel term=bold cterm=NONE ctermbg=231 ctermfg=16 gui=bold guibg=bg guifg=fg
    CSAHi TabLineFill term=reverse cterm=NONE ctermbg=16 ctermfg=231 gui=reverse guibg=bg guifg=fg
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=254 ctermfg=16 gui=NONE guibg=#e5e5e5 guifg=fg
    CSAHi CursorLine term=underline cterm=NONE ctermbg=254 ctermfg=16 gui=NONE guibg=#e5e5e5 guifg=fg
    CSAHi Cursor term=NONE cterm=NONE ctermbg=137 ctermfg=229 gui=bold guibg=#aa7733 guifg=#ffeebb
    CSAHi Conditional term=NONE cterm=NONE ctermbg=231 ctermfg=137 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Repeat term=NONE cterm=NONE ctermbg=231 ctermfg=131 gui=bold guibg=#fffdfa guifg=#aa5544
    CSAHi Operator term=NONE cterm=NONE ctermbg=231 ctermfg=137 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Exception term=NONE cterm=NONE ctermbg=231 ctermfg=30 gui=bold guibg=#fffdfa guifg=#228877
    CSAHi Include term=NONE cterm=NONE ctermbg=231 ctermfg=64 gui=bold guibg=#fffdfa guifg=#558811
    CSAHi Question term=NONE cterm=NONE ctermbg=231 ctermfg=29 gui=bold guibg=bg guifg=#2e8b57
    CSAHi StatusLine term=reverse,bold cterm=NONE ctermbg=229 ctermfg=16 gui=bold guibg=#ffeebb guifg=#000000
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=137 ctermfg=224 gui=NONE guibg=#aa8866 guifg=#f8e8cc
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=137 ctermfg=223 gui=NONE guibg=#aa8866 guifg=#ffe0bb
    CSAHi Title term=bold cterm=NONE ctermbg=231 ctermfg=16 gui=bold guibg=#fffdfa guifg=#000000
    CSAHi Visual term=reverse cterm=NONE ctermbg=217 ctermfg=16 gui=NONE guibg=#ffaaaa guifg=#000000
    CSAHi VisualNOS term=bold,underline cterm=underline ctermbg=231 ctermfg=16 gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=231 ctermfg=160 gui=bold guibg=#fffdfa guifg=#cc0000
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=226 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi Folded term=NONE cterm=NONE ctermbg=252 ctermfg=18 gui=NONE guibg=#d3d3d3 guifg=#00008b
    CSAHi lCursor term=NONE cterm=NONE ctermbg=16 ctermfg=231 gui=NONE guibg=#000000 guifg=#fffdfa
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=51 ctermfg=16 gui=NONE guibg=#00ffff guifg=fg
    CSAHi Comment term=bold cterm=NONE ctermbg=194 ctermfg=16 gui=NONE guibg=#ddeedd guifg=#002200
    CSAHi Constant term=underline cterm=NONE ctermbg=231 ctermfg=24 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Special term=bold cterm=NONE ctermbg=231 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Identifier term=underline cterm=NONE ctermbg=231 ctermfg=24 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi Statement term=bold cterm=NONE ctermbg=231 ctermfg=24 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi PreProc term=underline cterm=NONE ctermbg=231 ctermfg=137 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Type term=underline cterm=NONE ctermbg=231 ctermfg=28 gui=bold guibg=#fffdfa guifg=#007700
    CSAHi Typedef term=NONE cterm=NONE ctermbg=231 ctermfg=28 gui=italic guibg=#fffdfa guifg=#009900
    CSAHi Tag term=NONE cterm=NONE ctermbg=231 ctermfg=24 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi SpecialChar term=NONE cterm=NONE ctermbg=231 ctermfg=16 gui=bold guibg=#fffdfa guifg=#000000
    CSAHi SpecialComment term=NONE cterm=NONE ctermbg=253 ctermfg=124 gui=NONE guibg=#dddddd guifg=#aa0000
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=250 ctermfg=18 gui=NONE guibg=#c0c0c0 guifg=#00008b
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=152 ctermfg=16 gui=NONE guibg=#add8e6 guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=219 ctermfg=16 gui=NONE guibg=#ffbbff guifg=fg
    CSAHi DiffDelete term=bold cterm=NONE ctermbg=195 ctermfg=21 gui=bold guibg=#e0ffff guifg=#0013ff
    CSAHi DiffText term=reverse cterm=NONE ctermbg=196 ctermfg=16 gui=bold guibg=#ff0000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=250 ctermfg=18 gui=NONE guibg=#c0c0c0 guifg=#00008b
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=231 ctermfg=196 gui=undercurl guibg=bg guifg=fg guisp=Red
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=231 ctermfg=21 gui=undercurl guibg=bg guifg=fg guisp=Blue
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=231 ctermfg=201 gui=undercurl guibg=bg guifg=fg guisp=Magenta
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=231 ctermfg=30 gui=undercurl guibg=bg guifg=fg guisp=DarkCyan
elseif has("gui_running") || &t_Co == 88
    CSAHi Normal term=NONE cterm=NONE ctermbg=79 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Underlined term=underline cterm=underline ctermbg=79 ctermfg=19 gui=underline guibg=#fffdfa guifg=#0013ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=79 ctermfg=84 gui=NONE guibg=#fffdfa guifg=#999999
    CSAHi Error term=reverse cterm=NONE ctermbg=64 ctermfg=79 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi Todo term=NONE cterm=NONE ctermbg=79 ctermfg=32 gui=NONE guibg=#fffdfa guifg=#aa0000
    CSAHi String term=NONE cterm=NONE ctermbg=79 ctermfg=17 gui=italic guibg=#fffdfa guifg=#003399
    CSAHi Character term=NONE cterm=NONE ctermbg=79 ctermfg=17 gui=italic guibg=#fffdfa guifg=#003399
    CSAHi Number term=NONE cterm=NONE ctermbg=79 ctermfg=17 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Boolean term=NONE cterm=NONE ctermbg=79 ctermfg=17 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Float term=NONE cterm=NONE ctermbg=79 ctermfg=17 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Function term=NONE cterm=NONE ctermbg=79 ctermfg=21 gui=bold guibg=#fffdfa guifg=#0055aa
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=79 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi NonText term=bold cterm=NONE ctermbg=79 ctermfg=17 gui=bold guibg=#eafaea guifg=#000099
    CSAHi Directory term=bold cterm=NONE ctermbg=79 ctermfg=20 gui=NONE guibg=#fffdfa guifg=#337700
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=79 ctermfg=48 gui=bold guibg=#fffdfa guifg=#cc0000
    CSAHi IncSearch term=reverse cterm=NONE ctermbg=76 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi Search term=reverse cterm=NONE ctermbg=57 ctermfg=16 gui=NONE guibg=#d7d75f guifg=#000000
    CSAHi MoreMsg term=bold cterm=NONE ctermbg=79 ctermfg=21 gui=bold guibg=bg guifg=#2e8b57
    CSAHi ModeMsg term=bold cterm=NONE ctermbg=79 ctermfg=17 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi LineNr term=underline cterm=NONE ctermbg=79 ctermfg=84 gui=NONE guibg=#fffdfa guifg=#999999
    CSAHi Titled term=NONE cterm=NONE ctermbg=79 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=75 ctermfg=16 gui=NONE guibg=#ffbbff guifg=fg
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=85 ctermfg=16 gui=NONE guibg=#c0c0c0 guifg=fg
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=85 ctermfg=16 gui=NONE guibg=#c0c0c0 guifg=fg
    CSAHi PmenuThumb term=NONE cterm=NONE ctermbg=16 ctermfg=79 gui=reverse guibg=bg guifg=fg
    CSAHi TabLine term=underline cterm=underline ctermbg=86 ctermfg=16 gui=underline guibg=#d3d3d3 guifg=fg
    CSAHi TabLineSel term=bold cterm=NONE ctermbg=79 ctermfg=16 gui=bold guibg=bg guifg=fg
    CSAHi TabLineFill term=reverse cterm=NONE ctermbg=16 ctermfg=79 gui=reverse guibg=bg guifg=fg
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=87 ctermfg=16 gui=NONE guibg=#e5e5e5 guifg=fg
    CSAHi CursorLine term=underline cterm=NONE ctermbg=87 ctermfg=16 gui=NONE guibg=#e5e5e5 guifg=fg
    CSAHi Cursor term=NONE cterm=NONE ctermbg=36 ctermfg=78 gui=bold guibg=#aa7733 guifg=#ffeebb
    CSAHi Conditional term=NONE cterm=NONE ctermbg=79 ctermfg=36 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Repeat term=NONE cterm=NONE ctermbg=79 ctermfg=36 gui=bold guibg=#fffdfa guifg=#aa5544
    CSAHi Operator term=NONE cterm=NONE ctermbg=79 ctermfg=36 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Exception term=NONE cterm=NONE ctermbg=79 ctermfg=21 gui=bold guibg=#fffdfa guifg=#228877
    CSAHi Include term=NONE cterm=NONE ctermbg=79 ctermfg=36 gui=bold guibg=#fffdfa guifg=#558811
    CSAHi Question term=NONE cterm=NONE ctermbg=79 ctermfg=21 gui=bold guibg=bg guifg=#2e8b57
    CSAHi StatusLine term=reverse,bold cterm=NONE ctermbg=78 ctermfg=16 gui=bold guibg=#ffeebb guifg=#000000
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=37 ctermfg=78 gui=NONE guibg=#aa8866 guifg=#f8e8cc
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=37 ctermfg=74 gui=NONE guibg=#aa8866 guifg=#ffe0bb
    CSAHi Title term=bold cterm=NONE ctermbg=79 ctermfg=16 gui=bold guibg=#fffdfa guifg=#000000
    CSAHi Visual term=reverse cterm=NONE ctermbg=69 ctermfg=16 gui=NONE guibg=#ffaaaa guifg=#000000
    CSAHi VisualNOS term=bold,underline cterm=underline ctermbg=79 ctermfg=16 gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=79 ctermfg=48 gui=bold guibg=#fffdfa guifg=#cc0000
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=76 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi Folded term=NONE cterm=NONE ctermbg=86 ctermfg=17 gui=NONE guibg=#d3d3d3 guifg=#00008b
    CSAHi lCursor term=NONE cterm=NONE ctermbg=16 ctermfg=79 gui=NONE guibg=#000000 guifg=#fffdfa
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=31 ctermfg=16 gui=NONE guibg=#00ffff guifg=fg
    CSAHi Comment term=bold cterm=NONE ctermbg=87 ctermfg=16 gui=NONE guibg=#ddeedd guifg=#002200
    CSAHi Constant term=underline cterm=NONE ctermbg=79 ctermfg=17 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi Special term=bold cterm=NONE ctermbg=79 ctermfg=16 gui=NONE guibg=#fffdfa guifg=#000000
    CSAHi Identifier term=underline cterm=NONE ctermbg=79 ctermfg=17 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi Statement term=bold cterm=NONE ctermbg=79 ctermfg=17 gui=NONE guibg=#fffdfa guifg=#003399
    CSAHi PreProc term=underline cterm=NONE ctermbg=79 ctermfg=36 gui=bold guibg=#fffdfa guifg=#aa7733
    CSAHi Type term=underline cterm=NONE ctermbg=79 ctermfg=20 gui=bold guibg=#fffdfa guifg=#007700
    CSAHi Typedef term=NONE cterm=NONE ctermbg=79 ctermfg=20 gui=italic guibg=#fffdfa guifg=#009900
    CSAHi Tag term=NONE cterm=NONE ctermbg=79 ctermfg=17 gui=bold guibg=#fffdfa guifg=#003399
    CSAHi SpecialChar term=NONE cterm=NONE ctermbg=79 ctermfg=16 gui=bold guibg=#fffdfa guifg=#000000
    CSAHi SpecialComment term=NONE cterm=NONE ctermbg=87 ctermfg=32 gui=NONE guibg=#dddddd guifg=#aa0000
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=85 ctermfg=17 gui=NONE guibg=#c0c0c0 guifg=#00008b
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=58 ctermfg=16 gui=NONE guibg=#add8e6 guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=75 ctermfg=16 gui=NONE guibg=#ffbbff guifg=fg
    CSAHi DiffDelete term=bold cterm=NONE ctermbg=63 ctermfg=19 gui=bold guibg=#e0ffff guifg=#0013ff
    CSAHi DiffText term=reverse cterm=NONE ctermbg=64 ctermfg=16 gui=bold guibg=#ff0000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=85 ctermfg=17 gui=NONE guibg=#c0c0c0 guifg=#00008b
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=79 ctermfg=64 gui=undercurl guibg=bg guifg=fg guisp=Red
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=79 ctermfg=19 gui=undercurl guibg=bg guifg=fg guisp=Blue
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=79 ctermfg=67 gui=undercurl guibg=bg guifg=fg guisp=Magenta
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=79 ctermfg=21 gui=undercurl guibg=bg guifg=fg guisp=DarkCyan
endif

if 1
    delcommand CSAHi
endif
