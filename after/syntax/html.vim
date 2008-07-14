syn keyword  htmlError  TODO XXX FIXME  containedin=htmlCommentPart  contained
syn match    htmlNote   'NOTE:'         containedin=htmlCommentPart  contained

hi def link  htmlError  Error
hi def link  htmlNote   PreProc
