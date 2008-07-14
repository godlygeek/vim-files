" File: unicodename.vim
" Author: Marius Gedminas <marius@gedmin.as>
" Version: 0.1
" Last Modified: 2007-12-21
"
" Overview
" --------
" Defines a command :UnicodeName which shows the Unicode name of a character
" under cursor (e.g. U+0055 LATIN CAPITAL LETTER U).
"
" Requirements
" ------------
" Vim with Python support.

" Bugs
" ----
" Assumes that 'encoding' is UTF-8.
"
" Installation
" ------------
" Copy this file into $HOME/.vim/plugin/
"
" Map the command to a key for extra convenience, e.g.
"   map <F12> :UnicodeName<CR>

if !has("python")
  finish
endif

python << EOS
import vim
import unicodedata

def char_under_cursor():
    col = vim.current.window.cursor[1]
    return vim.current.line[col:].decode('UTF-8')[0]

def format_char_name(c):
    return 'U+%04X %s' % (ord(c), unicodedata.name(c, ''))
EOS

command! UnicodeName  python print format_char_name(char_under_cursor())
