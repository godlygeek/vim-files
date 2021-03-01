" Author:  Matt Wozniski (godlygeek@gmail.com)
"
" Feel free to do whatever you would like with this file.

""" Settings
"""" Locations searched for scripts
call pathogen#infect('runtimes')

"""" Mouse, Keyboard, Terminal
set mouse=nv                " Allow mouse use in normal and visual mode.
set timeoutlen=2000         " Wait 2 seconds before timing out a mapping
set lazyredraw              " Avoid redrawing the screen mid-command.

""""" Titlebar
set title                   " Turn on titlebar support

"  Titlebar string: hostname> ${PWD:s/^$HOME/~} || (view|vim) filename ([+]|)
let &titlestring  = hostname() . '> ' . '%{expand("%:p:~:h")}'
                \ . ' || %{&ft=~"^man"?"man":&ro?"view":"vim"} %f %m'

"""" Moving Around/Editing
set whichwrap=b,s,h,l,<,>   " <BS> <Space> h l <Left> <Right> can change lines
set virtualedit=block       " Let cursor move past the last char in <C-v> mode
set scrolloff=3             " Keep 3 context lines above and below the cursor
set showmatch               " Briefly jump to a paren once it's balanced
set matchtime=2             " (for only .2 seconds).

"""" Searching and Patterns
set ignorecase              " Default to using case insensitive searches,
set smartcase               " unless uppercase letters are used in the regex.

"""" Windows, Buffers
set noequalalways           " Don't keep resizing all windows to the same size
set hidden                  " Hide modified buffers when they are abandoned
set swb=useopen,usetab      " Allow changing tabs/windows for quickfix/:sb/etc
set splitright              " New windows open to the right of the current one

"""" Insert completion
set completeopt=menuone     " Show the completion menu even if only one choice

"""" Text Formatting
set formatoptions=q         " Format text with gq, but don't format as I type.
set formatoptions+=j        " When joining lines, remove comment leaders.
set formatoptions+=n        " gq recognizes numbered lists, and will try to
set formatoptions+=1        " break before, not after, a 1 letter word

"""" Display
set number                  " Display line numbers
set numberwidth=1           " using only 1 column (and 1 space) while possible
set signcolumn=number       " and drawing signs in the number column
set display+=uhex           " Use <03> rather than ^C for non-printing chars
set inccommand=nosplit      " Preview :s commands incrementally as you type

" In visual mode, make the cursor an underbar 15% of the cell high,
" and make it blink off for 100ms every 300ms.
set guicursor+=v:hor15-blinkon300-blinkoff100-blinkwait300

set list                    " visually represent certain invisible characters:
set listchars=              " Don't use the default markers; instead:
set listchars+=nbsp:⋅       " Use U+22C5 DOT OPERATOR for non-breaking spaces
set listchars+=trail:⋅      " and for trailing spaces at EOL,
set listchars+=tab:▷⋅       " and U+25B7 WHITE RIGHT-POINTING TRIANGLE plus
                            " zero or more DOT OPERATOR for a tab character.

"""" Messages, Info, Status
set confirm                 " Y-N-C prompt if closing with unsaved changes.
set report=0                " : commands always print changed line count.
set shortmess+=a            " Use [+]/[RO]/[w] for modified/readonly/written.

let &statusline = '%<%f%{&mod?"[+]":""}%r%'
 \ . '{&fenc !~ "^$\\|utf-8" || &bomb ? "[".&fenc.(&bomb?"-bom":"")."]" : ""}'
 \ . '%='
 \ . '%15.(%l,%c%V %P%)'

"""" Tabs/Indent Levels
set tabstop=8               " Real tab characters are 8 spaces wide,
set shiftwidth=4            " but an indent level is 4 spaces wide.
set softtabstop=4           " <BS> over an autoindent deletes all 4 spaces.
set expandtab               " Use spaces, not tabs, for autoindent/tab key.

"""" Tags
set showfulltag             " Show more information while completing tags.
set cscopetag               " When using :tag, <C-]>, or "vim -t", try cscope:
set cscopetagorder=0        " try ":cscope find g foo" and then ":tselect foo"

"""" Reading/Writing
set noautowrite             " Never write a file unless I request it.
set noautowriteall          " NEVER.
set noautoread              " Don't automatically re-read changed files.

"""" Backups/Swap Files
set writebackup             " Make a backup of the original file when writing
set backup                  " and don't delete it after a succesful write.
set backupskip=             " There are no files that shouldn't be backed up.
set updatetime=2000         " Write swap files after 2 seconds of inactivity.
set backupext=~             " Backup for "file" is "file~"
set backupdir^=~/.backup    " Backups are written to ~/.backup/ if possible.

"""" Command Line
set wildmenu                " Menu completion in command mode on <Tab>

