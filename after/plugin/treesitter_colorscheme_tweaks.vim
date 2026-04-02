function! s:tweak_colors()
    hi link @parameter Normal
    hi link @property Normal
    hi link @variable Normal
    hi link @field Normal
    hi link @function Normal
    hi link @method Normal

    hi link @namespace Include
endfunction


augroup TweakColors
    autocmd!
    autocmd ColorScheme * call s:tweak_colors()
augroup END

call s:tweak_colors()
