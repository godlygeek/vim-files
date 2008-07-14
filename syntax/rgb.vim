" Syntax plugin for rgb (rgb.txt) files
" Language:		rgb.txt
" Maintainer:		Tony Mechelynck <antoine.mechelynck@skynet.be>
" Last Change:		9 May 2007

sy match rgbError /^.*$/
hi def link rgbError Error

sy match rgbComment /^!.*$/ display
hi def link rgbComment Comment

sy match rgbLine transparent /^\s*\d\+\s\+\d\+\s\+\d\+\s\+\a.*$/ contains=rgbNumber,rgbName

sy match rgbNumber /\<\d\+\>/ contained
hi def link rgbNumber Number

sy match rgbName /\<\a.*$/ contained
hi def link rgbName Identifier
