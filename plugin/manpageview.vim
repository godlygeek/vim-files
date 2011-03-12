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

" Get result of "man | col" as a List
function! s:ReadManPage(topic)
  " MAN_KEEP_FORMATTING:
  " man-db 2.5.0 feature to disable stripping format with `col -p -b -x'.
  " We want to strip these characters ourself if at all possible, because
  " the bsdutils currently available on linux ships a `col' that isn't
  " multibyte aware, and can delete half of a multibyte character when
  " removing backspaces from the file.  Doesn't expand right, either.
  " Note: This should have no effect on non-Linux systems.

  let cmdline = 'env MAN_KEEP_FORMATTING=1 MANPAGER=cat PAGER=cat '
  if exists('g:fit_manpages_to_window') && g:fit_manpages_to_window
    let cmdline .= printf('COLUMNS=%d MANWIDTH=%d ', winwidth(0), winwidth(0))
  endif
  let cmdline .= 'man ' . a:topic . ' 2>/dev/null'
  let cmdline .= ' | col'

  " See if 'col' accepts the '-p' switch
  call system('col -p 2>/dev/null', 'foo')
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
  let page = s:ReadManPage(a:topic)

  if len(page) < 3
    echohl ErrorMsg
    echomsg "No article found matching \"" . a:topic . "\""
    echohl None
    return
  endif

  new
  setlocal noswapfile

  call setline(1, page)

  " Remove any tabs from the man output
  setlocal tabstop=8
  sil retab

  setlocal ro nomod noma bh=wipe ft=man nolist nonu nowrap bt=nofile

  let bufname=''
  if getline(nextnonblank(1)) =~ ')\s*$'
      let bufname = getline(nextnonblank(1))
      let bufname = substitute(bufname, '.\{-}\(\S\+\s*([^)]*)\)\s*$', '\1', '')
  endif

  if !empty(bufname)
      exe 'sil! file! ' . bufname
  else
      try
          exe 'sil! file! ' . fnameescape(a:topic)
      catch
          exe 'sil! file! ' . escape(a:topic)
      endtry
  endif

endfunction

let &cpo = s:keepcpo
