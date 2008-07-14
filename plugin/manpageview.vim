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
  return matchlist(basename, '\(.\{-}\)\.\(.\{-}\)\(\.gz\)\=$')[1:2]
endfunction

function s:ManPageView(topic)
  new
  let article = s:GetArticle(a:topic)
  if article == []
    echoerr "No article found matching \"" . a:topic . "\""
    return
  endif
  exe 'sil! file!' escape(article[0].'('.article[1].')', ' \')
  setlocal noswapfile
  exe 'sil r!man' a:topic '| col -bx'
  sil 0d
  setlocal ro nomod bh=wipe ft=man nolist nonu nowrap bt=nofile
endfunction

let &cpo = s:keepcpo

finish

" manpageview.vim : extra commands for manual-handling
" Author:	Charles E. Campbell, Jr.
" Date:		Sep 07, 2007
" Version:	17g	ASTRO-ONLY
"
" Please read :help manpageview for usage, options, etc
"
" GetLatestVimScripts: 489 1 :AutoInstall: manpageview.vim

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_manpageview")
  finish
endif
let g:loaded_manpageview = "v17g"
let s:keepcpo            = &cpo
set cpo&vim
"DechoTabOn

" ---------------------------------------------------------------------
" Set up default manual-window opening option: {{{1
if !exists("g:manpageview_winopen")
 let g:manpageview_winopen= "hsplit"
elseif g:manpageview_winopen == "only" && !has("mksession")
 echomsg "***g:manpageview_winopen<".g:manpageview_winopen."> not supported w/o +mksession"
 let g:manpageview_winopen= "hsplit"
endif

" ---------------------------------------------------------------------
" Public Interface: {{{1
if !hasmapto('<Plug>ManPageView') && &kp =~ '^man\>'
  nmap <unique> K <Plug>ManPageView
endif
nmap <silent> <script> <Plug>ManPageView  :<c-u>call <SID>ManPageView(1,v:count,expand("<cWORD>"))<CR>

com! -nargs=* -count=0	Man call s:ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	HMan let g:manpageview_winopen="hsplit"|call s:ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	OMan let g:manpageview_winopen="only"  |call s:ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	RMan let g:manpageview_winopen="reuse" |call s:ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	VMan let g:manpageview_winopen="vsplit"|call s:ManPageView(0,<count>,<f-args>)

" ---------------------------------------------------------------------
" Default Variable Values: {{{1
if !exists("g:manpageview_iconv")
 if executable("iconv")
  let s:iconv= "iconv -c"
 else
  let s:iconv= ""
 endif
else
 let s:iconv= g:manpageview_iconv
endif
if s:iconv != ""
 let s:iconv= "| ".s:iconv
endif
if !exists("g:manpageview_pgm")
 let g:manpageview_pgm= "man"
endif
if !exists("g:manpageview_options")
 let g:manpageview_options= ""
endif
if !exists("g:manpageview_pgm_i")
 let g:manpageview_pgm_i     = "info"
 let g:manpageview_options_i = "--output=-"
 let g:manpageview_syntax_i  = "info"
 let g:manpageview_K_i       = "<sid>ManPageInfo(0)"
 let g:manpageview_init_i    = "call ManPageInfoInit()"

 let s:linkpat1 = '\*[Nn]ote \([^():]*\)\(::\|$\)' " note
 let s:linkpat2 = '^\* [^:]*: \(([^)]*)\)'         " filename
 let s:linkpat3 = '^\* \([^:]*\)::'                " menu
 let s:linkpat4 = '^\* [^:]*:\s*\([^.]*\)\.$'      " index
endif
if !exists("g:manpageview_pgm_pl")
 let g:manpageview_pgm_pl     = "perldoc"
 let g:manpageview_options_pl = ";-f;-q"
endif
if !exists("g:manpageview_pgm_php") && executable("links")
 let g:manpageview_pgm_php    = "links http://www.php.net/"
 let g:manpageview_nospace_php= 1
 let g:manpageview_syntax_php = "manphp"
 let g:manpageview_K_php      = "<sid>ManPagePhp()"
endif
if exists("g:manpageview_hypertext_tex") && executable("links") && !exists("g:manpageview_pgm_tex")
 let g:manpageview_pgm_tex    = "links ".g:manpageview_hypertext_tex
 let g:manpageview_lookup_tex = "<sid>ManPageTexLookup"
 let g:manpageview_K_tex      = "<sid>ManPageTex()"
endif
if has("win32") && !exists("g:manpageview_rsh")
 let g:manpageview_rsh= "rsh"
endif

" =====================================================================
"  Functions: {{{1

" ---------------------------------------------------------------------
" ManPageView: view a manual-page, accepts three formats: {{{2
"    :call s:ManPageView(viamap,"topic")
"    :call s:ManPageView(viamap,booknumber,"topic")
"    :call s:ManPageView(viamap,"topic(booknumber)")
"
"    viamap=0: called via a command
"    viamap=1: called via a map
"    bknum   : if non-zero, then its the book number of the manpage (default=1)
"              if zero, but viamap==1, then use lastline-firstline+1
fun! s:ManPageView(viamap,bknum,...) range
"  call Dfunc("ManPageView(viamap=".a:viamap." bknum=".a:bknum.") a:0=".a:0)
  set lz
  let manpageview_fname = expand("%")
  call s:MPVSaveSettings()

  if a:0 > 0
   " fix topic
   if &ft != "info"
    let topic= substitute(a:1,'[^-a-zA-Z.0-9_:].*$','','')
"    call Decho("a:1<".a:1."> topic<".topic."> (after fix)")
   else
   	let topic= a:1
"	call Decho("topic<".topic.">")
   endif
  endif

  " interpret the input arguments - set up manpagetopic and manpagebook
  if a:0 > 0 && strpart(topic,0,1) == '"'
   let topic= topic
   " merge quoted arguments:  Man "some topic here"
"   call Decho('case a:0='.a:0." strpart(".topic.",0,1)<".strpart(topic,0,1))
   let manpagetopic = strpart(topic,1)
"   call Decho("manpagetopic<".manpagetopic.">")
   if a:bknum > 0
   	let manpagebook= string(a:bknum)
   else
    let manpagebook= ""
   endif
"   call Decho("manpagebook<".manpagebook.">")
   let i= 2
   while i <= a:0
   	let manpagetopic= manpagetopic.' '.a:{i}
	if a:{i} =~ '"$'
	 break
	endif
   	let i= i + 1
   endwhile
   let manpagetopic   = strpart(manpagetopic,0,strlen(manpagetopic)-1)
"   call Decho("merged quoted arguments<".manpagetopic.">")

  elseif a:0 == 0
"   call Decho('case a:0='.a:0)
   if exists("g:ManCurPosn") && has("mksession")
"    call Decho("ManPageView: a:0=".a:0."  g:ManCurPosn exists")
	call s:ManRestorePosn()
   else
    echomsg "***usage*** :Man topic  -or-  :Man topic nmbr"
"    call Decho("ManPageView: a:0=".a:0."  g:ManCurPosn doesn't exist")
   endif
   call s:MPVRestoreSettings()
"   call Dret("ManPageView")
   return

  elseif a:0 == 1
   " ManPageView("topic") -or-  ManPageView("topic(booknumber)")
"   call Decho("case a:0=".a:0." (topic  -or-  topic(booknumber))")
"   call Decho("ManPageView: a:0=".a:0." topic<".topic.">")
   if topic =~ "("
	" abc(3)
	let a1 = substitute(topic,'[-+*/;,.:]\+$','','e')
	if a1 =~ '[,"]'
     let manpagetopic= substitute(a1,'[(,"].*$','','e')
	else
     let manpagetopic= substitute(a1,'^\(.*\)(\d\+[A-Z]\=),\=.*$','\1','e')
     let manpagebook = substitute(a1,'^.*(\(\d\+\)[A-Z]\=),\=.*$','\1','e')
	endif

   else
    " ManPageView(booknumber,"topic")
    let manpagetopic= topic
    if a:viamap == 1 && a:lastline > a:firstline
     let manpagebook= string(a:lastline - a:firstline + 1)
    elseif a:bknum > 0
     let manpagebook= string(a:bknum)
	else
     let manpagebook= ""
    endif
   endif

  else
   " 3 abc  -or-  abc 3
"   call Decho("case a:0=".a:0." (3 abc  -or-  abc 3)")
   if     topic =~ '^\d\+'
    let manpagebook = topic
    let manpagetopic= a:2
   elseif a:2 =~ '^\d\+$'
    let manpagebook = a:2
    let manpagetopic= topic
   elseif topic == "-k"
"    call Decho("user requested man -k")
    let manpagetopic = a:2
    let manpagebook  = "-k"
   else
	" default: topic book
    let manpagebook = a:2
    let manpagetopic= topic
   endif
  endif
"  call Decho("manpagetopic<".manpagetopic.">")
"  call Decho("manpagebook <".manpagebook.">")

  " for the benefit of associated routines (such as InfoIndexLink())
  let s:manpagetopic = manpagetopic
  let s:manpagebook  = manpagebook

  " default program g:manpageview_pgm=="man" may be overridden
  " if an extension is matched
  if exists("g:manpageview_pgm")
   let pgm = g:manpageview_pgm
  else
   let pgm = ""
  endif
  let ext = ""
  if manpagetopic =~ '\.'
   let ext = substitute(manpagetopic,'^.*\.','','e')
  endif

  " infer the appropriate extension based on the filetype
  if ext == ""
"   call Decho("attempt to infer on filetype<".&ft.">")

   " filetype: vim
   if &ft == "vim"
   	if g:manpageview_winopen == "only"
   	 exe "help ".manpagetopic
	 only
	elseif g:manpageview_winopen == "vsplit"
   	 exe "vert help ".manpagetopic
	elseif g:manpageview_winopen == "vsplit="
   	 exe "vert help ".manpagetopic
	 wincmd =
	elseif g:manpageview_winopen == "hsplit="
   	 exe "help ".manpagetopic
	 wincmd =
	else
   	 exe "help ".manpagetopic
	endif
"    call Dret("ManPageView")
	return

   " filetype: perl
   elseif &ft == "perl"
   	let ext = "pl"

   " filetype:  php
   elseif &ft == "php"
   	let ext = "php"

   " filetype: tex
  elseif &ft == "tex"
   let ext= "tex"
   endif
  endif
"  call Decho("ext<".ext.">")

  " elide extension from manpagetopic
  if exists("g:manpageview_pgm_{ext}")
   let pgm          = g:manpageview_pgm_{ext}
   let manpagetopic = substitute(manpagetopic,'.'.ext.'$','','')
  endif
  let nospace= exists("g:manpageview_nospace_{ext}")
"  call Decho("pgm<".pgm."> manpagetopic<".manpagetopic.">")

  " special exception for info
  if a:viamap == 0 && ext == "i"
   let s:manpageview_pfx_i = "(".manpagetopic.")"
   let manpagetopic        = "Top"
"   call Decho("top-level info: manpagetopic<".manpagetopic.">")
  endif
  if exists("s:manpageview_pfx_{ext}")
   let manpagetopic= s:manpageview_pfx_{ext}.manpagetopic
  elseif exists("g:manpageview_pfx_{ext}")
   " prepend any extension-specified prefix to manpagetopic
   let manpagetopic= g:manpageview_pfx_{ext}.manpagetopic
  endif
  if exists("g:manpageview_sfx_{ext}")
   " append any extension-specified suffix to manpagetopic
   let manpagetopic= manpagetopic.g:manpageview_sfx_{ext}
  endif
  if exists("g:manpageview_K_{ext}")
   " override usual K map
"   call Decho("override K map to call ".g:manpageview_K_{ext})
   exe "nmap <silent> K :call ".g:manpageview_K_{ext}."\<cr>"
  endif
  if exists("g:manpageview_syntax_{ext}")
   " allow special-suffix extensions to optionally control syntax highlighting
   let manpageview_syntax= g:manpageview_syntax_{ext}
  else
   let manpageview_syntax= "man"
  endif

  " support for searching for options from conf pages
  if manpagebook == "" && manpageview_fname =~ '\.conf$'
   let manpagesrch = '^\s\+'.manpagetopic
   let manpagetopic= manpageview_fname
  endif
"  call Decho("manpagebook<".manpagebook."> manpagetopic<".manpagetopic.">")

  " it was reported to me that some systems change display sizes when a
  " filtering command is used such as :r! .  I record the height&width
  " here and restore it afterwards.  To make use of it, put
  "   let g:manpageview_dispresize= 1
  " into your <.vimrc>
  let dwidth  = &cwh
  let dheight = &co
"  call Decho("dwidth=".dwidth." dheight=".dheight)

  " Set up the window for the manpage display (only hsplit split etc)
  if     g:manpageview_winopen == "only"
"   call Decho("only mode")
   silent! windo w
   if !exists("g:ManCurPosn") && has("mksession")
    call s:ManSavePosn()
   endif
   " Record current file/position/screen-position
   if &ft != manpageview_syntax
    silent! only!
   endif
   enew!
  elseif g:manpageview_winopen == "hsplit"
"   call Decho("hsplit mode")
   if &ft != manpageview_syntax
    wincmd s
    enew!
    wincmd _
    3wincmd -
   else
    enew!
   endif
  elseif g:manpageview_winopen == "hsplit="
"   call Decho("hsplit= mode")
   if &ft != manpageview_syntax
    wincmd s
   endif
   enew!
  elseif g:manpageview_winopen == "vsplit"
"   call Decho("vsplit mode")
   if &ft != manpageview_syntax
    wincmd v
    enew!
    wincmd |
    20wincmd <
   else
    enew!
   endif
  elseif g:manpageview_winopen == "vsplit="
"   call Decho("vsplit= mode")
   if &ft != "man"
    wincmd v
   endif
   enew!
  elseif g:manpageview_winopen == "reuse"
   if &mod == 1
   	" file has been modified, would be lost if we re-used window.
	" Use hsplit instead.
    wincmd s
    enew!
    wincmd _
    3wincmd -
   elseif &ft != manpageview_syntax
   	setlocal bh=hide
    enew!
   else
    enew!
   endif
  else
   echohl ErrorMsg
   echo "***sorry*** g:manpageview_winopen<".g:manpageview_winopen."> not supported"
   echohl None
   sleep 2
   call s:MPVRestoreSettings()
"   call Dret("ManPageView : manpageview_winopen<".g:manpageview_winopen."> not supported")
   return
  endif

  " allow user to specify file encoding
  if exists("g:manpageview_fenc")
   exe "setlocal fenc=".g:manpageview_fenc
  endif

  " when this buffer is exited it will be wiped out
  if v:version >= 602
   setlocal bh=wipe
  endif
  let b:did_ftplugin= 2
  let $COLUMNS=winwidth(0)

  " special manpageview buffer maps
  nnoremap <buffer> <space>     <c-f>
  nnoremap <buffer> <c-]>       :call <SID>ManPageView(1,expand("<cWORD>"))<cr>

  " -----------------------------------------
  " Invoke the man command to get the manpage
  " -----------------------------------------
  " the buffer must be modifiable for the manpage to be loaded via :r!
  setlocal ma

  let cmdmod= ""
  if v:version >= 603
   let cmdmod= "silent keepjumps "
  endif

  " extension-based initialization (expected: buffer-specific maps)
  if exists("g:manpageview_init_{ext}")
   if !exists("b:manpageview_init_{ext}")
