" ColorschemeDegrade:  Degrade gvim colorschemes to be suitable for a terminal
" Maintainer:          Matthew Wozniski (mjw@drexel.edu)
" Date:                Sun, 21 Oct 2007 21:04:33 -0400
" Version:             0.2
" History:             TODO(History Link)
" Installation:        Drop this script into ~/.vim/plugin.

" Whenever you change colorschemes using the :colorscheme command, this script
" will be executed.  If you're running in 256 color terminal or an 88 color
" terminal, as reported by the command ":echo &t_Co" it will take the colors
" that the scheme specified for use in the gui and use an approximation
" algorithm to try to gracefully degrade them to the closest color available.
" If you are running in a gui or if t_Co is reported as less than 88 colors,
" no changes are made.

" TODO:
"   Be a little less braindead in handling g:colors_name - detect in advance
"   if a colorscheme set it to something that couldn't possibly be right
"   - that is, len(globpath(&rtp, 'colors/' . g:colors_name . '.vim')) == 0
"
"   Try falling back on :scriptnames to see what */colors/*.vim was loaded?
"
"   Do I even need to care what */colors/*.vim was loaded?

" Abort if running in vi-compatible mode or the user doesn't want or need us.
if &cp || has("gui_running") || ! has("gui") || exists('g:colorschemedegrade_loaded')
  if &cp && &verbose
    echomsg "Not loading ColorschemeDegrade in compatible mode."
  endif
  if has('gui_running') && &verbose
    echomsg "Not loading ColorschemeDegrade in gui mode."
  endif
  if ! has('gui') && &verbose
    echomsg "Unfortunately, ColorschemeDegrade needs gui support.  Not loading."
  endif
  finish
endif

" A local copy of rgb.txt must be included, since I can't count on it being in
" a standard location.  But, we won't load it unless we need it.
let s:rgb = {}

let g:colorschemedegrade_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" Script-local variables                                                  {{{1

" Script-local variables defining the rgb vals on a 256-color cube        {{{2

" Every possible 256-color cube color is made up of 3 rgb values, all out of
" this table.
let s:vals_greys_256 = [   0,   8,  18,  28,  38,
                       \  48,  58,  68,  78,  88,
                       \  95,  98, 108, 118, 128,
                       \ 135, 138, 148, 158, 168,
                       \ 175, 178, 188, 198, 208,
                       \ 215, 218, 228, 238, 255  ]

" Many of those colors can only be used for a grey (r == g == b).  This subset
" can be mix-and-matched.
let s:vals_color_256 = [  0,  95, 135, 175, 215, 255 ]

" This table holds the midpoints between each of the possible grey values, as
" well as one extra element higher than all, to be used in the approximation
" algorithm.
let s:mids_greys_256 = [   4,  13,  23,  33,  43,
                       \  53,  63,  73,  83,  91,
                       \  96, 103, 113, 123, 131,
                       \ 136, 143, 153, 163, 171,
                       \ 176, 183, 193, 203, 211,
                       \ 216, 223, 233, 246, 256  ]

" This table is the same, only for the non-grey midpoints.
let s:mids_color_256 = [ 48, 115, 155, 195, 235, 256 ]

" Script-local variables defining the rgb vals on a 88-color cube         {{{2

" Every possible 88-color cube color is made up of 3 rgb values, all out of
" this table.
let s:vals_greys_88 = [   0,  46,  92, 115, 139, 162,
                      \ 185, 205, 208, 231, 255       ]

" Many of those colors can only be used for a grey (r == g == b).  This subset
" can be mix-and-matched.
let s:vals_color_88 = [ 0, 139, 205, 255 ]

" This table holds the midpoints between each of the possible grey values, as
" well as one extra element higher than all, to be used in the approximation
" algorithm.
let s:mids_greys_88 = [  23,  69, 103, 127, 150, 173,
                      \ 195, 206, 219, 243, 256       ]

" This table is the same, only for the non-grey midpoints.
let s:mids_color_88 = [ 69, 172, 230, 256 ]

" Function definitions                                                    {{{1

