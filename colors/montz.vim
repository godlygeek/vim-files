" Vim color file
" Thanks to Connor Berry for his Montz configuration
" Maintainer: Victor B. Gonzalez
" Last Change: 2008/12/28
" Version: 1.0

set background=light
"""highlight clear
"""if exists("syntax on")
"""set t_Co=256
  """syntax reset
"""endif

let g:colors_name = "montz"

" Would not be possible without
" http://www.vim.org/scripts/script.php?script_id=1349

    hi clear Normal | hi Normal ctermfg=232 ctermbg=white guifg=#080808
    hi clear Statement | hi Statement ctermfg=28 guifg=#008700
    hi clear Function | hi Function cterm=bold ctermfg=208 gui=bold guifg=#ff8700

    hi clear Repeat | hi Repeat ctermfg=238 guifg=#444444
    hi clear Conditional | hi Conditional ctermfg=238 guifg=#444444
    hi clear Operator | hi Operator ctermfg=238 guifg=#444444
    hi clear Define | hi Define ctermfg=238 guifg=#444444

    hi clear Special | hi Special ctermfg=18 guifg=#000087
    hi clear Directory | hi Directory ctermfg=208 guifg=#ff8700
    hi clear treeCWD | hi treeCWD cterm=bold ctermfg=108 gui=bold guifg=#87af87
    hi clear treeDirSlash | hi treeDirSlash ctermfg=208 guifg=#ff8700
    hi clear treeFile | hi treeFile ctermfg=238 guifg=#444444
    hi clear treePart | hi treePart ctermfg=252 guifg=#d0d0d0
    hi clear treePartFile | hi treePartFile ctermfg=252 guifg=#d0d0d0
    hi clear treeClosable | hi treeClosable ctermfg=252 guifg=#d0d0d0
    hi clear treeOpenable | hi treeOpenable ctermfg=252 guifg=#d0d0d0

        " Some Python syntax specifics I am unable to see in action
        hi clear pythonsync | hi pythonsync ctermfg=196 ctermbg=220 guifg=#ff0000 guibg=#ffd700
        hi clear vimpythonregion | hi vimpythonregion ctermfg=196 ctermbg=220 guifg=#ff0000 guibg=#ffd700

        " These are fine, gotta highlight them all!
        let python_highlight_all = 1
        hi clear pythonBuiltin | hi pythonBuiltin ctermfg=238 guifg=#444444
        hi clear pythonException | hi pythonException ctermfg=196 guifg=#ff0000
        hi clear pythonSpaceError | hi pythonSpaceError ctermbg=226 guifg=#ffff00
        hi clear pythonDecorator | hi pythonDecorator ctermfg=208 guifg=#ff8700

    hi clear PreCondit | hi PreCondit cterm=bold ctermfg=233 gui=bold guifg=#121212
    hi clear Todo | hi Todo cterm=bold ctermfg=246 gui=bold guifg=#949494
    hi clear Comment | hi Comment ctermfg=246 guifg=#949494
    hi clear String | hi String ctermfg=18 guifg=#000087

    hi clear CursorLine | hi CursorLine cterm=bold ctermbg=none gui=bold "hmmm
    hi clear Gutter | hi Gutter ctermbg=255 guifg=#eeeeee
    hi clear StatusLine | hi StatusLine ctermfg=18 ctermbg=255 guifg=#000087 guibg=#eeeeee
    hi clear StatusLineNC | hi StatusLineNC ctermfg=248 ctermbg=230 guifg=#a8a8a8 guibg=#ffffd7
    hi clear VertSplit | hi VertSplit ctermfg=255 guifg=#eeeeee
    hi clear LineNr | hi LineNr ctermfg=250 guifg=#bcbcbc

    hi clear MatchParen | hi MatchParen ctermfg=196 guifg=#ff0000
    hi clear Pmenu | hi Pmenu ctermfg=18 ctermbg=255 guifg=#000087 guibg=#eeeeee
    hi clear PmenuSel | hi PmenuSel cterm=bold ctermbg=none gui=bold "hmmm
    hi clear PmenuSbar | hi PmenuSbar ctermbg=none "hmmm
    hi clear PmenuThumb | hi PmenuThumb ctermbg=18 guibg=#000087
    hi clear ErrorMsg | hi ErrorMsg ctermfg=196 guifg=#ff0000
    hi clear Visual | hi Visual term=reverse ctermbg=255 gui=reverse guibg=#eeeeee
    hi clear NonText | hi NonText ctermfg=255 guifg=#eeeeee
    hi clear Identifier | hi Identifier ctermfg=160 guifg=#d70000

    " Most of these colors for some reason are not applied! and no gui for
    " them either!
    "hi clear TagListComment | hi TagListComment ctermfg=196
    "hi clear TagListFileName | hi TagListFileName ctermfg=196
    "hi clear TagListTitle | hi TagListTitle ctermfg=196
    "hi clear TagListTagScope | hi TagListTagScope ctermfg=196
    "hi clear TagListTagName | hi TagListTagName ctermfg=196

" vim:ts=2:sw=2:et


