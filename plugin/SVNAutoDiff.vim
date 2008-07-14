let savecpo = &cpo
set cpo&vim

if(!exists("s:autocmds_loaded"))
  autocmd VimEnter svn-commit.tmp call <SID>SVNAutoDiff()
  let s:autocmds_loaded = 1
endif

function! s:SVNAutoDiff()
  let ci_buff = bufnr("")
  vsplit
  wincmd w

  let files = ""
  let pos = line("$")
  while 1
    let line     = getline(pos)

    if line =~ '^\s*$'
      break
    endif

    let files .= escape(substitute(line, '^\([MAD]\)\s*', '', ''), ' \') . ' '
    let pos      = pos - 1
  endwhile

  enew
  setlocal buftype=nofile bufhidden=delete nobuflisted
  setlocal ft=diff nobackup noswapfile nowrap
  " Autocommand executed upon entering the diff pane that closes the diff pane if the commit pane is closed
  exe "autocmd BufEnter <buffer> if bufwinnr(" . ci_buff . ") == -1 | quit | endif"
  silent exe "keepjumps r! svn diff " . files
  keepjumps goto 1
  silent d _

  echo bufwinnr(ci_buff)
  silent exe bufwinnr(ci_buff) . "winc w"
endfunction

let &cpo = savecpo
unlet savecpo