"    call Decho("exe manpageview_init_".ext."<".g:manpageview_init_{ext}.">")
    exe g:manpageview_init_{ext}
	let b:manpageview_init_{ext}= 1
   endif
  elseif ext == ""
   silent! unmap K
   nmap <unique> K <Plug>ManPageView
  endif

  " default program g:manpageview_options (empty string) may be overridden
  " if an extension is matched
  let opt= g:manpageview_options
  if exists("g:manpageview_options_{ext}")
   let opt= g:manpageview_options_{ext}
  endif
"  call Decho("opt<".opt.">")

  let cnt= 0
  while cnt < 3 && (strlen(opt) > 0 || cnt == 0)
   let cnt   = cnt + 1
   let iopt  = substitute(opt,';.*$','','e')
   let opt   = substitute(opt,'^.\{-};\(.*\)$','\1','e')
"   call Decho("iopt<".iopt."> opt<".opt.">")

   " use pgm to read/find/etc the manpage (but only if pgm is not the empty string)
   " by default, pgm is "man"
   if pgm != ""

	" ---------------------------
	" use manpage_lookup function
	" ---------------------------
   	if exists("g:manpageview_lookup_{ext}")
"	 call Decho("lookup: exe call ".g:manpageview_lookup_{ext}."(".manpagebook.",".manpagetopic.")")
	 exe "call ".g:manpageview_lookup_{ext}."(".manpagebook.",".manpagetopic.")"

    elseif has("win32") && exists("g:manpageview_server") && exists("g:manpageview_user")
