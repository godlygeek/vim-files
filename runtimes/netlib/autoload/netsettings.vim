let s:aliases = {}

function! netsettings#SetAliasOption(alias, key, val)
  if type(a:alias) != type('') || type(a:key) != type('')
    throw "netsettings.exception: Bad arguments for SetAliasOption()"
  endif

  if !has_key(s:aliases, a:alias)
    let s:aliases[a:alias] = {}
  endif

  let s:aliases[a:alias][a:key] = a:val
endfunction

function! netsettings#GetAliasOptions(alias)
  return deepcopy(get(s:aliases, a:alias, {}))
endfunction

function! netsettings#DeleteAlias(alias)
  try
    unlet s:aliases[a:alias]
  catch
  endtry
endfunction




" Functions for prioritizing handlers per protocol
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

" Comparator for objects of type [ 'handlername', priority ]
function! s:PrioSort(item1, item2)
  if a:item1[1] > a:item2[1]
    return -1
  elseif a:item1[1] < a:item2[1]
    return 1
  else
    return 0
  endif
endfunction

" Return a list of handler names for a given protocol, sorted from highest
" priority to lowest.
function! netsettings#HandlerList(protocol)
  if !has_key(s:netlib_handler_priorities, a:protocol)
    let s:netlib_handler_priorities[a:protocol] = {}
  endif

  let items = items(s:netlib_handler_priorities[a:protocol])
  call sort(items, "s:PrioSort")
  return map(items, 'v:val[0]')
endfunction
