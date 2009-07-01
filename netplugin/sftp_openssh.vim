" Recognized options:
"
" General options:
"
" sftp_{option}, ssh_{option}, and {option} are all checked, in that order.
" First one found takes precedence.
"
" host      hostname of remote machine
" port      ssh port on remote machine
" user      username on remote machine
"
" sftp-specific options:
"
" Only sftp_{option} and ssh_{option} are checked.  First one takes precedence.
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
" sftp_progname   path to sftp (only needed when not in path)
"
" FIXME NOT YET IMPLEMENTED: FIXME
" extra_options   List of extra options to pass (see man 5 ssh_config)


" NOTE: This will only work on POSIX systems.

if exists("g:netplugin_opensftp_loaded") || !has('unix')
  finish
endif

let g:netplugin_opensftp_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let s:opensftp_prio = 90

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

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

function! s:FindOptions(path)
  let parsed_path = netlib#utility#uri_split(a:path, '@', ':', '[:/]')
  if !has_key(parsed_path, 'host')
    throw "netlib.exception: Invalid URI " . string('sftp://' . a:path)
  endif

  let options = netsettings#GetAliasOptions(parsed_path['host'])

  " Not recognized without leading {ssh_,sftp_}
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

  if has_key(options, 'sftp_progname')
    let sftp_progname = options['sftp_progname']
  endif

  " ssh_opt takes precedence over opt
  call s:FoldPrefix(options, 'ssh_')

  " sftp_opt takes precedence over opt and ssh_opt
  call s:FoldPrefix(options, 'sftp_')

  " Undo this wrong collapse...  Need to keep ssh_progname and sftp_progname
  sil! unlet options['progname']

  if exists('ssh_progname')
    let options['ssh_progname'] = ssh_progname
  endif

  if exists('sftp_progname')
    let options['sftp_progname'] = sftp_progname
  endif

  let options['path'] = parsed_path['path']

  if has_key(parsed_path, 'port')
    let options['port'] = parsed_path['port']
  endif

  if has_key(parsed_path, 'user')
    let options['user'] = parsed_path['user']
  endif

  if !has_key(options, 'host')
    let options['host'] = parsed_path['host']
  endif

  return options
endfunction

function! s:sftp(input, opts)
  let cmd = get(a:opts, 'sftp_progname', 'sftp')

  if !executable(cmd)
    return -1
  endif

  sil! let cmd .= ' -oPort=' . shellescape(a:opts['port'])
  sil! let cmd .= a:opts['force_proto'] == 1 ? shellescape(' -1') : ''
  sil! let cmd .= a:opts['force_ipv'] == 4 ? shellescape(' -oAddressFamily=inet') : ''
  sil! let cmd .= a:opts['force_ipv'] == 6 ? shellescape(' -oAddressFamily=inet6') : ''
  sil! let cmd .= a:opts['compress'] != '0' ? shellescape(' -C') : ''
  "sil! let cmd .= ' -c ' . shellescape(a:opts['cipher'])
  "sil! let cmd .= ' -F ' . shellescape(a:opts['config_file'])
  "sil! let cmd .= ' -i ' . shellescape(a:opts['identity_file'])
  "sil! let cmd .= ' -l ' . shellescape(a:opts['kbits_per_sec'])
  "sil! let cmd .= a:opts['preserve'] != '0' ? shellescape(' -p') : ''
  "sil! let cmd .= ' -S ' . shellescape(a:opts['ssh_progname'])

  "sil let cmd .= ' ' . shellescape(a:src) . ' ' . shellescape(a:dest)

  sil! let cmd .= ' -b -'
  sil! let cmd .= ' -S /home/matt/ssh-sanitize.sh'
  sil! let cmd .= ' ' . shellescape(a:opts['host'])

  echo cmd
  echon "\n"
  echo system(cmd, join(a:input + [], "\n"))

  if v:shell_error
    return -1
  endif

  return 1
endfunction

let s:handler = {}

function! s:handler.read(path, file) dict
  try
    let opts = s:FindOptions(a:path)
    echomsg string(opts)
    let input = [ 'get -P "' . opts['path'] . '" "' . a:file . '"' ]
    return s:sftp(input, opts)
  catch
    return 0
  endtry
endfunction

function! s:handler.write(path, file) dict
  try
    let opts = s:FindOptions(a:path)
    let input  = [ '-rm "'  . opts['path'] . '"']
    let input += [ 'ln . "' . opts['path'] . '"']
    let input += [ 'rm "'   . opts['path'] . '"']
    let input += [ 'put "'  . a:file       . '" "' . opts['path'] . '"' ]
    return s:sftp(input, opts)
  catch
    return 0
  endtry
endfunction

call netlib#RegisterHandler('sftp', 'opensftp', s:handler, s:opensftp_prio)

unlet s:handler

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let &cpo = s:savecpo
unlet s:savecpo