" Given 3 hex strings rr, gg, bb, return the closest color cube number.
function! s:FindClosestCode(h1,h2,h3)
  let d1 = str2nr(a:h1, 16)
  let d2 = str2nr(a:h2, 16)
  let d3 = str2nr(a:h3, 16)

  let r = s:FindClosest(d1, s:vals_greys_{&t_Co}, s:mids_greys_{&t_Co})
  let g = s:FindClosest(d2, s:vals_greys_{&t_Co}, s:mids_greys_{&t_Co})
  let b = s:FindClosest(d3, s:vals_greys_{&t_Co}, s:mids_greys_{&t_Co})

  if(r == g && g == b)
    return s:GreyComponentTo{&t_Co}Cube(r)
  else
    let r = s:FindClosest(d1, s:vals_color_{&t_Co}, s:mids_color_{&t_Co})
    let g = s:FindClosest(d2, s:vals_color_{&t_Co}, s:mids_color_{&t_Co})
    let b = s:FindClosest(d3, s:vals_color_{&t_Co}, s:mids_color_{&t_Co})
    return s:RGBComponentsTo{&t_Co}Cube(r, g, b)
  endif
endfunction

" Given a number, an array of elements, and an array of midpts, find the index
" of the least midpt that the number is strictly less than, and return the
" corresponding element.
function! s:FindClosest(num, elems, midpts)
  for i in range(len(a:elems))
    if ( a:num < a:midpts[i] )
      return a:elems[i]
    endif
  endfor
endfunction

" Expects a decimal value 'x' between 0 and 255, inclusive
" Returns a 256-color colorcube number for the color at RGB=x,x,x
function! s:GreyComponentTo256Cube(num)
  if(a:num % 10 == 8)
    return 232 + (a:num - 8) / 10
  else
    " Not in the greyscale ramp, so we can use our normal processing
    return s:RGBComponentsTo256Cube(a:num, a:num, a:num)
  endif
endfunction

" Expects a decimal value 'x' between 0 and 255, inclusive
" Returns an 88-color colorcube number for the color at RGB=x,x,x
function! s:GreyComponentTo88Cube(num)
  if a:num == 46
    return 80
  elseif a:num == 92
    return 81
  elseif a:num == 115
    return 82
  elseif a:num == 139
    return 83
  elseif a:num == 162
    return 84
  elseif a:num == 185
    return 85
  elseif a:num == 208
    return 86
  elseif a:num == 231
    return 87
  else
    " Not in the greyscale ramp, so we can use our normal processing
    return s:RGBComponentsTo88Cube(a:num, a:num, a:num)
  endif
endfunction

" Expects 3 decimal values 'r', 'g', and 'b', each between 0 and 255 inclusive.
" Returns a 256-color colorcube number for the color at RGB=r,g,b.
" Will not use the greyscale ramp.
function! s:RGBComponentsTo256Cube(r,g,b)
  let rc = index(s:vals_color_256, a:r)
  let gc = index(s:vals_color_256, a:g)
  let bc = index(s:vals_color_256, a:b)

  return (rc * 36 + gc * 6 + bc + 16)
endfunction

" Expects 3 decimal values 'r', 'g', and 'b', each between 0 and 255 inclusive.
" Returns a 88-color colorcube number for the color at RGB=r,g,b.
" Will not use the greyscale ramp.
function! s:RGBComponentsTo88Cube(r,g,b)
  let rc = index(s:vals_color_88, a:r)
  let gc = index(s:vals_color_88, a:g)
  let bc = index(s:vals_color_88, a:b)

  return (rc * 16 + gc * 4 + bc + 16)
endfunction

" Check if the provided value is found in "g:colorschemedegrade_ignore", which
" may either be a list or a comma or space separated string.  If the variable
" "g:colorschemedegrade_ignore" is not present, the default is "bold italic"
function! s:ignoring(attr)
  if !exists("g:colorschemedegrade_ignore")
    let ignore = [ 'bold', 'italic' ]
  elseif type(g:colorschemedegrade_ignore) == type("")
    let ignore = split(g:colorschemedegrade_ignore, '[ ,]')
  elseif type(g:colorschemedegrade_ignore) == type([])
    let ignore = g:colorschemedegrade_ignore
  else
    return 0
  endif

  return index(ignore, a:attr) != -1
endfunction

