let s:savecpo = &cpo
set cpo&vim

if !exists('b:undo_ftplugin')
    let b:undo_ftplugin = ''
endif

let b:undo_ftplugin .= "| setl sts< sw< ts< et<"
                   \ . "| nunmap <buffer> >>"
                   \ . "| nunmap <buffer> >"
                   \ . "| vunmap <buffer> >"
                   \ . "| nunmap <buffer> <<"
                   \ . "| nunmap <buffer> <"
                   \ . "| vunmap <buffer> <"

setlocal sts=3 sw=3 ts=8 et

function! s:indent(count) range
    for i in range(a:firstline, a:lastline)
        let line = getline(i)
        let c = (line[0] == ' ' ? 5 : 0)
        if a:count >= 0
            let line = line[0:c] . repeat(' ', &sw * a:count) . line[c+1:]
        else
            let pattern = '\%>' . (c+1) . 'c \{,' . (-a:count * &sw) . '\}'
            let line = substitute(line, pattern, '', '')
        endif
        let line = substitute(line, '\s\+$', '', '')
        call setline(i, line)
    endfor
endfunction

function! s:opfunc(unused)
    let beg = line("'[")
    let end = line("']")

    "echomsg "opfunc: beg " . beg . " end " . end . ' lm ' . s:line_multiplier
    "      \ . ' sm ' . s:shift_multiplier

    if end < beg " This seems to happen with a motion of '0'... Why?
        let end = beg
    endif

    let end = beg + (end - beg) * s:line_multiplier
    exe beg . ',' . end . 'call s:indent(s:shift_multiplier)'
endfunction

function! s:setup_opfunc(line_multiplier, shift_multiplier)
    let s:line_multiplier  = a:line_multiplier
    let s:shift_multiplier = a:shift_multiplier
endfunction

vnoremap <buffer> <silent>  > :<C-u>call <SID>setup_opfunc(
                              \ line("'>") - line("'<"), v:count1)<Bar>
                              \ set opfunc=<SID>opfunc<CR>g@j
nnoremap <buffer> <silent>  > :<C-u>call <SID>setup_opfunc(v:count1, 1)<Bar>
                              \ set opfunc=<SID>opfunc<CR>g@
nnoremap <buffer> <silent> >> :<C-u>call <SID>setup_opfunc(v:count1-1, 1)<Bar>
                              \ set opfunc=<SID>opfunc<CR>g@j

vnoremap <buffer> <silent>  < :<C-u>call <SID>setup_opfunc(
                              \ line("'>") - line("'<"), -v:count1)<Bar>
                              \ set opfunc=<SID>opfunc<CR>g@j
nnoremap <buffer> <silent>  < :<C-u>call <SID>setup_opfunc(v:count1, -1)<Bar>
                              \ set opfunc=<SID>opfunc<CR>g@
nnoremap <buffer> <silent> << :<C-u>call <SID>setup_opfunc(v:count1-1, -1)<Bar>
                              \ set opfunc=<SID>opfunc<CR>g@j

let &cpo = s:savecpo
unlet s:savecpo