"     call Decho("win32: manpagebook<".manpagebook."> topic<".manpagetopic.">")
     exe cmdmod."r!".g:manpageview_rsh." ".g:manpageview_server." -l ".g:manpageview_user." ".pgm." ".iopt." ".manpagebook." ".manpagetopic
     exe cmdmod.'silent!  %s/.\b//ge'

"   elseif has("conceal")
"    exe cmdmod."r!".pgm." ".iopt." ".manpagebook." ".manpagetopic

	"--------------------------
	" use pgm to obtain manpage
	"--------------------------
    else
     if nospace
"	   call Decho("(nospace) exe silent! ".cmdmod."r!".pgm.iopt.manpagebook.manpagetopic)
      exe "silent! ".cmdmod."r!".pgm.iopt.manpagebook.manpagetopic.s:iconv
     elseif has("win32")
"       call Decho("(win32) exe silent! ".cmdmod."r!".pgm." ".iopt." ".manpagebook." \"".manpagetopic."\"")
       exe "silent! ".cmdmod."r!".pgm." ".iopt." ".manpagebook." \"".manpagetopic."\"".s:iconv
	 else
"      call Decho("(nrml) exe silent! ".cmdmod."r!".pgm." ".iopt." ".manpagebook." '".manpagetopic."'")
      echo "exe silent! ".cmdmod."r!".pgm." ".iopt." ".manpagebook." '".manpagetopic."'".s:iconv
      exe "silent! ".cmdmod."r!".pgm." ".iopt." ".manpagebook." '".manpagetopic."'".s:iconv
	endif
     exe cmdmod.'silent!  %s/.\b//ge'
    endif
	setlocal ro nomod noswf
   endif

   " check if manpage actually found
   if line("$") != 1 || col("$") != 1