" Sets some settings, calls s:ColorschemeDegradeImpl to handle actually
" degrading the colorscheme, then restores the settings.  This wrapper
" should make sure that we don't accidentally recurse, and that settings are
" restored properly even if something throws.
function! s:ColorschemeDegrade()
  let savelz = &lz
  set lz

  try
    let rv = s:ColorschemeDegradeImpl()
  catch
    let ex = v:exception
    let rv = -1
  endtry

  let &lz = savelz

  if exists("ex")
    echoerr 'ColorschemeDegrade failed: ' . substitute(ex, '.\{-}:', '', '')
  endif

  return rv
endfunction

function! s:HashHighlights()
  let highlights = {}

  let i = 1
  while 1
    if strlen(synIDattr(i, "name")) == 0
      break
    endif
    let highlights[synIDtrans(i)] = ""
    let i += 1
  endwhile

  for i in keys(highlights)
    let highlights[i] = {}
    let highlights[i].name           = synIDattr(i, 'name',      'gui'  )
    let highlights[i].guifg          = synIDattr(i, 'fg',        'gui'  )
    let highlights[i].guibg          = synIDattr(i, 'bg',        'gui'  )
    let highlights[i].guibg          = synIDattr(i, 'sp',        'gui'  )
    let highlights[i].ctermfg        = synIDattr(i, 'fg',        'cterm')
    let highlights[i].ctermbg        = synIDattr(i, 'bg',        'cterm')

    let highlights[i].guibold        = synIDattr(i, 'bold',      'gui')
    let highlights[i].guiitalic      = synIDattr(i, 'italic',    'gui')
    let highlights[i].guireverse     = synIDattr(i, 'reverse',   'gui')
    let highlights[i].guiunderline   = synIDattr(i, 'underline', 'gui')
    let highlights[i].guiundercurl   = synIDattr(i, 'undercurl', 'gui')

    let highlights[i].ctermbold      = synIDattr(i, 'bold',      'cterm')
    let highlights[i].ctermitalic    = synIDattr(i, 'italic',    'cterm')
    let highlights[i].ctermreverse   = synIDattr(i, 'reverse',   'cterm')
    let highlights[i].ctermunderline = synIDattr(i, 'underline', 'cterm')
    let highlights[i].ctermundercurl = synIDattr(i, 'undercurl', 'cterm')
  endfor

  return highlights
endfunction