"""" Per-Filetype Scripts
" NOTE: These define autocmds, so they should come before any other autocmds.
"       That way, a later autocmd can override the result of one defined here.
filetype on                 " Enable filetype detection,
filetype indent on          " use filetype-specific indenting where available,
filetype plugin on          " also allow for filetype-specific plugins,
syntax on                   " and turn on per-filetype syntax highlighting.

""" Plugin Settings
let lisp_rainbow=1          " Color parentheses by depth in LISP files.
let is_posix=1              " Assume /bin/sh is POSIX compliant by default.
let vim_indent_cont=4       " Spaces to add for vimscript continuation lines
let no_buffers_menu=1       " Disable 'Buffers' menu
let surround_indent=1       " Automatically reindent text surround.vim affects
let fastfold_minlines=0     " Don't update syntax folds in insert mode

" When using a gvim-only colorscheme in terminal vim with CSApprox
"   - Disable the bold and italic attributes completely
"   - Use the color specified by 'guisp' as the foreground color.
let g:CSApprox_attr_map = { 'bold' : '', 'italic' : '', 'sp' : 'fg' }

""" Autocommands
augroup vimrcEx
au!
" In plain-text files and svn commit buffers, wrap automatically at 78 chars
au FileType text,svn setlocal tw=78 fo+=t

" Try to jump to the last spot the cursor was at in a file when reading it.
au BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" Use :make to compile C, even without a makefile
au FileType c   if glob('[Mm]akefile') == "" | let &mp="gcc -o %< %" | endif

" Use :make to compile C++, too
au FileType cpp if glob('[Mm]akefile') == "" | let &mp="g++ -o %< %" | endif

" When reading a file, :cd to its parent directory unless it's a help file.
au BufEnter * if &ft != 'help' | silent! cd %:p:h | endif

" Use syntaxcomplete as a default omnifunc for languages without one
au Filetype * let &l:ofu = (len(&ofu) ? &ofu : 'syntaxcomplete#Complete')

" zfunctions are in the zsh language
au BufRead,BufNewFile ~/.zsh/.zfunctions/[^.]* setf zsh

" Update the system clipboard after yanking in visual mode.
autocmd TextYankPost *
  \ if v:event.visual && v:operator == 'y' |
  \   let @+ = getreg(v:event.regname) |
  \ endif

" Flash anything that was just yanked, except in visual mode.
autocmd TextYankPost *
  \ lua vim.highlight.on_yank {on_visual = false, higroup = Search}

augroup END

""" Colorscheme
colorscheme autumnleaf  " 256 color light scheme
"colorscheme brookstream " 256 color dark scheme

""" Key Mappings

" Make [[ and ]] work even if the { is not in the first column
nnoremap <silent> [[ :call search('^\S\@=.*{\s*$', 'besW')<CR>
nnoremap <silent> ]] :call search('^\S\@=.*{\s*$', 'esW')<CR>
onoremap <expr> [[ (search('^\S\@=.*{\s*$', 'ebsW') && (setpos("''", getpos('.'))
                  \ <bar><bar> 1) ? "''" : "\<ESC>")
onoremap <expr> ]] (search('^\S\@=.*{\s*$', 'esW') && (setpos("''", getpos('.'))
                  \ <bar><bar> 1) ? "''" : "\<ESC>")

" Some Emacs bindings for the command window
cnoremap <C-A>     <Home>
cnoremap <ESC>b    <S-Left>
cnoremap <ESC>f    <S-Right>
cnoremap <ESC><BS> <C-W>

" Extra functionality for some existing commands:
" <C-6> switches back to the alternate file and the correct column in the line.
nnoremap <C-6> <C-6>`"

" Swap ` and ' in normal mode - I normally want ``, but '' is easier to hit
nnoremap ` '
nnoremap ' `

" CTRL-g shows filename and buffer number, too.
nnoremap <C-g> 2<C-g>

" <C-l> redraws the screen and removes search highlighting and LSP diagnostics.
nnoremap <silent> <C-l> <cmd>nohl\|lua vim.lsp.diagnostic.clear(0)<CR><C-l>

" In normal/insert mode, ar inserts spaces to right align to &tw or 80 chars
nnoremap <leader>ar :AlignRight<CR>

" In normal/insert mode, ac center aligns the text after it to &tw or 80 chars
nnoremap <leader>ac :center<CR>

" Zoom in on the current window with <leader>z
nmap <leader>z <Plug>ZoomWin

" F10 toggles highlighting lines that are too long
nnoremap <F10> :call <SID>ToggleTooLongHL()<CR>

" F11 toggles line numbering
nnoremap <silent> <F11> :set number! <bar> set number?<CR>

" F12 toggles search term highlighting
nnoremap <silent> <F12> :set hlsearch! <bar> set hlsearch?<CR>

" <space> toggles folds opened and closed
nmap <space> za

" <space> in visual mode creates a fold over the marked range
vmap <space> zf

" Pressing an 'enter visual mode' key while in visual mode changes mode.
vmap <C-V> <ESC>`<<C-v>`>
vmap V     <ESC>`<V`>
vmap v     <ESC>`<v`>

" Make { and } in visual mode stay in the current column unless 'sol' is set.
vnoremap <expr> { line("'{") . 'G'
vnoremap <expr> } line("'}") . 'G'

" <leader>bsd inserts BSD copyright notice
nnoremap <leader>bsd :BSD<CR>

" <leader>sk inserts skeleton for the current filetype
nnoremap <leader>sk :Skel<CR>

" Insert a modeline on the last line with <leader>ml
nmap <leader>ml :$put =<SID>ModelineStub()<CR>

" Tapping C-W twice brings me to previous window, not next.
nnoremap <C-w><C-w> :winc p<CR>

" Get old behavior with <C-w><C-e>
nnoremap <C-w><C-e> :winc w<CR>

" Y behaves like D rather than like dd
nnoremap Y y$

" ctrl-backspace deletes the last word when inserting
imap <C-_> <C-w>

""" Abbreviations
function! s:InsertCloseBraceAfterCR(open, close)
    let c = nr2char(getchar(0))
    if c == "\r"
        return a:open . c . a:close . "\<C-o>O"
    endif
    return a:open . c
