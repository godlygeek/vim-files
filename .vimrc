" Author:  Matthew Wozniski (mjw@drexel.edu)
"
" Feel free to do whatever you would like with this file as long as you give
" credit where credit is due.
"
" NOTE:
" If you're editing this in Vim and don't know how folding works, type zR to
" unfold them all.

if version < 700
  set noloadplugins
endif

"" Skip this file unless we have +eval
if 1
""" Setup
""" Settings
"""" Important
set nocompatible            " Don't try to be vi compatible - be better.

"""" Terminal Setup
if ! has('gui_running')
  set ttyscroll=3           " Prefer redraw to scrolling for more than 3 lines
  set timeoutlen=700        " Wait 700 ms before timing out a mapping
  set ttimeoutlen=100       " and only 100 ms before timing out on a keypress
  set mouse=nv              " Allow mouse use in normal and visual mode
  set ttymouse=xterm2       " Terminal sends modern xterm mouse reporting.

  exe "set t_kb=\<C-?>"   | " My machines are all configured to send ^? for <BS>
  exe "set t_kD=\<ESC>[3~"| " and ^[[3~ for <DEL>, no matter what termcap says.
  exe "set t_kB=\<ESC>[Z" | " If the terminal has shift-tab, it's ^[[Z

  if $INTERM =~ '^xterm' || $INTERM == 'rxvt-unicode'
    exe "set t_RV=\<ESC>[>c"
  endif

  set clipboard=exclude:*

  " Set the to-status-line and from-status-line sequence for any terminal we
  " expect to have a changeable titlebar; as they are likely wrong in terminfo
  if $TERM != 'linux'
    " Set up the titlebar control sequences; they may be wrong in termcap/info
    exe "set t_ts=\<ESC>]2;"
    exe "set t_fs=\<C-G>"
  endif
endif

set title                   " Turn on titlebar support

"  Titlebar string is  hostname> ${PWD:s/^$HOME/~} || (view|vim) filename ([+]|)
let &titlestring  = hostname() . '> '
                \ . '%{substitute(expand("%:p:h"),"^".$HOME,"~","")}'
                \ . ' || %{&ft=~"^man"?"man":&ro?"view":"vim"} %f %m'

if $TITLE != ""
  " We know the last title set by the shell. (My zsh config exports this.)
  let &titleold = $TITLE
