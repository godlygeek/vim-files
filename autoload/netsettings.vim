let s:options = {}

function! s:InternalSet(host, key, val)
  " XXX Enforce that host, key and val are strings?
  "     At least host and key should probably be strings...

  if !has_key(s:options, a:host)
    let s:options[a:host] = {}
  endif

  " XXX Warn on overwrite?  Require force flag?
  let s:options[a:host][a:key] = a:val
endfunction

function! netsettings#SetOption(key, val)
  call s:InternalSet('', a:key, a:val)
endfunction

function! netsettings#SetHostOption(host, key, val)
  call s:InternalSet(a:host, a:key, a:val)
endfunction

function! netsettings#GetOption(host, key, val)
  let host = a:host

  if has_key(a:options, a:host) && has_key(a:options[a:host], a:key)
    return a:options[a:host][a:key]
  elseif has_key(a:options[''], a:key)
    return a:options[''][a:key]
  else
    throw "netsettings.exception: no such key"
  endif
endfunction



let s:netlib_handler_priorities = {}

function! netsettings#SetHandlerPriority(protocol, handler, priority)
  if !has_key(s:netlib_handler_priorities, a:protocol)
    let s:netlib_handler_priorities[a:protocol] = {}
  endif

  let s:netlib_handler_priorities[a:protocol][a:handler] = a:priority
endfunction

function! netsettings#GetHandlerPriority(protocol, handler)
  if !has_key(s:netlib_handler_priorities, a:protocol)
    let s:netlib_handler_priorities[a:protocol] = {}
  endif

  if has_key(s:netlib_handler_priorities[a:protocol], a:handler)
    return s:netlib_handler_priorities[a:protocol][a:handler]
  endif

  throw "netsettings.exception: no such handler"
endfunction

function! s:PrioSort(item1, item2)
  if a:item1[1] > a:item2[1]
    return -1
  elseif a:item1[1] < a:item2[1]
    return 1
  else
    return 0
  endif
endfunction

function! netsettings#HandlerList(protocol)
  if !has_key(s:netlib_handler_priorities, a:protocol)
    let s:netlib_handler_priorities[a:protocol] = {}
  endif

  let items = items(s:netlib_handler_priorities[a:protocol])
  call sort(items, "s:PrioSort")
  return map(items, 'v:val[0]')
endfunction
