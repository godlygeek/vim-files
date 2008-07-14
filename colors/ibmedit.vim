" Vim color file
" Maintainer:   Maarten Slaets
" Last Change:  2002 Aug 16

" Color settings similar to that used in IBM Edit

set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="ibmedit"

hi Normal       term=NONE cterm=NONE  
hi Normal       gui=NONE guifg=#CCCCCC ctermfg=252 guibg=1 ctermbg=1
hi NonText      term=NONE cterm=NONE  
hi NonText      gui=NONE guifg=#CCCCCC ctermfg=252 guibg=1 ctermbg=1

hi Statement    term=NONE cterm=NONE   
hi Statement    gui=NONE guifg=15 ctermfg=15 guibg=1 ctermbg=1
hi Special      term=NONE cterm=NONE  
hi Special      gui=NONE guifg=15 ctermfg=15 guibg=1 ctermbg=1
hi Constant     term=NONE cterm=NONE  
hi Constant     gui=NONE guifg=#99CCFF ctermfg=117 guibg=1 ctermbg=1
hi Comment      term=NONE cterm=NONE  
hi Comment      gui=NONE guifg=#6666FF ctermfg=63 guibg=1 ctermbg=1
hi Preproc      term=NONE cterm=NONE  
hi Preproc      gui=NONE guifg=#99CCFF ctermfg=117 guibg=1 ctermbg=1
hi Type         term=NONE cterm=NONE  
hi Type         gui=NONE guifg=#CCCCCC ctermfg=252 guibg=1 ctermbg=1
hi Identifier   term=NONE cterm=NONE  
hi Identifier   gui=NONE guifg=#CCCCCC ctermfg=252 guibg=1 ctermbg=1

hi StatusLine   term=bold cterm=bold  
hi StatusLine   gui=bold guifg=0 ctermfg=0 guibg=15 ctermbg=15

hi StatusLineNC term=NONE cterm=NONE  
hi StatusLineNC gui=NONE guifg=0 ctermfg=0 guibg=15 ctermbg=15

hi Visual       term=NONE cterm=NONE  
hi Visual       gui=NONE guifg=0 ctermfg=0 guibg=7 ctermbg=7

hi Search       term=NONE cterm=NONE 
hi Search       gui=NONE guibg=7 ctermbg=7

hi VertSplit    term=NONE cterm=NONE  
hi VertSplit    gui=NONE guifg=0 ctermfg=0 guibg=15 ctermbg=15

hi Directory    term=NONE cterm=NONE  
hi Directory    gui=NONE guifg=10 ctermfg=10 guibg=1 ctermbg=1

hi WarningMsg   term=standout cterm=NONE  
hi WarningMsg   gui=standout guifg=12 ctermfg=12 guibg=1 ctermbg=1

hi Error        term=NONE cterm=NONE  
hi Error        gui=NONE guifg=15 ctermfg=15 guibg=12 ctermbg=12

hi Cursor       guifg=0 ctermfg=0 guibg=14 ctermbg=14

