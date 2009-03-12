if &cp || exists("g:loaded_manpageview")
 finish
endif
let g:loaded_manpageview = "v17g"
let s:keepcpo            = &cpo
set cpo&vim

com! -nargs=* Man call s:ManPageView(<q-args>)

function s:GetArticle(topic)
  let file = (split(system("man -w ".a:topic." 2>/dev/null"), '\n') + [""])[0]
  let basename = substitute(file, '.*/', '', '')
  return matchlist(basename, '\(.\{-}\)\.\([^.]*\)\(\.gz\)\=$')[1:2]
endfunction

function s:ManPageView(topic)
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
  " As of 2008/11/09, bsdmainutils provides a `col' that doesn't understand
  " multibyte, and bsdutils provides a `col' that understand multibyte, but
  " glibc seems to think that '‐' is an invalid character.  So, I'm using
  " a new option that was introduced in man-db 2.5.0 to disable stripping
  " format characters with `col', combined with what seems to be an
  " implementation detail of bsdmainutils `col' that it will reorder
  " characters, so that "ab^H^Hxyz" becomes the equivalent "a^Hb^Hxyz".
  " This means I can run `col' to reorder the output and expand tabs to spaces
  " without stripping the ^H's itself, and then use `sed' to remove the
  " backspaces.
  exe 'sil r!MAN_KEEP_FORMATTING=1 man ' a:topic '| col -p -x | sed -e "s/^\x08*//g" -e "s/.\x08//g"'
  sil 0d
  setlocal ro nomod noma bh=wipe ft=man nolist nonu nowrap bt=nofile
endfunction

let &cpo = s:keepcpo
