" Run some ex command with a particular set of options.
" The old values of each option are saved before and restored afterwards.
function! Exe#ExeWithOpts(cmd, opts)
  try
    let _saveopts = {}
    for [key, val] in items(a:opts)
      exe 'let _saveopts["' . key . '"]=&' . key
      exe 'let &' . key . '=' . val
    endfor
    exe a:cmd
  finally
    for [key, val] in items(_saveopts)
      exe 'let &' . key . '=' . val
    endfor
  endtry
endfunction
