let s:savecpo = &cpo
set cpo&vim

if !exists('b:undo_ftplugin')
    let b:undo_ftplugin = ''
endif

let b:undo_ftplugin .= "| nunmap <buffer> [["
                   \ . "| nunmap <buffer> []"
                   \ . "| nunmap <buffer> ]["
                   \ . "| nunmap <buffer> ]]"
                   \ . "| vunmap <buffer> [["
                   \ . "| vunmap <buffer> []"
                   \ . "| vunmap <buffer> ]["
                   \ . "| vunmap <buffer> ]]"

"let s:unit_pat = '^      \zs\s*\c\%(subroutine\|entry\|\%(integer\|real\|double\s\+precision\|complex\|logical\|character\%(\s*\*\s*\d\+\|\s*(\s*\d\+\s*)\)\=\)\s*function\|program\)'
let s:unit_pat = '^      \zs\s*\c\%(subroutine\|entry\|\%(integer\|real\|double\s\+precision\|complex\|logical\|character\)\%(\s*\*\s*\d\+\|\s*(\s*\d\+\s*)\)\=\s*function\|program\)'
let s:end_pat = '^ .... \zs\s*\cend'

function! s:previous_unit_end()
    let orig = line('.')

    call s:previous_unit_begin()
    let unit_start = line('.')

    call s:next_unit_end()
    let unit_end = line('.')

    if orig > unit_end
        exe unit_end
    else
        exe unit_start
        if !search(s:end_pat, 'bsW')
            1
            return
        endif
    endif
endfunction

function! s:previous_unit_begin()
    if !search(s:unit_pat, 'bsW')
        1
        return
    endif
endfunction

function! s:next_unit_begin()
    if !search(s:unit_pat,  'sW')
        $
        return
    endif
endfunction

function! s:next_unit_end()
    if !search(s:end_pat, 'sW')
        $
        return
    endif

    call s:next_unit_begin()

    if !search(s:end_pat, 'bsW')
        $
        return
    endif
endfunction

nnoremap <buffer> <silent> [] :call <SID>previous_unit_end()<CR>
nnoremap <buffer> <silent> [[ :call <SID>previous_unit_begin()<CR>
nnoremap <buffer> <silent> ]] :call <SID>next_unit_begin()<CR>
nnoremap <buffer> <silent> ][ :call <SID>next_unit_end()<CR>

vnoremap <buffer> <silent> [] <C-\><C-n>:<C-u>call <SID>previous_unit_end()<CR>:exe "norm gv" . line('.') . 'G'<CR>
vnoremap <buffer> <silent> [[ <C-\><C-n>:<C-u>call <SID>previous_unit_begin()<CR>:exe "norm gv" . line('.') . 'G'<CR>
vnoremap <buffer> <silent> ]] <C-\><C-n>:<C-u>call <SID>next_unit_begin()<CR>:exe "norm gv" . line('.') . 'G'<CR>
vnoremap <buffer> <silent> ][ <C-\><C-n>:<C-u>call <SID>next_unit_end()<CR>:exe "norm gv" . line('.') . 'G'<CR>

let &cpo = s:savecpo
unlet s:savecpo
