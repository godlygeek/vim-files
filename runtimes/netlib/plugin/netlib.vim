if exists("g:netlib_loaded")
  finish
endif

let g:netlib_loaded = 1
let g:loaded_netrwPlugin = 'replaced with netlib'

let s:savecpo = &cpo
set cpo&vim

try
  augroup Network
    au!
    au BufReadCmd    *://* call netlib#HandleBufRead    (expand("<amatch>"))
    au FileReadCmd   *://* call netlib#HandleFileRead   (expand("<amatch>"))
    au BufWriteCmd   *://* call netlib#HandleBufWrite   (expand("<amatch>"))
    au FileWriteCmd  *://* call netlib#HandleFileWrite  (expand("<amatch>"))
    au FileAppendCmd *://* call netlib#HandleFileAppend (expand("<amatch>"))
    au SourceCmd     *://* call netlib#HandleSource     (expand("<amatch>"))
  augroup END
catch
endtry

runtime! netplugin/**/*.vim

let &cpo = s:savecpo
unlet s:savecpo
