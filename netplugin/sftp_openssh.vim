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

function! s:get_sftp_cmdline(opts)
  let cmd = get(a:opts, 'sftp_progname', 'sftp')

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

  sil! let cmd .= ' ' . shellescape(a:opts['host'])

  return cmd
endfunction

let s:handler = {}

function! s:handler.read(path, file) dict
  let opts = s:FindOptions(a:path)

  if !executable(get(opts, 'sftp_progname', 'sftp'))
    return 0
  endif

  " Marker for beginning of output
  let input = [ '- - - - -' ]
  let input += [ 'ls -1al "' . opts['path'] . '"' ]
  let input += [ 'get -P "' . opts['path'] . '" "' . a:file . '"' ]

  let cmdline = s:get_sftp_cmdline(opts)

  echo cmdline

  sil! call delete(a:file)

  let output = system(cmdline, join(input + [], "\n"))

  if !filereadable(a:file)
    let lines = split(output, '\r\=\n')

    while lines[0] !~# '^sftp> - - - - -$'
      call remove(lines, 0)
    endwhile

    call remove(lines, 0, 2)

    let listing = []

    let chars_to_remove = -1

    while lines[0] =~# '^[-bcCdDlMnpPs?][r-][w-][sStTx-][r-][w-][sStTx-][r-][w-][sStTx-]\S\=\s*\d'
      let line = remove(lines, 0)

      if line =~# '^d' && line !~ '/$'
        let line .= '/'
      endif

      if chars_to_remove == -1 && line =~ '\s\./$'
        let chars_to_remove = strlen(substitute(line, '.', 'x', 'g')) - 2
      endif

      let line = substitute(line, '^.\{' . chars_to_remove . '}', '', '')

      let listing += [ 'sftp://' . a:path . '/' . line ]
    endwhile

    if empty(listing)
      return -1
    endif

    call writefile(listing, a:file)

    return 2
  endif

  return 1
endfunction

function! s:handler.write(path, file) dict
  let opts = s:FindOptions(a:path)

  if !executable(get(opts, 'sftp_progname', 'sftp'))
    return 0
  endif

  let input = [ 'put "' . a:file . '" "' . opts['path'] . '"' ]

  let cmdline = s:get_sftp_cmdline(opts)

  echo cmdline
  echon "\n"

  let output = system(cmdline, join(input + [], "\n"))

  " This may just be an implementation detail, but it works...
  if output =~ "\r\n$"
    return -1
  endif

  return 1
endfunction

call netlib#RegisterHandler('sftp', 'opensftp', s:handler, s:opensftp_prio)

unlet s:handler

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

let &cpo = s:savecpo
unlet s:savecpo
