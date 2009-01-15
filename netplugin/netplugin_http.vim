if exists("g:netplugin_http_loaded")
  finish
endif

let g:netplugin_http_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

" Page dumpers
let s:elinks_prio = 80
let s:w3m_prio    = 70
let s:links_prio  = 60

" Source grabbers
let s:curl_prio   = 40
let s:wget_prio   = 30

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let s:handler = netlib#GenericHandler('http', 'elinks -version', 'elinks -dump', '')
call netlib#RegisterHandler('http', 'elinks', s:handler, s:elinks_prio)

let s:handler = netlib#GenericHandler('http', 'w3m -version', 'w3m -dump', '')
call netlib#RegisterHandler('http', 'w3m', s:handler, s:w3m_prio)

let s:handler = netlib#GenericHandler('http', '', 'links -dump', '')
call netlib#RegisterHandler('http', 'links', s:handler, s:links_prio)

let s:handler = netlib#GenericHandler('http', 'curl --version', 'curl', '')
call netlib#RegisterHandler('http', 'curl', s:handler, s:curl_prio)

let s:handler = netlib#GenericHandler('http', 'wget --version', 'wget -q -O -', '')
call netlib#RegisterHandler('http', 'wget', s:handler, s:wget_prio)

unlet s:handler

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let &cpo = s:savecpo
unlet s:savecpo
