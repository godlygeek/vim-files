finish
let s:handled_types = []

function! s:Sanitize(name)
  return substitute(a:name, '[^-_[:alnum:]]', '', 'g')
endfunction

let s:handled_types += ["vim"]
function! s:GetSignature_vim(func)
  let func = s:Sanitize(a:func)

  if ! exists("s:functions") || s:functions == {}
    try
      let s:functions = {}
      let file        = split(globpath(&rtp, "doc/eval.txt"), '\n')[0]
      let oldsearch   = getreg("/")
      let searchmode  = getregtype("/")

      " FIXME Should really not require tabs, but it made this so much easier.
      "       Otherwise, it was very tough to keep the window layout while
      "       switching to and from the temp buffer.
      silent tabnew
      setlocal buftype=nofile
      setlocal bufhidden=wipe
      silent 1,$d
      silent exe "0r " . file
      silent 1,/^USAGE/+1d
      silent /^$/,$d
      silent %s/\t\+.*\t\+/\t/
      silent %g/^\t/-1j
      silent %s/\t\+/  /g

      for linenr in range(1, line("$"))
        let line = getline(linenr)
        let func = matchstr(line, '.\{-}\ze(')
        let s:functions[func] = line
      endfor
      bw!

      call setreg("/", oldsearch, searchmode)
    catch
      let s:functions = {}
    endtry
  endif

  if exists("s:functions") && has_key(s:functions, a:func)
    return s:functions[a:func]
  endif

  return ""
endfunction

let s:handled_types += ["c"]
function! s:GetSignature_c(func)
  let func = s:Sanitize(a:func)
  let manpage = system("man 3 " . a:func . " 2>/dev/null | head -n 100")

  " Narrow down the text before we do anything complicated.
  " It's in the synopsis section.
  let manpage = substitute(manpage, '^.\{-}SYNOPSIS\(.\{-}\)DESCRIPTION.*$', '\1', '')

  " Grab it, the word before it, and aything in parens after it, ending at ;
  let manpage = substitute(manpage, '\C.\{-}\([[:alnum:]]*\s\+\S*\<' . a:func . '\>\s*(.\{-})\)\s*;.*', '\1', '')

  " If we didn't manage to match it, return early
  if manpage !~ '\C\<' . a:func . '\>'
    return ""
  endif

  " Squeeze spaces
  let manpage = substitute(manpage, '\_s\+', ' ', 'g')

  " Sanitize non-printing characters out.
  let manpage = substitute(manpage, '[^[:print:]]', '', 'g')

  return manpage
endfunction

" set statusline=%<%f\ %h%m%r%(\ %#StatusLineNC#%{getbufvar('%','AutoSignature_signature')}%*%)%=%-14.(%l,%c%V%)\ %P

function! AutoSignature(func)
  if count(s:handled_types, &ft) != 0
    try
      let b:AutoSignature_signature = s:GetSignature_{&ft}(a:func)
    catch
      let b:AutoSignature_signature = ""
    endtry
  endif
endfunction

function! s:PickCmd()
  if count(s:handled_types, &ft) != 0
    if &ch < 2
      let s:chsave = &ch
      set ch=2
    endif
  else
    if exists("s:chsave")
      let &ch = s:chsave
      unlet s:chsave
    endif
  endif
endfunction

augroup AutoSignature
  au!
  autocmd InsertLeave * let b:AutoSignature_signature=""
augroup END

inoremap <silent> ( <C-r>=AutoSignature(matchstr(getline(".")[0:col(".") - 2], '\i\+\ze.\?$'))<CR><BS>(
inoremap <silent> ) <C-r>=setbufvar('%', 'AutoSignature_signature', '')<CR><BS>)
