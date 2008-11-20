" SyntaxAttr:  Get syntax attributes of character under cursor
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        Fri, 23 Nov 2007 16:04:35 -0500
" Version:     0.1
" History:     TODO(History Link)

" Abort if running in vi-compatible mode or the user doesn't want us.
if &cp || !has('syntax') " || exists('g:syntaxattr_loaded')
  if !has('syntax')
    echomsg "Not loading SyntaxAttr, vim not compiled with +syntax"
  elseif &cp && &verbose
    echomsg "Not loading SyntaxAttr in compatible mode"
  endif
  finish
endif

let g:syntaxattr_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" Function definitions                                                    {{{1

" Extended version of synIDattr() that returns all information for the given
" id, in all modes, in a dictionary.
function! SynIDattrExt(id)
  let rv = {}
  let rv.id = (a:id == 0 ? hlID("Normal") : a:id)

  let rv.name = synIDattr(rv.id, "name")

  let id = synIDtrans(rv.id)
  for where in [ "gui", "cterm", "term" ]
    let rv[where] = {}
    for what in [ "fg", "bg", "fg#", "bg#", "bold", "italic",
                \ "reverse", "inverse", "underline", "undercurl" ]
      let rv[where][what] = synIDattr(id, what, where)

      if what =~# '^[fb]g$' && rv[where][what] =~ -1
        let rv[where][what] = what
      elseif what =~# '^[fb]g#$' && rv[where][what] =~# '^\(-1\|[fb]g\)$'
        if rv.id == hlID("Normal")
          let rv[where][what] = rv[where][what[0:-2]]
        else
          if ! exists("normdict")
            let normdict = SynIDattrExt(hlID("Normal"))
          endif
          let rv[where][what] = normdict[where][what]
        endif
      endif
    endfor
  endfor

  return rv
endfunction

function! PrintAttrDict(dict)
  let dict = a:dict

  exe 'echohl ' . dict.name
  echon 'xxx'
  echohl None
  echon '  ' . dict.name
  if dict.id != synIDtrans(dict.id)
    echon ' -> ' . synIDattr(synIDtrans(dict.id), "name")
  endif

  echon ' '

  for where in [ 'gui', 'cterm', 'term' ]
    let attrs = []
    for attr in [ 'bold', 'italic', 'reverse', 'undercurl', 'underline' ]
      if dict[where][attr]
        let attrs += [attr]
      endif
    endfor
    if ! empty(attrs)
      echon ' ' . where . '='
    endif
    while ! empty(attrs)
      echon remove(attrs, 0)
      if !empty(attrs)
        echon ','
      endif
    endwhile

    for color in [ 'bg', 'fg' ]
      if dict[where][color] != ''
        echon ' ' . where . color . '=' . dict[where][color]
        if dict[where][color] != dict[where][color.'#']
          echon '(' . dict[where][color.'#'] . ')'
        endif
      endif
    endfor
  endfor
endfunction

function! SyntaxAttrStack(line, col)
  let synstack = synstack(a:line, a:col)

  " Work around a vim 7.1 synstack bug (fixed in 7.2b.023)
  if len(synstack) == 0
    let synstack = []
  endif

  let synstack = [ hlID("Normal") ] + synstack
  let rv = []
  for id in synstack
    let rv += [ SynIDattrExt(id) ]
  endfor
  return rv
endfunction

function! PrintSyntaxAttrStack(stack)
  for group in reverse(a:stack)
    call PrintAttrDict(group)
    echon "\n"
  endfor
endfunction

nmap <silent> <F1> :call PrintAttrDict(SynIDattrExt(synID(line('.'), col('.'), 1)))<CR>

if exists('*synstack')
  nmap <silent> <S-F1> :call PrintSyntaxAttrStack(SyntaxAttrStack(line('.'), col('.')))<CR>
endif

let &cpo = s:savecpo
unlet s:savecpo

" vim:set sw=2 sts=2:
