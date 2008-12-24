set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "asdf"

hi Normal guifg=black guibg=white
hi Constant guifg=darkmagenta
hi String guifg=darkmagenta
hi Special guifg=darkmagenta
hi Statement guifg=blue
hi Comment guifg=black gui=italic
hi Conditional guifg=blue gui=bold
hi Cursor guifg=white guibg=black
hi CursorColumn guibg=gray90
hi CursorIM gui=None
hi CursorLine guibg=gray90
hi LineNr guifg=black
hi IncSearch gui=reverse
hi MatchParen guibg=cyan
hi StatusLine guifg=white guibg=black
hi StatusLineNC gui=reverse guifg=black
hi TabLine gui=underline guibg=lightgrey
hi TabLineFill gui=reverse
hi VertSplit gui=reverse
hi Visual gui=reverse guifg=grey guibg=black
hi VisualNOS gui=bold,underline
hi Statement guifg=blue
hi Comment guifg=black gui=italic
hi Conditional guifg=blue gui=bold

hi clear SpecialKey
hi clear PreProc
hi clear Function
hi clear DiffAdd
hi clear DiffChange
hi clear DiffDelete
hi clear DiffText
hi clear Directory
hi clear Error
hi clear ErrorMsg
hi clear FoldColumn
hi clear Folded
hi clear Ignore
hi clear ModeMsg
hi clear MoreMsg
hi clear NonText
hi clear Pmenu
hi clear PmenuSbar
hi clear PmenuSel
hi clear PmenuThumb
hi clear Question
hi clear Search
hi clear SignColumn
hi clear SpellBad
hi clear SpellCap
hi clear SpellLocal
hi clear SpellRare
hi clear TabLineSel
hi clear Title
hi clear Todo
hi clear Type
hi clear Underlined
hi clear WildMenu
hi clear Boolean
hi clear Character
hi clear Debug
hi clear Define
hi clear Delimiter
hi clear Exception
hi clear Float
hi clear Identifier
hi clear Include
hi clear Keyword
hi clear Label
hi clear Macro
hi clear Number
hi clear Operator
hi clear PreCondit
hi clear Repeat
hi clear SpecialChar
hi clear SpecialComment
hi clear StorageClass
hi clear Structure
hi clear Tag
hi clear Typedef

hi link SpecialKey Normal
hi link PreProc Normal
hi link Function Normal
hi link DiffAdd Normal
hi link DiffChange Normal
hi link DiffDelete Normal
hi link DiffText Normal
hi link Directory Normal
hi link Error Normal
hi link ErrorMsg Normal
hi link FoldColumn Normal
hi link Folded Normal
hi link Ignore Normal
hi link ModeMsg Normal
hi link MoreMsg Normal
hi link NonText Normal
hi link Pmenu Normal
hi link PmenuSbar Normal
hi link PmenuSel Normal
hi link PmenuThumb Normal
hi link Question Normal
hi link Search Normal
hi link SignColumn Normal
hi link SpellBad Normal
hi link SpellCap Normal
hi link SpellLocal Normal
hi link SpellRare Normal
hi link TabLineSel Normal
hi link Title Normal
hi link Todo Normal
hi link Type Normal
hi link Underlined Normal
hi link WildMenu Normal
hi link Boolean Normal
hi link Character Normal
hi link Debug Normal
hi link Define Normal
hi link Delimiter Normal
hi link Exception Normal
hi link Float Normal
hi link Identifier Normal
hi link Include Normal
hi link Keyword Normal
hi link Label Normal
hi link Macro Normal
hi link Number Normal
hi link Operator Normal
hi link PreCondit Normal
hi link Repeat Normal
hi link SpecialChar Normal
hi link SpecialComment Normal
hi link StorageClass Normal
hi link Structure Normal
hi link Tag Normal
hi link Typedef Normal