"    call Decho("manpage found")
    break
   endif
"   call Decho("manpage not found")
  endwhile

  " here comes the vim display size restoration
  if exists("g:manpageview_dispresize")
   if g:manpageview_dispresize == 1
"    call Decho("restore display size to ".dheight."x".dwidth)
    exe "let &co=".dwidth
    exe "let &cwh=".dheight
   endif
  endif

  " clean up (ie. remove) any ansi escape sequences
  silent! %s/\e\[[0-9;]\{-}m//ge
  silent! %s/\%xe2\%x80\%x90/-/ge
  silent! %s/\%xe2\%x88\%x92/-/ge
  silent! %s/\%xe2\%x80\%x99/'/ge
  silent! %s/\%xe2\%x94\%x82/ /ge

  " set up options and put cursor at top-left of manpage
  if manpagebook == "-k"
   setlocal ft=mankey
  else
   exe cmdmod."setlocal ft=".manpageview_syntax
  endif
  exe cmdmod."setlocal ro"
  exe cmdmod."setlocal noma"
  exe cmdmod."setlocal nomod"
  exe cmdmod."setlocal nolist"
  exe cmdmod."setlocal nonu"
  exe cmdmod."setlocal fdc=0"
"  exe cmdmod."setlocal isk+=-,.,(,)"
  exe cmdmod."setlocal nowrap"
  set nolz
  exe cmdmod."1"
  exe cmdmod."norm! 0"

  if line("$") == 1 && col("$") == 1
   " looks like there's no help for this topic
   q
"   call Decho("***warning*** no manpage exists for <".manpagetopic."> book=".manpagebook)
   echohl ErrorMsg
   echo "***warning*** sorry, no manpage exists for <".manpagetopic.">"
   echohl None
   sleep 2
  elseif manpagebook == ""
   exe 'file '.'Manpageview['.manpagetopic.']'
"   call Decho("setting filename<Manpageview[".manpagetopic.']>')
  else
   exe 'file '.'Manpageview['.manpagetopic.'('.manpagebook.')]'
"   call Decho("setting filename<Manpageview[".manpagetopic.'('.manpagebook.')]>')
  endif

  " if there's a search pattern, use it
  if exists("manpagesrch")
   if search(manpagesrch,'w') != 0
    exe "norm! z\<cr>"
   endif
  endif

  call s:MPVRestoreSettings()
"  call Dret("ManPageView")
endfun

" ---------------------------------------------------------------------
" MPVSaveSettings: save and standardize certain user settings {{{2
fun! s:MPVSaveSettings()

  if !exists("s:sxqkeep")
"   call Dfunc("MPVSaveSettings()")
   let s:sxqkeep           = &sxq
   let s:srrkeep           = &srr
   let s:repkeep           = &report
   let s:gdkeep            = &gd
   let s:cwhkeep           = &cwh
   let s:magickeep         = &magic
   setlocal srr=> report=10000 nogd magic
   if &cwh < 2
    " avoid hit-enter prompts
    setlocal cwh=2
   endif
  if has("win32") || has("win95") || has("win64") || has("win16")
   let &sxq= '"'
  else
   let &sxq= ""
  endif
"  call Dret("MPVSaveSettings")
 endif

endfun

" ---------------------------------------------------------------------
" MPV_RestoreSettings: {{{2
fun! s:MPVRestoreSettings()
  if exists("s:sxqkeep")
"   call Dfunc("MPV_RestoreSettings()")
   let &sxq    = s:sxqkeep   | unlet s:sxqkeep
   let &srr    = s:srrkeep   | unlet s:srrkeep
   let &report = s:repkeep   | unlet s:repkeep
   let &gd     = s:gdkeep    | unlet s:gdkeep
   let &cwh    = s:cwhkeep   | unlet s:cwhkeep
   let &magic  = s:magickeep | unlet s:magickeep
"   call Dret("MPV_RestoreSettings")
  endif
endfun

" ---------------------------------------------------------------------
" ManRestorePosn: restores file/position/screen-position {{{2
"                 (uses g:ManCurPosn)
fun! s:ManRestorePosn()
"  call Dfunc("ManRestorePosn()")

  if exists("g:ManCurPosn")
"   call Decho("g:ManCurPosn<".g:ManCurPosn.">")
   if v:version >= 603
    exe 'keepjumps silent! source '.escape(g:ManCurPosn,' ')
   else
    exe 'silent! source '.escape(g:ManCurPosn,' ')
   endif
   unlet g:ManCurPosn
   silent! cunmap q
  endif

"  call Dret("ManRestorePosn")
endfun

" ---------------------------------------------------------------------
" ManSavePosn: saves current file, line, column, and screen position {{{2
fun! s:ManSavePosn()
"  call Dfunc("ManSavePosn()")

  let g:ManCurPosn= tempname()
  let keep_ssop   = &ssop
  let &ssop       = 'winpos,buffers,slash,globals,resize,blank,folds,help,options,winsize'
  if v:version >= 603
   exe 'keepjumps silent! mksession! '.escape(g:ManCurPosn,' ')
  else
   exe 'silent! mksession! '.escape(g:ManCurPosn,' ')
  endif
  let &ssop       = keep_ssop
  cnoremap <silent> q call <SID>ManRestorePosn()<CR>

"  call Dret("ManSavePosn")
endfun

let &cpo= s:keepcpo
unlet s:keepcpo

" ---------------------------------------------------------------------
" ManPageInfo: {{{2
fun! s:ManPageInfo(type)
"  call Dfunc("ManPageInfo(type=".a:type.")")

  if &ft != "info"
   " restore K and do a manpage lookup for word under cursor
"   call Decho("ft!=info: restore K and do a manpage lookup of word under cursor")
   setlocal kp=<sid>ManPageView
   if exists("s:manpageview_pfx_i")
    unlet s:manpageview_pfx_i
   endif
   call s:ManPageView(1,0,expand("<cWORD>"))
"   call Dret("ManPageInfo : restored K")
   return
  endif

  if !exists("s:manpageview_pfx_i")
   let s:manpageview_pfx_i= g:manpageview_pfx_i
  endif

  " -----------
  " Follow Link
  " -----------
  if a:type == 0
   " extract link
   let curline  = getline(".")
"   call Decho("type==0: curline<".curline.">")
   let ipat     = 1
   while ipat <= 4
    let link= matchstr(curline,s:linkpat{ipat})
"	call Decho("..attempting s:linkpat".ipat.":<".s:linkpat{ipat}.">")
    if link != ""
     if ipat == 2
      let s:manpageview_pfx_i = substitute(link,s:linkpat{ipat},'\1','')
      let node                = "Top"
     else
      let node                = substitute(link,s:linkpat{ipat},'\1','')
 	 endif
"   	 call Decho("ipat=".ipat."link<".link."> node<".node."> pfx<".s:manpageview_pfx_i.">")
 	 break
    endif
    let ipat= ipat + 1
   endwhile

  " ---------------
  " Go to next node
  " ---------------
  elseif a:type == 1
"   call Decho("type==1: goto next node")
   let node= matchstr(getline(2),'Next: \zs[^,]\+\ze,')
   let fail= "no next node"

  " -------------------
  " Go to previous node
  " -------------------
  elseif a:type == 2
"   call Decho("type==2: goto previous node")
   let node= matchstr(getline(2),'Prev: \zs[^,]\+\ze,')
   let fail= "no previous node"

  " ----------
  " Go up node
  " ----------
  elseif a:type == 3
"   call Decho("type==3: go up one node")
   let node= matchstr(getline(2),'Up: \zs.\+$')
   let fail= "no up node"

  " --------------
  " Go to top node
  " --------------
  elseif a:type == 4
"   call Decho("type==4: go to top node")
   let node= "Top"
  endif
"  call Decho("node<".(exists("node")? node : '--n/a--').">")

  " use ManPageView() to view selected node
  if !exists("node")
   echohl ErrorMsg
   echo "***sorry*** unable to view selection"
   echohl None
   sleep 2
  elseif node == ""
   echohl ErrorMsg
   echo "***sorry*** ".fail
   echohl None
   sleep 2
  else
   call s:ManPageView(1,0,node.".i")
  endif

"  call Dret("ManPageInfo")
endfun

" ---------------------------------------------------------------------
" ManPageInfoInit: {{{2
fun! ManPageInfoInit()
"  call Dfunc("ManPageInfoInit()")

  " some mappings to imitate the default info reader
  nmap    <buffer>          <cr> K
  noremap <silent> <buffer> >		:call <SID>ManPageInfo(1)<cr>
  noremap <silent> <buffer> n		:call <SID>ManPageInfo(1)<cr>
  noremap <silent> <buffer> <		:call <SID>ManPageInfo(2)<cr>
  noremap <silent> <buffer> p		:call <SID>ManPageInfo(2)<cr>
  noremap <silent> <buffer> u		:call <SID>ManPageInfo(3)<cr>
  noremap <silent> <buffer> t		:call <SID>ManPageInfo(4)<cr>
  noremap <silent> <buffer> ?		:he manpageview-info<cr>
  noremap <silent> <buffer> d		:call <SID>ManPageView(0,0,"dir.i")<cr>
  noremap <silent> <buffer> <BS>	<C-B>
  noremap <silent> <buffer> <Del>	<C-B>
  noremap <silent> <buffer> <Tab>	:call <SID>NextInfoLink()<CR>
  noremap <silent> <buffer> i		:call <SID>InfoIndexLink('i')<CR>
  noremap <silent> <buffer> ,		:call <SID>InfoIndexLink(',')<CR>
  noremap <silent> <buffer> ;		:call <SID>InfoIndexLink(';')<CR>

"  call Dret("ManPageInfoInit")
endfun

" ---------------------------------------------------------------------
" s:NextInfoLink: {{{2
fun! s:NextInfoLink()
    let ln = search('\('.s:linkpat1.'\|'.s:linkpat2.'\|'.s:linkpat3.'\|'.s:linkpat4.'\)', 'w')
    if ln == 0
		echohl ErrorMsg
	   	echo '***sorry*** no links found' 
	   	echohl None
		sleep 2
    endif
endfun

" ---------------------------------------------------------------------
" s:InfoIndexLink: supports info's "i" for index-search-for-topic {{{2
fun! s:InfoIndexLink(cmd)
"  call Dfunc("s:InfoIndexLink(cmd<".a:cmd.">)")
"  call Decho("indx vars: line #".(exists("s:indxline")? s:indxline : '---'))
"  call Decho("indx vars: cnt  =".(exists("s:indxcnt")? s:indxcnt : '---'))
"  call Decho("indx vars: find =".(exists("s:indxfind")? s:indxfind : '---'))
"  call Decho("indx vars: link <".(exists("s:indxlink")? s:indxlink : '---').">")
"  call Decho("indx vars: where<".(exists("s:wheretopic")? s:wheretopic : '---').">")
"  call Decho("indx vars: srch <".(exists("s:indxsrchdir")? s:indxsrchdir : '---').">")

  " sanity checks
  if !exists("s:manpagetopic")
   echohl Error
   echo "(InfoIndexLink) no manpage topic available!"
   echohl NONE
"   call Dret("s:InfoIndexLink : no manpagetopic")
   return

  elseif !executable("info")
   echohl Error
   echo '(InfoIndexLink) the info command is not executable!'
   echohl NONE
"   call Dret("s:InfoIndexLink : info not exe")
   return
  endif

  if a:cmd == 'i'
   call inputsave()
   let s:infolink= input("Index entry: ","","shellcmd")
   call inputrestore()
   let s:indxfind= -1
  endif
"  call Decho("infolink<".s:infolink.">")

  if s:infolink != ""

   if a:cmd == 'i'
	let mpt= substitute(s:manpagetopic,'\.i','','')
"	call Decho('system("info '.mpt.' --where")')
	let s:wheretopic    = substitute(system("info ".mpt." --where"),'\n','','g')
    let s:indxline      = 1
    let s:indxcnt       = 0
	let s:indxsrchdir   = 'cW'
"	call Decho("new indx vars: cmd<i> where<".s:wheretopic.">")
"	call Decho("new indx vars: cmd<i> line#".s:indxline)
"	call Decho("new indx vars: cmd<i> cnt =".s:indxcnt)
"	call Decho("new indx vars: cmd<i> srch<".s:indxsrchdir.">")
   elseif a:cmd == ','
	let s:indxsrchdir= 'W'
"	call Decho("new indx vars: cmd<,> srch<".s:indxsrchdir.">")
   elseif a:cmd == ';'
	let s:indxsrchdir= 'bW'
"	call Decho("new indx vars: cmd<;> srch<".s:indxsrchdir.">")
   endif

   let cmdmod= ""
   if v:version >= 603
    let cmdmod= "silent keepjumps "
   endif

   let wheretopic= s:wheretopic
   if s:indxcnt != 0
	let wheretopic= substitute(wheretopic,'\.info\%(-\d\+\)\=\.','.info-'.s:indxcnt.".",'')
   else
	let wheretopic= substitute(wheretopic,'\.info\%(-\d\+\)\=\.','.info.','')
   endif
"   call Decho("initial wheretopic<".wheretopic."> indxcnt=".s:indxcnt)

   " search for topic in various files loop
   while filereadable(wheretopic)
"	call Decho("--- while loop: where<".wheretopic."> indxcnt=".s:indxcnt." indxline#".s:indxline)

	" read file <topic.info-#.gz>
    setlocal ma
    silent! %d
	if s:indxcnt != 0
	 let wheretopic= substitute(wheretopic,'\.info\%(-\d\+\)\=\.','.info-'.s:indxcnt.".",'')
	else
	 let wheretopic= substitute(wheretopic,'\.info\%(-\d\+\)\=\.','.info.','')
	endif
"    call Decho("    exe ".cmdmod."r ".escape(wheretopic,' '))
    try
     exe cmdmod."r ".escape(wheretopic,' ')
	catch /^Vim\%((\a\+)\)\=:E484/
	 break
	finally
	 if search('^File:','W') != 0
	  silent 1,/^File:/-1d
	  1put! =''
	 else
	  1d
	 endif
	endtry
	setlocal noma nomod

	if s:indxline < 0
	 if a:cmd == ','
	  " searching forwards
	  let s:indxline= 1
"	  call Decho("    searching forwards from indxline#".s:indxline)
	 elseif a:cmd == ';'
	  " searching backwards
	  let s:indxline= line("$")
"	  call Decho("    searching backwards from indxline#".s:indxline)
	 endif
	endif

	if s:indxline != 0
"     call Decho("    indxline=".s:indxline." infolink<".s:infolink."> srchflags<".s:indxsrchdir.">")
     exe s:indxline
     let s:indxline= search('^\n\zs'.s:infolink.'\>\|^[0-9.]\+.*\zs\<'.s:infolink.'\>',s:indxsrchdir)
"     call Decho("    search(".s:infolink.",".s:indxsrchdir.") yields: s:indxline#".s:indxline)
     if s:indxline != 0
	  let s:indxfind= s:indxcnt
	  echo ",=Next Match  ;=Previous Match"
"      call Dret("s:InfoIndexLink : success!  (indxfind=".s:indxfind.")")
      return
     endif
	endif

	if a:cmd == 'i' || a:cmd == ','
	 let s:indxcnt  = s:indxcnt + 1
	 let s:indxline = 1
	elseif a:cmd == ';'
	 let s:indxcnt  = s:indxcnt - 1
	 if s:indxcnt < 0
	  let s:indxcnt= 0
"	  call Decho("    new indx vars: cmd<".a:cmd."> indxcnt=".s:indxcnt)
	  break
	 endif
	 let s:indxline = -1
	endif
"	call Decho("    new indx vars: cmd<".a:cmd."> indxcnt =".s:indxcnt)
"	call Decho("    new indx vars: cmd<".a:cmd."> indxline#".s:indxline)
   endwhile
  endif
"  call Decho("end-while indx vars: find=".s:indxfind." cnt=".s:indxcnt)

  " clear screen
  setlocal ma
  silent! %d
  setlocal noma nomod

  if s:indxfind < 0
   " unsuccessful :(
   echohl WarningMsg
   echo "(InfoIndexLink) unable to find info for topic<".s:manpagetopic."> indx<".s:infolink.">"
   echohl NONE
"   call Dret("s:InfoIndexLink : unable to find info for ".s:manpagetopic.":".s:infolink)
   return
  elseif a:cmd == ','
   " no more matches
   let s:indxcnt = s:indxcnt - 1
   let s:indxline= 1
   echohl WarningMsg
   echo "(InfoIndexLink) no more matches"
   echohl NONE
"   call Dret("s:InfoIndexLink : no more matches")
   return
  elseif a:cmd == ';'
   " no more matches
   let s:indxcnt = s:indxfind
   let s:indxline= -1
   echohl WarningMsg
   echo "(InfoIndexLink) no previous matches"
   echohl NONE
"   call Dret("s:InfoIndexLink : no previous matches")
   return
  endif
endfun

" ---------------------------------------------------------------------
" s:ManPageTex: {{{2
fun! s:ManPageTex()
  let topic= '\'.expand("<cWORD>")
"  call Dfunc("ManPageTex() topic<".topic.">")
  call s:ManPageView(1,0,topic)
"  call Dret("ManPageTex")
endfun

" ---------------------------------------------------------------------
" s:ManPageTexLookup: {{{2
fun! s:ManPageTexLookup(book,topic)
"  call Dfunc("s:ManPageTexLookup(book<".a:book."> topic<".a:topic.">)")
"  call Dret("s:ManPageTexLookup ".lookup)
endfun

" ---------------------------------------------------------------------
" ManPagePhp: {{{2
fun! s:ManPagePhp()
  let topic=substitute(expand("<cWORD>"),'()','.php','e')
"  call Dfunc("ManPagePhp() topic<".topic.">")
  call s:ManPageView(1,0,topic)
"  call Dret("ManPagePhp")
endfun

" ---------------------------------------------------------------------
" Modeline: {{{1
" vim: ts=4 fdm=marker