else
  "  Old title was probably just  hostname> ${PWD:s/^$HOME/~}
  let &titleold  = ($WINDOW == "" ? '[' .$WINDOW. '] ' : '') . hostname() . '> '
  let &titleold .= escape(substitute($PWD, "^".$HOME, "~", ""), ' \')
endif

"""" Moving Around
set whichwrap=b,s,h,l,<,>   " Keys that normally move l-r that can change lines
set virtualedit=block       " Let cursor go past the last char in block mode
" Jumping to files searches subdirectories and system include directories
set path=**,/usr/local/include,/usr/include;

"""" Searching and Patterns
set incsearch               " Incrementally search on /, don't wait for return.
set ignorecase              " Case insensitive searches
set smartcase               " Unless uppercase letters are used in the query
set hlsearch                " Highlight searches by default

"""" Display
set lazyredraw              " Don't repaint the screen while scripts are running
set scrolloff=3             " Keep at least 3 lines below and above the cursor
if has("multi_byte") && &enc == "utf-8"
  set list                  " Show tabs, trailing spaces, and nonbreaking spaces
  let s:arr = nr2char(9655) " Use U+25B7 (▷) for an arrow
  let s:dot = nr2char(8901) " Use U+22C5 (⋅) for a very light dot
  exe "set listchars=tab:"    . s:arr . s:dot
  exe "set listchars+=trail:" . s:dot
  if version > 700
    exe "set listchars+=nbsp:"  . s:dot
  endif
endif
set number                  " Number the lines
set numberwidth=1           " Use 1 col plus 1 space for numbers, grow as needed

"""" Windows
set noequalalways           " Don't automatically resize all windows to be equal
set hidden                  " Hide any buffer not in a window
if exists(":tab")           " Try moving to another window when changing buffers
  set switchbuf=useopen,
               \usetab
else                        " Try other windows, and other tabs if available
  set switchbuf=useopen
endif
set splitright              " New windows open right of the current one

"""" Messages, Info, Status
set shortmess+=a            " Use [+] [RO] [w] for modified, read-only, modified
set showcmd                 " Display what command is waiting for an operator
set ruler                   " Show pos below the win if there's no status line
set laststatus=2            " Always show statusline, even if only 1 window
set report=0                " Notify me whenever any lines have changed
set confirm                 " Y-N-C prompt if closing with unsaved changes
set vb t_vb=                " Disable visual bell!  I hate that flashing.
let &statusline = '%<%f%{&mod?"[+]":""}%r%{&fenc !~ "^$\\|utf-8" || &bomb ? "[".&fenc.(&bomb?"-bom":"")."]" : ""}%=%{exists("actual_curbuf")&&bufnr("")==actual_curbuf?CountMatches(1):""} %15.(%l,%c%V %P%)'

"""" Editing
set backspace=2             " Backspace over autoindent, EOL, and BOL
if version > 700
  set completeopt-=preview  " Don't show preview menu for tags
endif
set infercase               " Try to guess at case for insertions if not a match
set showmatch               " Briefly jump to the previous matching paren
set matchtime=2             " For .2 seconds
set formatoptions+=n        " gq recognizes numbered lists, and will try to
set formatoptions+=1        " break before, not after, a 1 letter word

"""" Coding
set formatoptions-=tc       " I can format for myself, thank you very much
set expandtab               " When I press tab, insert spaces
set shiftwidth=2            " Each tab is represented with 2 spaces for indents
set softtabstop=2           " As well as for pressing <TAB>
set tags=./tags;/home       " Tags file can be ./tags, ../tags, ..., /home/tags.
set showfulltag             " Show more information while completing tags
filetype indent on          " Use filetype-specific indenting where available
filetype plugin on          " Also use filetype plugins
syntax on                   " Turn on syntax highlighting
let g:lisp_rainbow=1        " Rainbow parentheses by depth in lisp files
let g:is_posix=1            " I won't work on systems where /bin/sh isn't POSIX

" And turn off automatic completion for C++, I'll ask for it if I want it.
let OmniCpp_MayCompleteDot = 0
let OmniCpp_MayCompleteArrow = 0

"""" Folding
set foldmethod=syntax       " By default, use syntax to determine folds
set foldlevelstart=99       " All folds open by default

"""" Reading/Writing
set backup                  " Make backups of files not matching 'backupskip'
set noautowrite             " This should be default, but I worry...
set updatetime=2000         " Timeout for swapfile writes and CursorHold autocmd

"""" Command Line
set wildmenu                " Menu completion in command mode (ex: ":e <tab>")
set wcm=<C-Z>               " Ctrl-Z in a mapping acts like <tab> on cmdline
source $VIMRUNTIME/menu.vim " Load menus, even when non-gui, use <f4> to display
map <F4> :emenu <C-Z>

"""" Multi-byte
set encoding=utf-8

""" Autocommands
if has("autocmd")
  augroup vimrcEx
  au!
  " In plain-text files and svn commit buffers, wrap automatically at 78 chars
  au FileType text,svn setlocal tw=78 fo+=t

  " In all files, try to jump back to the last spot cursor was in before exiting
  au BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif

  " When opening a file, set fdm to something sane for that filetype.
  au BufReadPre * setlocal foldmethod=syntax
  au BufReadPre *.xml,*.xsd setlocal foldmethod=indent

  " Use :make to check a script with perl
  au FileType perl set makeprg=perl\ -c\ %\ $* errorformat=%f:%l:%m

  " Use :make to compile c, even without a makefile
  au FileType c,cpp if glob('Makefile') == "" | let &mp="gcc -o %< %" | endif

  " Switch to the directory of the current file, unless it's a help file.
  au BufEnter * if &ft != 'help' | silent! cd %:p:h | endif

  " Insert Vim-version as X-Editor in mail headers
  au FileType mail sil 1  | call search("^$")
               \ | sil put! ='X-Editor: Vim-' . Version()

  augroup END
endif

""" Colorscheme
if $COLORSCHEME == "light" && (&t_Co == 256 || has('gui_running'))
  colorscheme autumnleaf  " 256 color light scheme
elseif $COLORSCHEME == "light"
  colorscheme biogoo      " 16 color light scheme
elseif &t_Co == 256 || has('gui_running')
  colorscheme brookstream " 256 color dark scheme
else
  colorscheme torte       " 16 color dark scheme
endif

""" Key Mappings

" Make [[ and ]] work even if the { is not in the first column
nnoremap <silent> [[ :call search('^\S\@=.*{$', 'besW')<CR>
nnoremap <silent> ]] :call search('^\S\@=.*{$', 'esW')<CR>
onoremap <expr> [[ (search('^\S\@=.*{$', 'ebsW') && (setpos("''", getpos('.'))
                  \ <bar><bar> 1) ? "''" : "\<ESC>")
onoremap <expr> ]] (search('^\S\@=.*{$', 'esW') && (setpos("''", getpos('.'))
                  \ <bar><bar> 1) ? "''" : "\<ESC>")

" Use \sq to squeeze blank lines with :Squeeze, defined below
nnoremap <leader>sq :Squeeze<CR>

" In visual mode, \box draws a box around the highlighted text.
vnoremap <leader>box <ESC>:call <SID>BoxIn()<CR>gvlolo

" I'm sorry.  :(  Some Emacs bindings for the command window
cnoremap <C-A>     <Home>
cnoremap <ESC>b    <S-Left>
cnoremap <ESC>f    <S-Right>
cnoremap <ESC><BS> <C-W>

" Extra functionality for some existing commands:
" <C-6> switches back to the alternate file and the correct column in the line.
nnoremap <C-6> <C-6>`"

" CTRL-g shows filename and buffer number, too.
nnoremap <C-g> 2<C-g>

" <C-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :nohl<CR><C-l>

" In normal/insert mode, ar inserts spaces to right align to &tw or 80 chars
nnoremap <leader>ar :AlignRight<CR>
inoremap <leader>ar <C-\><C-o>:AlignRight<CR>

" In normal/insert mode, ac center aligns the text after it to &tw or 80 chars
nnoremap <leader>ac :AlignCenter<CR>
inoremap <leader>ac <C-\><C-o>:AlignCenter<CR>

" Arg!  I hate hitting q: instead of :q
nnoremap q: q:iq<esc>

" Zoom in on the current window with <leader>z
nmap <leader>z <Plug>ZoomWin

" F10 toggles highlighting lines that are too long
nnoremap <F10> :call <SID>ToggleTooLongHL()<CR>

" F11 toggles line numbering
nnoremap <silent> <F11> :set number! <bar> set number?<CR>

" F12 toggles search term highlighting
nnoremap <silent> <F12> :set hlsearch! <bar> set hlsearch?<CR>

" Q formats paragraphs, instead of entering ex mode
noremap Q gq

" * and # search for next/previous of selected text when used in visual mode
function! s:VSetSearch()
  let old = @"
  norm! gvy
  let @/ = '\V' . substitute(escape(@", '\'), '\n', '\\n', 'g')
  let @" = old
endfunction

vnoremap * :<C-u>call <SID>VSetSearch()<CR>/<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>?<CR>

" <space> toggles folds opened and closed
nnoremap <space> za

" <space> in visual mode creates a fold over the marked range
vnoremap <space> zf

" Pressing an 'enter visual mode' key while in visual mode changes mode.
vmap <C-V> <ESC>`<<C-v>`>
vmap V     <ESC>`<V`>
vmap v     <ESC>`<v`>

" <leader>bsd inserts BSD copyright notice
nnoremap <leader>bsd :BSD<CR>

" <leader>sk inserts skeleton for the current filetype
nnoremap <leader>sk :Skel<CR>

" Insert a modeline on the last line with <leader>ml
nmap <leader>ml :$put =ModelineStub()<CR>

" Tapping C-W twice brings me to previous window, not next.
nnoremap <C-w><C-w> :winc p<CR>

" Get old behavior with <C-w><C-e>
nnoremap <C-w><C-e> :winc w<CR>

" Y behaves like D rather than like dd
nnoremap Y y$

" Backspace should delete to the black hole register, not move left
nnoremap <BS> "_X

" Alt + Arrows
nnoremap  <a-right>  gt
nnoremap  <a-left>   gT

" Ctrl + Arrows
nnoremap  <c-up>     {
nnoremap  <c-down>   }
nnoremap  <c-right>  El
nnoremap  <c-down>   Bh

" Shift + Arrows
nnoremap  <s-up>     Vk
nnoremap  <s-down>   Vj
nnoremap  <s-right>  vl
nnoremap  <s-left>   vh

""" Abbreviations
function! EatChar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunc

iabbr _me Matthew Wozniski (mjw@drexel.edu)<C-R>=EatChar('\s')<CR>
iabbr #i< #include <><left><C-R>=EatChar('\s')<CR>
iabbr #i" #include ""<left><C-R>=EatChar('\s')<CR>
iabbr _t  <C-R>=strftime("%H:%M:%S")<CR><C-R>=EatChar('\s')<CR>
iabbr _d  <C-R>=strftime("%a, %d %b %Y")<CR><C-R>=EatChar('\s')<CR>
iabbr _dt <C-R>=strftime("%a, %d %b %Y %H:%M:%S %z")<CR><C-R>=EatChar('\s')<CR>

""" Cute functions
" Squeeze blank lines with :Squeeze
command! -nargs=0 Squeeze g/^\s*$/,/\S/-j

function! s:ToggleTooLongHL()
  if exists('*matchadd')
    if ! exists("w:TooLongMatchNr")
      let last = (&tw <= 0 ? 80 : &tw)
      let w:TooLongMatchNr = matchadd('ErrorMsg', '.\%>' . (last+1) . 'v', 0)
      echo "   Long Line Highlight"
    else
      call matchdelete(w:TooLongMatchNr)
      unlet w:TooLongMatchNr
      echo "No Long Line Highlight"
    endif
  endif
endfunction

function! s:BoxIn()
  let mode = visualmode()
  if mode == ""
    return
  endif
  let vesave = &ve
  let &ve = "all"
  exe "norm! ix\<BS>\<ESC>"
  if line("'<") > line("'>")
    undoj | exe "norm! gvo\<ESC>"
  endif
  if mode != "\<C-v>"
    let len = max(map(range(line("'<"), line("'>")), "virtcol([v:val, '$'])"))
    undoj | exe "norm! gv\<C-v>o0o0" . (len-2?string(len-2):'') . "l\<esc>"
  endif
  let diff = virtcol("'>") - virtcol("'<")
  if diff < 0
    let diff = -diff
  endif
  let horizm = "+" . repeat('-', diff+1) . "+"
  if mode == "\<C-v>"
    undoj | exe "norm! `<O".horizm."\<ESC>"
  else
    undoj | exe line("'<")."put! ='".horizm."'" | norm! `<k
  endif
  undoj | exe "norm! yygvA|\<ESC>gvI|\<ESC>`>p"
  let &ve = vesave
endfunction

function! ModelineStub()
  let fmt = ' vim: set ts=%d sts=%d sw=%d %s: '
  let x = printf(&cms, printf(fmt, &ts, &sts, &sw, (&et?"et":"noet")))
  return substitute(substitute(x, '\ \+', ' ', 'g'), ' $', '', '')
endfunction

function! AlignRight(...)
  let width = (a:0 == 1 ? a:1 : (&tw <= 0 ? 80 : &tw))
  if getline(".") =~ "^\s*$"
    call setline(".", "")
  else
    exe "norm! i\<C-r>=repeat(' ', width - len(getline('.')))\<CR>\<ESC>l"
  endif
endfunction
com! -nargs=? AlignRight :call AlignRight(<f-args>)

function! AlignCenter(...)
  let width = (a:0 == 1 ? a:1 : (&tw <= 0 ? 80 : &tw))
  let line = substitute(getline('.'), '^ *\(.\{-}\) *$', '\1', '')
  let fw = width - strlen(line)
  let left = (fw / 2 + (fw / 2 * 2 != fw))
  let line = repeat(' ', left) . line
  call setline(".", substitute(line, '\s*$', '', 'g'))
endfunction
com! -range -nargs=? AlignCenter :<line1>,<line2>call AlignCenter(<f-args>)

function! Version()
  let i=1
  while has("patch" . i)
    let i+=1
  endwhile
  return v:version / 100 . "." . v:version % 100 . "." . (i-1)
endfunction
command! Version :echo Version()

command! -nargs=1 -complete=dir Rename saveas <args> | call delete(expand("#"))

"" Stop skipping here
endif

"" vim:fdm=expr:fdl=0
"" vim:fde=getline(v\:lnum)=~'^""'?'>'.(matchend(getline(v\:lnum),'""*')-2)\:'='
