" Aliases:     Attempt alias expansion within mail files
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        Wed, 24 Oct 2007 13:53:43 -0400
" Version:     0.1

" Abort if running in vi-compatible mode or the user doesn't want us.
if &cp || exists('g:aliases_loaded')
  if &cp && &verbose
    echo "Not loading Aliases in compatible mode."
  endif
  finish
endif

let g:aliases_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" Function definitions                                                    {{{1

" Expand email aliases on lines that have a colon before their first space

" Figure out where to start on the first invocation, and find the matching
" aliases on the second.  If the first invocation couldn't find a starting
" string to complete on, we complete all aliases from the address book.
function! Aliases(findstart, base)
  if a:findstart
    return match(getline('.')[0:col('.')-1], '\S*$')
  else
    let rv = []

    let aliasfile = ( exists("g:aliasfile") ? g:aliasfile : "~/.aliases" )
    let aliasfile = substitute(aliasfile, '^\~\ze\/', $HOME, '')

    for alias in readfile(aliasfile)
      if alias =~ '\c^alias\s\+' . a:base
        echomsg alias
        call add(rv, join(split(alias)[2:]))
      endif
    endfor

    return rv
  endif
endfunction

" If the current line is a Headers line (it's above the first blank line),
" we return a key sequence that opens the alias completion menu by calling
" ^X^U, otherwise we return keys that expand to a literal tab, for putting
" real tabs into the message body.
function! s:AliasTab()
  if search('^$', 'bnW') == 0
    return (!pumvisible() ? "\<C-x>" : "") . "\<C-u>"
  endif
  return "\<C-v>\<TAB>"
endfunction

" Autocommands                                                            {{{1

" Automatically bind <TAB> in insert mode to our AliasTab() function for mail
" files, and ^X^U to complete Aliases.
augroup AliasesPlug
  au!
  autocmd FileType mail set cfu=Aliases
  autocmd FileType mail imap <TAB> <plug>AliasTab
augroup END

imap <expr> <plug>AliasTab <SID>AliasTab()

let &cpo = s:savecpo
unlet s:savecpo

" vim:set sw=2 sts=2:
