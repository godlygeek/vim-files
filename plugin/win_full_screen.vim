" File: win_full_screen.vim
" Author: Nickolay Golubev
" Email: golubev.nikolay@gmail.com
" Description: Script for maximize current window and restore others windows sizes after
" Usage:
"   Command :WinFullScreen to maximize current window
"   Command :WinFullScreen again (or move to another window or tab) restore
"   windows sizes
"   Map :WinFullScreen for any key you like and enjoy vim's windows

if exists('win_full_screen_plugin')
    "finish
endif

let win_full_screen_plugin = 1

let s:windows_sizes = []
let s:full_screen = 0

function! s:SaveWindowsSize()
    let s:windows_sizes = []

    let s:minwinwidth = &winminwidth
    let s:minwinheight = &winminheight

    for win_number in range(1, winnr('$'))
        let win_width = winwidth(win_number)
        let win_height = winheight(win_number)

        call add(s:windows_sizes, [win_width, win_height])
    endfor
endfunction

function! s:RestoreWindowsSize()
    augroup fullScreenToggleAU
        au!
    augroup END

    let win_count = len(s:windows_sizes)
    let curr_window = winnr()
    
    for adjustment in range(2)
        for win_number in range(win_count)
            exec win_number+1.'wincmd w'   
            let width = s:windows_sizes[win_number][0]
            let height = s:windows_sizes[win_number][1]
            exec 'vertical resize '.width
            exec 'resize '.height
        endfor
    endfor

    exec curr_window.'wincmd w'   
endfunction

function! s:EnterFullScreen()
    let s:full_screen = 1
    call s:SaveWindowsSize()

    exec 'resize 1000'
    exec 'vertical resize 1000'

    augroup fullScreenToggleAU
        au!
        au WinLeave * call s:LeaveFullScreen()
    augroup END
endfunction

function! s:LeaveFullScreen()
    let s:full_screen = 0
    call s:RestoreWindowsSize()
endfunction

function! s:ToggleFullScreen()
    if s:full_screen
        call s:LeaveFullScreen()
        return
    endif

    call s:EnterFullScreen()
endfunction

command! WinFullScreen call s:ToggleFullScreen()