" For every highlight group, sets the cterm values to the best approximation
" of the gui values possible given the value of &t_Co.
function! s:ColorschemeDegradeImpl()
  " Return if not running in an 88/256 color terminal
  if has('gui_running') || (&t_Co != 256 && &t_Co != 88)
    if &verbose && ! has('gui_running')
      echomsg "ColorschemeDegrade skipped; terminal only has" &t_Co "colors."
    endif
    return
  endif

  " Initialize a hash if not already done
  if ! exists("s:hlhash")
    let s:hlhash = {}
  endif

  " Create references for the old and new hashes
  let oldhash = s:hlhash
  let newhash = s:HashHighlights()

  " Create a list of colors that have changed since the last iteration
  let modified = []
  for hl in newhash
    if !has_key(oldhash, hl) || oldhash[hl] != newhash[hl]
      let modified += [hl]
    endif
  endfor

  " And store the new highlight hash for the next iteration
  let s:hlhash = newhash

  " Abort if the scheme set some cterm colors to above 15
  " We don't want to change a scheme that was already 88/256 color
  " FIXME Make forceable
  let low_color = 1

  for hl in modified
    if s:hlhash[hl].ctermfg > 15 || s:hlhash[hl].ctermbg > 15
      let low_color = 0
      break
    endif
  endfor

  if low_color == 0
    if &verbose
      echomsg "ColorschemeDegrade skipped - colorscheme set some high colors."
    endif
    return
  endif

  " Then, set all the colors to approximate the gui colors.
  call filter(hilines, 'v:val !~ "links to" && v:val !~ "cleared"')

  let i = 0
  let end = len(hilines)

  while i < end
    let line = hilines[i]
    let i += 1
    while i < end && hilines[i] !~ '\<xxx\>'
      let line .= hilines[i]
      let i += 1
    endwhile
    let line = substitute(line, '\<st\(art\|op\)=.\{-}\S\@!', '', 'g')
    let line = substitute(line, '\<c\=term.\{-}=.\{-}\S\@!', '', 'g')
    let line = substitute(line, '\<xxx\>', '', '')
    let line = substitute(line, '\<gui', 'cterm', 'g')
    let line = substitute(line, '\s\+', ' ', 'g')

    let items = split(line, '\%(\s\zecterm\|font\)\|=')

    let higrp = items[0]
    if len(items) % 2 != 1
      echoerr "I cannot understand the highlight group "
             \ . string(items) . ' at line ' . hilines[i]
    endif

    " Start clean
    exe 'hi ' . higrp . ' term=NONE cterm=NONE ctermbg=NONE ctermfg=NONE'

    for j in range((len(items)-1)/2)
      " TODO Can we handle 16 color terminals?  Probably, if we're in an xterm.
      let var = items[2*j+1]
      let val = items[2*j+2]
      if var == 'ctermsp'
        if exists('g:colorschemedegrade_sp_is_bg') && g:colorschemedegrade_sp_is_bg
          let var = 'ctermbg'
        else
          let var = 'ctermfg'
        endif
      endif
      if var == 'cterm'
        if s:ignoring('bold')
          let val = substitute(val, 'bold', '', '')
        endif
        if s:ignoring('underline')
          let val = substitute(val, 'underline', '', '')
        endif
        if s:ignoring('undercurl')
          let val = substitute(val, 'undercurl', '', '')
        endif
        if s:ignoring('reverse') || s:ignoring('inverse')
          let val = substitute(val, '\%(re\|in\)verse', '', '')
        endif
        if s:ignoring('italic')
          let val = substitute(val, 'italic', '', '')
        endif
        if s:ignoring('standout')
          let val = substitute(val, 'standout', '', '')
        endif
        let val = substitute(val, '\(^,*\|,*$\)', '', '')
        let val = substitute(val, ',\+', ',', 'g')
        let val = substitute(val, '^,*$', 'NONE', '')

        exe 'hi ' . higrp . ' ' . var . '=' . val
      elseif var =~ 'cterm[fb]g'
        if val =~ '[FBfb]g'
          let val = tolower(val)
          if var =~ val
            let val = "NONE"
          endif
          "echomsg 'higrp=' . higrp . ' var=' . var . ' val=' . val
          exe 'hi ' . higrp . ' ' . var . '=' . val
          continue
        elseif val !~ '^#'
          try
            " We do need our cooked rgb.txt
            if s:rgb == {}
              let s:rgb = colorschemedegradelib#RGB()
            endif
            let val = s:rgb[tolower(substitute(val, ' ', '_', 'g'))]
          catch
            echomsg "Cannot translate color \"" . val . "\""
            continue
          endtry
        endif

        if v:termresponse =~ '>8[35];'
              \ && exists('g:colorschemedegrade_changecube')
              \ && g:colorschemedegrade_changecube
          if !exists("s:lastcubepos")
            let s:lastcubepos="15"
            let s:colors = {}
          endif

          let tisave = &t_ti
          let tesave = &t_te
          set t_ti= t_te=

          if has_key(s:colors, tolower(val))
            let nr = s:colors[tolower(val)]
          else
            let s:lastcubepos = s:lastcubepos + 1

            if s:lastcubepos >= &t_Co
              let s:lastcubepos = 16
            endif

            let nr = s:lastcubepos
            let s:colors[tolower(val)] = nr

            if $STY == ""
              exe 'sil !echo -n -e "\\033]4;' . nr . ';\' . val . '\\a"'
            else
              exe 'sil !echo -n -e "\\033P\\033]4;' . nr . ';\' . val . '\\a\\033\\\\"'
            endif
          endif

          let &t_ti = tisave
          let &t_te = tesave
          exe 'hi' higrp var.'='.nr
        else
          let r = val[1] . val[2]
          let g = val[3] . val[4]
          let b = val[5] . val[6]
          exe 'hi ' . higrp . ' ' . var . '=' . s:FindClosestCode(r, g, b)
        endif
      endif
    endfor
  endwhile
  if exists("s:lastcubepos")
    unlet s:lastcubepos
  endif
endfunction

" Dirty hacks.                                                            {{{1

augroup ColorSchemeDegrade
  au!
  au ColorScheme * call s:ColorschemeDegrade()
augroup END

call s:ColorschemeDegrade()

let &cpo = s:savecpo
unlet s:savecpo

" vim:set sw=2 sts=2 fdm=marker:
