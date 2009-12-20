if exists("g:netplugin_http_loaded")
  finish
endif

let g:netplugin_http_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let s:need_source_grabber = 'g:netlib_operation ==# "source"'

" Page dumpers
let s:elinks_prio = 80
let s:elinks_usable = 'len(system("elinks -version")) && !v:shell_error'
                    \ . ' && !' . s:need_source_grabber

let s:w3m_prio = 70
let s:w3m_usable = 'len(system("w3m -version")) && !v:shell_error'
                 \ . ' && !' . s:need_source_grabber

let s:links_prio = 60
let s:links_usable = 'len(system("links -version")) && v:shell_error == 3'
                   \ . ' && !' . s:need_source_grabber

" Source grabbers
let s:curl_prio = 40
let s:curl_usable = 'len(system("curl --version")) && !v:shell_error'

let s:wget_prio = 30
let s:wget_usable = 'len(system("wget --version")) && !v:shell_error'

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let s:handler = netlib#GenericHandler('http', s:elinks_usable, 'elinks -dump', '')
call netlib#RegisterHandler('http', 'elinks', s:handler, s:elinks_prio)

let s:handler = netlib#GenericHandler('http', s:w3m_usable, 'w3m -dump', '')
call netlib#RegisterHandler('http', 'w3m', s:handler, s:w3m_prio)

let s:handler = netlib#GenericHandler('http', s:links_usable, 'links -dump', '')
call netlib#RegisterHandler('http', 'links', s:handler, s:links_prio)

let s:handler = netlib#GenericHandler('http', s:curl_usable, 'curl', '')
call netlib#RegisterHandler('http', 'curl', s:handler, s:curl_prio)

let s:handler = netlib#GenericHandler('http', s:wget_usable, 'wget -q -O -', '')
call netlib#RegisterHandler('http', 'wget', s:handler, s:wget_prio)

unlet s:handler

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let &cpo = s:savecpo
unlet s:savecpo
