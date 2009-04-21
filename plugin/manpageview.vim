" TODO:  Is there any way to support the :tab modifier?
"        Reuse existing windows where possible
"        Make a map on K?
if &cp || exists("g:loaded_manpageview")
 finish
endif
let g:loaded_manpageview = "v17g"
let s:keepcpo            = &cpo
set cpo&vim

com! -nargs=* Man call s:ManPageView(<q-args>)

function! s:GetArticle(topic)
  let file = (split(system("man -w ".a:topic." 2>/dev/null"), '\n') + [""])[0]
  let basename = substitute(file, '.*/', '', '')
  return matchlist(basename, '\(.\{-}\)\.\([^.]*\)\(\.gz\)\=$')[1:2]
endfunction

" Get result of "man | col" as a List
function! s:ReadManPage(topic)
  " MAN_KEEP_FORMATTING:
  " man-db 2.5.0 feature to disable stripping format with `col -p -b -x'.
  " We want to strip these characters ourself if at all possible, because
  " the bsdutils currently available on linux ships a `col' that isn't
  " multibyte aware, and can delete half of a multibyte character when
  " removing backspaces from the file.  Doesn't expand right, either.
  " Note: This should have no effect on non-Linux systems.

  let cmdline = 'env MAN_KEEP_FORMATTING=1 MANPAGER= PAGER= man ' . a:topic
  let cmdline .= ' | col'

  " See if 'col' accepts the '-p' switch
  call system('col -p', 'foo')
  if v:shell_error == 0
    let cmdline .= ' -p'
  endif

  " Call man
  let rv = split(system(cmdline), '\n')

  " Remove ^H ourself (col can't be trusted to do it on Linux)
  for i in range(len(rv))
    while rv[i] =~ '\%x08'
      let rv[i] = substitute(rv[i], '^[[:backspace:]]*', '', '')
      let rv[i] = substitute(rv[i], '[^[:backspace:]][[:backspace:]]', '', 'g')
    endwhile
  endfor

  return rv
endfunction

function! s:ManPageView(topic)
  new
  let article = s:GetArticle(a:topic)
  if article == []
    echohl ErrorMsg
    echomsg "No article found matching \"" . a:topic . "\""
    echohl None
    return
  endif
  exe 'sil! file!' escape(article[0].'('.article[1].')', ' \')
  setlocal noswapfile

  let page = s:ReadManPage(a:topic)

  call setline(1, page)

  " Remove any tabs from the man output
  setlocal tabstop=8
  sil retab

  setlocal ro nomod noma bh=wipe ft=man nolist nonu nowrap bt=nofile
endfunction

let &cpo = s:keepcpo
