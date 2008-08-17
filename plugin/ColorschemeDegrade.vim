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

let g:colorschemedegrade_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" A local copy of rgb.txt must be included, since I can't count on it being in
" a standard location.  But, we won't load it unless we need it.
let s:rgb = {}

" Determine if synIDattr() is usable on this machine, or if we instead need to
" use :redir to find information about syntax groups.  As of 7.2.000,
" synIDattr() can't be used to check 'guisp', and no patch has been released.
function! s:NeedRedirFallback()
  if !exists("g:colorschemedegrade_redirfallback")
    hi ColorSchemeDegradeTest guisp=Red gui=standout
    if synIDattr(hlID('ColorSchemeDegradeTest'), 'sp', 'gui') == '1'
      " We requested the 'sp' attribute, but vim thought we wanted 'standout'
      " So, reporting of the guisp attribute is broken.  Fall back on :redir
      let g:colorschemedegrade_redirfallback=1
    else
      " Reporting guisp works, use synIDattr
      let g:colorschemedegrade_redirfallback=0
    endif
  endif
  return g:colorschemedegrade_redirfallback
endfunction

function! s:Highlights()
  let rv = {}

  let i = 1
  while 1
    if ! hlexists(synIDattr(i, "name"))
      break
    endif

    if !has_key(rv, synIDtrans(i))
      let rv[synIDtrans(i)] = {}

      let rv[synIDtrans(i)].name = synIDattr(synIDtrans(i), "name")

      for where in [ "term", "cterm", "gui" ]
        let rv[synIDtrans(i)][where]  = {}
        for attr in [ "fg", "bg", "sp", "bold", "italic",
                    \ "reverse", "underline", "undercurl" ]
          let rv[synIDtrans(i)][where][attr] = synIDattr(i, attr, where)
        endfor

        if s:NeedRedirFallback()
          redir => temp
          exe 'sil hi ' . synIDattr(synIDtrans(i), "name")
          redir END
          let temp = substitute(temp, '^.*$', '', '')
          let temp = matchstr(temp, where.'sp=\zs\S*\ze')
          let rv[synIDtrans(i)][where]["sp"] = temp
        endif
      endfor
    endif

    let i += 1
  endwhile

  return rv
endfunction

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

"  try
    let rv = s:ColorschemeDegradeImpl()
"  catch
"    let ex = v:exception
"    let rv = -1
"  endtry

  let &lz = savelz

  if exists("ex")
    echoerr 'ColorschemeDegrade failed: ' . substitute(ex, '.\{-}:', '', '')
  endif

  return rv
endfunction

function! s:SetCtermFromGui(hl)
  let hl = a:hl

  " Clear existing highlights
  exe 'hi ' . hl.name . ' term=NONE cterm=NONE ctermbg=NONE ctermfg=NONE'

  " Set background, foreground, and special colors - special must be last!
  for color in [ 'bg', 'fg', 'sp' ]
    let val = hl.gui[color]
    let orig = val

    " Skip unset colors
    if val == -1 || val == ""
      continue
    endif

    " No such thing as 'ctermsp', so if guisp is set we instead will set
    " either ctermfg or ctermbg
    if color == 'sp'
      let color = 'fg'
      if exists('g:colorschemedegrade_sp_is_bg')
        if g:colorschemedegrade_sp_is_bg
          color = 'bg'
        endif
      endif
    endif

    " Try translating anything but 'fb', 'bg', #rrggbb, and rrggbb from an
    " rgb.txt color to a #rrggbb color
    if val !~? '[fb]g' && val !~ '^#\=\x\{6}$'
      if s:rgb == {}
        let s:rgb = colorschemedegradelib#RGB()
      endif
      try
        let val = s:rgb[tolower(substitute(val, ' ', '_', 'g'))]
      catch /^/
        echomsg "ColorschemeDegrade: Unknown color: \"" . orig . "\""
        continue
      endtry
    endif

    if val =~# '[fb]g'
      exe 'hi ' . hl.name . ' cterm' . color . '=' . val
    elseif val =~# '^#\=\x\{6}$'
      let val = substitute(val, '^#', '', '')
      let r = val[0] . val[1]
      let g = val[2] . val[3]
      let b = val[4] . val[5]
      exe 'hi ' . hl.name . ' cterm' . color . '=' . s:FindClosestCode(r,g,b)
    else
      echoerr "ColorschemeDegrade: Failed to handle color: " . orig
      continue
    endif

    let attrs = ""
    for attr in [ "bold", "italic", "reverse", "underline", "undercurl" ]
      if hl.gui[attr] == 1
        let attrs .= ',' . attr
      endif
    endfor
    if attrs != ''
      exe 'hi ' . hl.name . ' cterm=' . attrs[1:]
    endif
  endfor
endfunction

function! s:SortNormalFirst(num1, num2)
  return a:num1 == hlID('Normal') ? -1 : a:num2 == hlID('Normal') ? 1 : 0
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
  if ! exists("s:highlights")
    let s:highlights = {}
  endif

  let highlights = s:Highlights()

  " Create a list of colors that have changed since the last iteration
  let modified = []
  for hl in keys(highlights)
    if !has_key(s:highlights, hl) || s:highlights[hl] != highlights[hl]
      " Only include ones that weren't already set above 15
      if highlights[hl].cterm.fg <= 15 && highlights[hl].cterm.bg <= 15
        let modified += [hl]
      endif
    endif
  endfor

  " And store the new highlight hash for the next iteration
  let s:highlights = highlights

  " Then, set all the modified colors to approximate the gui colors.
  call sort(modified, "s:SortNormalFirst")

  for hlnum in modified
    call s:SetCtermFromGui(highlights[hlnum])
  endfor

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
