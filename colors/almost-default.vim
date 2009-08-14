" Vim color file
" Maintainer:   Tony Mechelynck <antoine.mechelynck@skynet.be>
" Last Change:  2006 Sep 06
" ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
" This is almost the default color scheme.  It doesn't define the Normal
" highlighting, it uses whatever the colors used to be.

" Only the few highlight groups named below are defined; the rest (most of
" them) are left at their compiled-in default settings.

let s:colors_name = "almost-default"
if exists("g:debug") && g:debug
  echomsg s:colors_name "start"
endif

" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
hi clear Normal
set bg&

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

" Set our own highlighting settings
hi SpecialKey                   guibg=NONE
" white on red is not always distinct in the GUI: use black on red then
hi Error                        guibg=red           guifg=black
hi clear ErrorMsg
hi link  ErrorMsg       Error
" display matchit messages
hi def link MatchError  WarningMsg
" show cursor line/column (if enabled) in very light grey in the GUI,
" underlined in the console
if has("gui_running")
  hi clear CursorLine
  hi CursorLine                 guibg=#F4F4F4
endif
hi clear CursorColumn
hi link  CursorColumn   CursorLine
" do not make help bars and stars invisible
hi clear helpBar
hi link  helpBar        helpHyperTextJump
hi clear helpStar
hi link  helpStar       helpHyperTextEntry
" the following were forgotten in the syntax/vim.vim (and ended up cleared)
hi clear vimVar
hi link  vimVar         Identifier
hi clear vimGroupName
hi link  vimGroupName   vimGroup
hi clear vimHiClear
hi link  vimHiClear     vimHighlight
" in the GUI only, display the Ignore group as very slightly visible
hi clear Ignore
  exe "hi Ignore term=NONE guibg=white guifg=#999999 ctermbg=NONE ctermfg="
    \ . (&bg == "dark" ? "black" : "white")
" display the status line of the active window in a distinctive color:
" bold black on bright red in the GUI, white on green in the console
" (where the bg is never bright, and dark red is sometimes an ugly sort
" of reddish brown).
hi StatusLine   gui=NONE,bold   guibg=red           guifg=black
        \       cterm=NONE,bold ctermbg=darkgreen   ctermfg=white
hi WildMenu     gui=NONE,bold   guibg=green         guifg=black
        \       cterm=NONE,bold ctermbg=black       ctermfg=white
" make the status line bold-reverse (but B&W) for inactive windows
hi StatusLineNC gui=reverse,bold
        \       cterm=NONE      ctermbg=black       ctermfg=lightgrey
" make the active status line colours alternate between two settings
" to give a visual notice of the CursorHold/CursorHoldI events
if ! exists("s:statuslineflag")
  let s:statuslineflag = 0
endif
function! ToggleStatusLine()
    if s:statuslineflag
        hi StatusLine
          \     cterm=NONE,bold ctermbg=darkgreen   ctermfg=white
          \     gui=NONE,bold   guibg=red           guifg=black
        hi WildMenu
          \     cterm=NONE,bold ctermbg=black       ctermfg=white
          \     gui=NONE,bold   guibg=green         guifg=black
    else
        hi StatusLine
          \     cterm=NONE,bold ctermbg=black       ctermfg=white
          \     gui=NONE,bold   guibg=green         guifg=black
        hi WildMenu
          \     cterm=NONE,bold ctermbg=darkgreen   ctermfg=white
          \     gui=NONE,bold   guibg=red           guifg=black
    endif
    let s:statuslineflag = ! s:statuslineflag
    if exists(':CSApprox') == 2
      CSApprox!
    endif
endfunction
exe "augroup" s:colors_name
    au! CursorHold,CursorHoldI * call ToggleStatusLine()
    au! ColorScheme *
        \ if g:colors_name != s:colors_name | exe "au!" s:colors_name | endif
augroup END
" define colors for the tab line:
" file name of unselected tab
hi TabLine      gui=NONE        guibg=#EEEEEE       guifg=black
        \       cterm=NONE,bold ctermbg=lightgrey   ctermfg=white
" file name of selected tab (GUI default is bold black on white)
hi TabLineSel   cterm=NONE,bold ctermbg=green       ctermfg=white
" fillup and tab-delete "X" at right
hi TabLineFill  gui=NONE,bold   guibg=#CCCCCC       guifg=#990000
        \       cterm=NONE      ctermbg=lightgrey   ctermfg=red
" tab and file number 1:2/3 (meaning "tab 1: window 2 of 3) for selected tab
hi User1        gui=bold        guibg=white         guifg=magenta
        \                       ctermbg=green       ctermfg=black
" tab and file number 1:2/3 for unselected tab
hi User2                        guibg=#EEEEEE       guifg=magenta
        \                       ctermbg=lightgrey   ctermfg=black
" additional override for manpages à la Dr. Chip
hi manSubSectionStart           guibg=white         guifg=yellow
        \                       ctermbg=black       ctermfg=darkblue

" remember the current colorscheme name
let g:colors_name = s:colors_name
if 0
" the following is required e.g. if we have debug on, and doesn't harm anyway
if exists("syntax_on")
  syntax on
endif

if exists("g:debug") && g:debug
  echomsg s:colors_name "end"
endif
endif

" vim: sw=2 et