endfunction

function! s:EatChar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunc

iabbr _me Matt Wozniski <mwozniski@bloomberg.net>
iabbr _dt <C-R>=strftime("%a, %d %b %Y %H:%M:%S %z")<CR>
iabbr #i< #include <><left><C-R>=<SID>EatChar('\s')<CR>
iabbr #i" #include ""<left><C-R>=<SID>EatChar('\s')<CR>
iabbr { <C-r>=<SID>InsertCloseBraceAfterCR("{", "}")<CR>

""" Cute functions

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

function! s:ModelineStub()
  let fmt = ' vim: set ts=%d sts=%d sw=%d %set: '
  let x = printf(&cms, printf(fmt, &ts, &sts, &sw, (&et?"":"no")))
  return substitute(substitute(x, '\ \+', ' ', 'g'), ' $', '', '')
endfunction

" Replace tabs with spaces in a string, preserving alignment.
function! s:Retab(string)
  let rv = ''
  let i = 0

  for char in split(a:string, '\zs')
    if char == "\t"
      let rv .= repeat(' ', &ts - i)
      let i = 0
    else
      let rv .= char
      let i = (i + 1) % &ts
    endif
  endfor

  return rv
endfunction

" Right align the portion of the current line to the right of the cursor.
" If an optional argument is given, it is used as the width to align to,
" otherwise textwidth is used if set, otherwise 80 is used.
function! s:AlignRight(...)
  if getline('.') =~ '^\s*$'
    call setline('.', '')
  else
    let line = s:Retab(getline('.'))

    let prefix = matchstr(line, '.*\%' . virtcol('.') . 'v')
    let suffix = matchstr(line, '\%' . virtcol('.') . 'v.*')

    let prefix = substitute(prefix, '\s*$', '', '')
    let suffix = substitute(suffix, '^\s*', '', '')

    let len  = len(substitute(prefix, '.', 'x', 'g'))
    let len += len(substitute(suffix, '.', 'x', 'g'))

    let width  = (a:0 == 1 ? a:1 : (&tw <= 0 ? 80 : &tw))

    let spaces = width - len

    call setline('.', prefix . repeat(' ', spaces) . suffix)
  endif
endfunction
com! -nargs=? AlignRight :call <SID>AlignRight(<f-args>)

command! -nargs=1 -complete=dir Rename saveas <args> | call delete(expand("#"))

lua <<EOF
vim.cmd('packadd nvim-lspconfig')
require'lspconfig'.clangd.setup{}
require'lspconfig'.pyls.setup{
  settings = {
    pyls = {
      configurationSources = {"flake8"};
    }
  }
}
EOF

nnoremap <C-up> <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <C-down> <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

nnoremap <Leader>k <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <Leader>j <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <Leader>x <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <Leader>d <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <Leader>f <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <Leader>h <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <Leader>n <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <Leader>r <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <Leader>o <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <Leader>l <cmd>lua vim.lsp.diagnostic.set_loclist()<CR>

hi link LspDiagnosticsVirtualTextError Comment
hi link LspDiagnosticsVirtualTextWarning Comment
hi link LspDiagnosticsVirtualTextInformation Comment
hi link LspDiagnosticsVirtualTextHint Comment

lua <<EOF
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    -- Enable virtual text, override spacing to 4
    virtual_text = {
      prefix = 'ᐊ',
    },
  }
)
EOF

" In vim the wildmenu is displayed horizontally, with left and right choosing
" files and up and down descending or ascending the directory hierarchy. In
" neovim it's displayed vertically instead, but the keybindings aren't changed
" accordingly. Fix them.
cnoremap <expr> <Down>  wildmenumode() ? "\<Right>" : "\<Down>"
cnoremap <expr> <Right> wildmenumode() ? "\<Down>"  : "\<Right>"
cnoremap <expr> <Up>    wildmenumode() ? "\<Left>"  : "\<Up>"
cnoremap <expr> <Left>  wildmenumode() ? "\<Up>"    : "\<Left>"

" Make each <C-u> and <C-w> undoable.
inoremap <C-u> <C-g>u<C-u>
inoremap <C-w> <C-g>u<C-w>
