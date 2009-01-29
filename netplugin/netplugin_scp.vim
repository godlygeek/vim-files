" Recognized options:
"
" General options:
"
" scp_{option}, ssh_{option}, and {option} are all checked, in that order.
" First one found takes precedence.
"
" host      hostname of remote machine
" port      ssh port on remote machine
" user      username on remote machine
"
" SCP-specific options:
"
" Only scp_{option} and ssh_{option} are checked.  First one takes precedence.
"
" force_proto     force the use of a particular ssh protocol version (1 or 2)
" force_ipv       force the use of a particular IP version (4 or 6)
" compress        request no compression or compression (0 or 1)
" cipher          choose a particular cipher
" config_file     choose a different config file than ~/.ssh/config
" identity_file   choose a different identity file than ~/.ssh/id_[rd]sa
" kbits_per_sec   limit maximum bandwidth
" preserve        force times and permissions to be transferred (0 or 1)
"
" ssh_progname    program name for underlying ssh connection
" scp_progname    path to scp (only needed when not in path)
"
" FIXME NOT YET IMPLEMENTED: FIXME
" extra_options   List of extra options to pass (see man 5 ssh_config)

if exists("g:netplugin_scp_loaded")
  finish
endif

let g:netplugin_scp_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let s:openscp_prio = 90

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

" Parse the three valid path formats.
" /path/to/file
" [user@]host[#port]:path/to/file
" [user@]host[#port]/path/to/file
"
" TODO: Can this be made generic and moved into netlib#Something() ?
function! s:ParsePath(path)
  let rv = {}
  if a:path[0] ==# '/'
    let rv['path'] = a:path
  else
    let list = matchlist(a:path, '^\%(\([^@]\+\)@\)\=\([^#:/]\+\)\%(#\(\d\+\)\)\=[:/]\(.*\)$')
    if len(list) != 0
      if len(list[1])
        let rv['user'] = list[1]
      endif
      let rv['host'] = list[2]
      if len(list[3])
        let rv['port'] = list[3]
      endif
      let rv['path'] = list[4]
    endif
  endif
  return rv
endfunction

function! s:FoldPrefix(options, prefix)
  let pfxlen = len(a:prefix)
  if pfxlen
    for [key, val] in items(a:options)
      if key[0 : pfxlen - 1] ==# a:prefix
        let a:options[key[pfxlen : -1]] = val
        unlet a:options[key]
      endif
    endfor
  endif
endfunction

function! s:ChoosePathAndOptions(path)
  let parsed_path = s:ParsePath(a:path)

  if has_key(parsed_path, 'host')
    let options = netsettings#GetAliasOptions(parsed_path['host'])
  else
    let options = {}
  endif

  " Not recognized without leading {ssh_,scp_}
  sil! unlet options['force_proto']
  sil! unlet options['force_ipv']
  sil! unlet options['compress']
  sil! unlet options['cipher']
  sil! unlet options['config_file']
  sil! unlet options['identity_file']
  sil! unlet options['kbits_per_sec']
  sil! unlet options['extra_options']
  sil! unlet options['preserve']

  if has_key(options, 'ssh_progname')
    let ssh_progname = options['ssh_progname']
  endif

  if has_key(options, 'scp_progname')
    let scp_progname = options['scp_progname']
  endif

  call s:FoldPrefix(options, 'ssh_')
  call s:FoldPrefix(options, 'scp_')

  " Undo this wrong collapse...
  sil! unlet options['progname']

  if exists('ssh_progname')
    let options['ssh_progname'] = ssh_progname
  endif

  if exists('scp_progname')
    let options['scp_progname'] = scp_progname
  endif

  if has_key(options, 'host')
    let parsed_path['host'] = options['host']
  endif

  if !has_key(parsed_path, 'user') && has_key(options, 'user')
    let parsed_path['user'] = options['user']
  endif

  sil! unlet options['host']
  sil! unlet options['user']

  let path = ''

  if has_key(parsed_path, 'host')
    if has_key(parsed_path, 'user')
      let path = parsed_path['user'] . '@' . parsed_path['host'] . ':'
    else
      let path = parsed_path['host'] . ':'
    endif
  endif

  let path .= parsed_path['path']

  return [ path, options ]
endfunction

function! s:scp(src, dest, opts)
  let cmd = get(a:opts, 'scp_progname', 'scp')

  if !executable(cmd)
    return -1
  endif

  sil! let cmd .= ' -P ' . shellescape(a:opts['port'])
  sil! let cmd .= ' -' . shellescape(a:opts['force_proto'])
  sil! let cmd .= ' -' . shellescape(a:opts['force_ipv'])
  sil! let cmd .= a:opts['compress'] != '0' ? shellescape(' -C') : ''
  sil! let cmd .= ' -c ' . shellescape(a:opts['cipher'])
  sil! let cmd .= ' -F ' . shellescape(a:opts['config_file'])
  sil! let cmd .= ' -i ' . shellescape(a:opts['identity_file'])
  sil! let cmd .= ' -l ' . shellescape(a:opts['kbits_per_sec'])
  sil! let cmd .= a:opts['preserve'] != '0' ? shellescape(' -p') : ''
  sil! let cmd .= ' -S ' . shellescape(a:opts['ssh_progname'])

  sil let cmd .= ' ' . shellescape(a:src) . ' ' . shellescape(a:dest)

  echo cmd
  echon "\n"
  echo system(cmd)

  if v:shell_error
    return -1
  endif

  return 1
endfunction

let s:handler = {}

function! s:handler.read(path, file) dict
  let [ path, opts ] = s:ChoosePathAndOptions(a:path)
  return s:scp(path, a:file, opts)
endfunction

function! s:handler.write(path, file) dict
  let [ path, opts ] = s:ChoosePathAndOptions(a:path)
  return s:scp(a:file, path, opts)
endfunction

call netlib#RegisterHandler('scp', 'openscp', s:handler, s:openscp_prio)

unlet s:handler

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let &cpo = s:savecpo
unlet s:savecpo
