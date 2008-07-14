" -- PUBLIC FUNCTIONS -- "

" Check how many windows are between a given window and a given edge
function! windowlayout#DistanceFromLeft(winnum)
  return s:NumWindowsInDir(a:winnum, 'h')
endfunction

function! windowlayout#DistanceFromTop(winnum)
  return s:NumWindowsInDir(a:winnum, 'k')
endfunction

function! windowlayout#DistanceFromRight(winnum)
  return s:NumWindowsInDir(a:winnum, 'l')
endfunction

function! windowlayout#DistanceFromBottom(winnum)
  return s:NumWindowsInDir(a:winnum, 'j')
endfunction

" Check which window is above/below/left of/right of a given window
function! windowlayout#WindowAbove(winnum)
  return s:WindowInDir(a:winnum, 'k')
endfunction

function! windowlayout#WindowBelow(winnum)
  return s:WindowInDir(a:winnum, 'j')
endfunction

function! windowlayout#WindowLeftOf(winnum)
  return s:WindowInDir(a:winnum, 'h')
endfunction

function! windowlayout#WindowRightOf(winnum)
  return s:WindowInDir(a:winnum, 'l')
endfunction

" Retrieve the location of a single window
" Returns a dictionary with at least L, R, T, B, x, y, w, h, where
"   L and R are the leftmost/rightmost column inside this window
"   T and B are the topmost/bottommost row inside this window
"   x and y are the leftmost column/topmost row inside this window
"   w and h are the dimensions of this window
"
" Additionally provides the following keys:
" The current window on this tab page has key "curr"
" The previous window on this tab page has key "prev"
" Every window has a key "winnr" set to its window number
" Every window has a key "bufnr" set to its currently displayed buffer
" Every window has a key "line" set to the currently selected line
" Every window has a key "midline" set line in the center of the window
function! windowlayout#GetWindowInfo(winnum)
  call windowlayout#SaveWindows()

  let rv = {}

  let left  = windowlayout#WindowLeftOf(a:winnum)
  let above = windowlayout#WindowAbove(a:winnum)
  let right = windowlayout#WindowRightOf(a:winnum)
  let down  = windowlayout#WindowBelow(a:winnum)

  exe a:winnum . "wincmd w"

  let rv.winnr = a:winnum
  let rv.bufnr = winbufnr(a:winnum)
  let rv.line = line(".")
  let rv.midline = rv.line - winline() + (winheight(".") + 1) / 2

  let rv.w = winwidth('.')
  let rv.h = winheight('.')

  if left == a:winnum
    " Leftmost window
    let rv.x = 1
  else
    let leftpos = windowlayout#GetWindowInfo(left)
    let rv.x = leftpos.x + leftpos.w + 1
  endif

  if above == a:winnum
    " Topmost window
    let rv.y = 1
  else
    let toppos = windowlayout#GetWindowInfo(above)
    let rv.y = toppos.y + toppos.h + 1
  endif

  let rv.L = rv.x
  let rv.T = rv.y
  let rv.R = rv.L + rv.w - 1
  let rv.B = rv.T + rv.h - 1

  if s:currwinnr[tabpagenr()] == a:winnum
    let rv.curr = 1
  elseif s:prevwinnr[tabpagenr()] == a:winnum
    let rv.prev = 1
  endif

  call windowlayout#RestoreWindows()

  return rv
endfunction

" Returns the location of all windows as a list
" Just calls GetWindowInfo once per window and accumulates the results.
function! windowlayout#WindowPositions()
  let rv = []

  call windowlayout#SaveWindows()
  for i in range(1, winnr('$'))
    let rv += [ windowlayout#GetWindowInfo(i) ]
  endfor
  call windowlayout#RestoreWindows()

  return rv
endfunction

" Gets a structure that can be passed to SetLayout() to restore all windows
function! windowlayout#GetLayout()
  let savewiw = &wiw
  let savewmw = &wmw
  let saveei  = &ei

  set wiw=1 wmw=0 ei=all

  call windowlayout#SaveWindows()

  let rv = s:GetLayoutImpl(0, windowlayout#WindowPositions())

  for hookname in s:usedhooks
    let dict = {}
    let dict.function = s:savehooks[hookname]
    for win in s:GetWindowsFromLayout(rv)
      exe win.winnr . "wincmd w"
      call dict.function(win)
    endfor
    unlet dict
  endfor

  call windowlayout#RestoreWindows()

  let &wiw = savewiw
  let &wmw = savewmw
  let &ei  = saveei

  return rv
endfunction

" Restores a window layout saved with GetLayout()
function! windowlayout#SetLayout(layout)
  sil wincmd o

  let lzsave  = &lz
  let eisave  = &ei
  let sbsave  = &sb
  let sprsave = &spr
  let wmhsave = &wmh
  let wmwsave = &wmw
  let wfhsave = &wfh
  let wfwsave = &wfw
  let whsave  = &wh
  let wiwsave = &wiw
  let fdmsave = &fdm

  set lazyredraw
  set ei=all
  set nosplitbelow
  set nosplitright
  set winminheight=0
  set winminwidth=0
  set winheight=1
  set winwidth=1
  set nowinfixheight
  set nowinfixwidth
  set fdm=manual

  " Scale() will modify the list, and we shouldn't modify layout in-place
  let layout = deepcopy(a:layout)

  call s:Scale(layout)
  call s:Expand(0, layout)
  call s:FixViews(layout)

  call windowlayout#SaveWindows()
  for hookname in s:usedhooks
    let dict = {}
    let dict.function = s:resthooks[hookname]
    for win in s:GetWindowsFromLayout(layout)
      exe win.winnr . "wincmd w"
      call dict.function(win)
    endfor
    unlet dict.function
  endfor
  call windowlayout#RestoreWindows()

  let &lz  = lzsave
  let &ei  = eisave
  let &sb  = sbsave
  let &spr = sprsave
  let &wmh = wmhsave
  let &wmw = wmhsave
  let &wfh = wfhsave
  let &wfw = wfwsave
  let &wh  = whsave
  let &wiw = wiwsave
  let &fdm = fdmsave
endfunction

" -- PRIVATE FUNCTIONS -- "

" Pair of functions to save and restore the previous and current window
let s:savecount = 0
let s:currwinnr = {}
let s:prevwinnr = {}

function! windowlayout#SaveWindows()
  if s:savecount == 0
    let s:currwinnr[tabpagenr()] = winnr()
    wincmd p
    let s:prevwinnr[tabpagenr()] = winnr()
    wincmd p
  endif
  let s:savecount += 1
endfunction

function! windowlayout#RestoreWindows()
  let s:savecount -= 1
  if s:savecount == 0
    exe s:prevwinnr[tabpagenr()] . 'wincmd w'
    exe s:currwinnr[tabpagenr()] . 'wincmd w'
    unlet s:prevwinnr[tabpagenr()] s:currwinnr[tabpagenr()]
  endif
endfunction

" Implementation for the DistanceFrom(Left|Top|Right|Bottom) functions
" Private so that nothing unexpected can be passed for a:directionkey
function! s:NumWindowsInDir(winnum, directionkey)
  call windowlayout#SaveWindows()

  exe a:winnum . "wincmd w"

  let i = 0

  while 1
    let num = winnr()
    exe "wincmd " . a:directionkey
    if winnr() == num
      break
    endif
    let i = i + 1
  endwhile

  call windowlayout#RestoreWindows()

  return i
endfunction

" Implementation for the Window(Above|Below|LeftOf|RightOf) functions
" Private so that nothing unexpected can be passed for a:directionkey
function! s:WindowInDir(winnum, directionkey)
  call windowlayout#SaveWindows()
  exe a:winnum . "wincmd w"
  exe "wincmd " . a:directionkey
  call windowlayout#RestoreWindows()
  return winnr()
endfunction

" Implementation for the GetLayout() function
" Private so that the user cannot pass something unexpected for a:winlines
" Finds all lines that completely bisect a region in the given direction,
" then sorts the windows by which region they fall in, then recurses on each
" region.
function! s:GetLayoutImpl(dir, winlines)
  if type(a:winlines) == type({})
    return a:winlines
  endif

  let rv = []

  let bounds = s:GetBounds(a:winlines)

  call sort(bounds.xs, "s:NumCompare")
  call sort(bounds.ys, "s:NumCompare")
  call remove(bounds.xs, 0)
  call remove(bounds.ys, 0)

  if a:dir == 1
    let major = bounds.xs
    let minor = bounds.ys
    let check = bounds.bottom - bounds.top
  else
    let major = bounds.ys
    let minor = bounds.xs
    let check = bounds.right - bounds.left
  endif

  let blocklines = []

  " Find lines that completely bisect the region
  for i in major
    " Find windows whose (bottom|right) edge lies on this (x|y)
    let matches = copy(a:winlines)
    call filter(matches, 'v:val[(a:dir == 0 ? "B" : "R")] + 1 == i')

    let sum = 0
    for match in matches
      exe "let sum += match." . (a:dir == 0 ? "w" : "h") . " + 1"
    endfor

    if sum == check
      let blocklines += [i]
    endif
  endfor

  " Find the windows in each of those blocks
  let blocks = []
  for i in range(len(blocklines))
    let blocks += [[]]
  endfor

  let blocklines = [ 0 ] + blocklines

  for win in a:winlines
    for i in range(len(blocklines) - 1)
      let bound = (a:dir == 0 ? "T" : "R")
      if win[bound] > blocklines[i] && win[bound] < blocklines[i+1]
        let blocks[i] += [win]
        break
      endif
      if i == len(blocklines) - 2
        let blocks[-1] += [win]
      endif
    endfor
  endfor

  let rv = []

  for block in blocks
    if len(block) == 1
      let rv += block
    else
      let rv += [ s:GetLayoutImpl(1-a:dir, block) ]
    endif
  endfor

  return rv
endfunction

" Returns a dictionary containing bounding information for the given windows.
" In particular, it includes:
"   "left"   column immediately before the leftmost window(s)
"   "right"  column immediately after the rightmost window(s)
"   "top"    row immediately above the topmost window(s)
"   "bottom" row immediately below the bottommost window(s)
"   "xs"     list of all borders separating two windows vertically
"   "ys"     list of all borders separating two windows horizontally
"
" NOTE: 'xs' and 'ys' must (by definition) contain an entry for each of
"       'left', 'right', 'top', and 'bottom'.
"
" NOTE: 'xs' and 'ys' contain borders not included in windows, and thus
"       specify the locations of the horizontal / vertical window separators.
function! s:GetBounds(windows)
  let rv = { "left" : &columns + 1, "right"  : 0,
           \ "top"  : &lines   + 1, "bottom" : 0,
           \ "xs"   : [],           "ys"     : [] }

  if len(a:windows) == 0
    echoerr "s:GetBounds called with empty window list!"
    return {}
  endif

  for win in a:windows
    if index(rv.xs, win.L - 1) == -1
      let rv.xs += [ win.L - 1 ]
    endif
    if index(rv.xs, win.R + 1) == -1
      let rv.xs += [ win.R + 1 ]
    endif
    if index(rv.ys, win.T - 1) == -1
      let rv.ys += [ win.T - 1 ]
    endif
    if index(rv.ys, win.B + 1) == -1
      let rv.ys += [ win.B + 1 ]
    endif
  endfor

  let rv.left   = min(rv.xs)
  let rv.right  = max(rv.xs)
  let rv.top    = min(rv.ys)
  let rv.bottom = max(rv.ys)

  return rv
endfunction

" Numerical comparator for sort function
" Default is to use a string compare.
function! s:NumCompare(i, j)
  return a:i == a:j ? 0 : a:i > a:j ? 1 : -1
endfunction

" Get the size of a given layout as a dictionary of keys `height' and `width'
" NOTE: The naive approach taken is to find the leftmost left, the topmost
"       top, the bottommost bottom, and the rightmost right, and say that the
"       enclosed area is everything between the topleft and bottomright corner
function! s:GetSize(elem)
  let rv = { 'height' : 0, 'width' : 0 }

  let bounds = s:GetBounds(s:GetWindowsFromLayout([a:elem]))

  let rv.height = bounds.bottom - bounds.top - 1
  let rv.width  = bounds.right - bounds.left - 1

  return rv
endfunction

" Given a layout, return a list of all the windows in it.
function! s:GetWindowsFromLayout(layout)
  let rv = []
  for elem in a:layout
    if type(elem) == type({})
      let rv += [ elem ]
    else
      call extend(rv, s:GetWindowsFromLayout(elem))
    endif
    unlet elem
  endfor
  return rv
endfunction

" Scale a given layout up or down to the current window size.
" NOTE: The varargs shouldn't be used by the caller, only the implementation
function! s:Scale(layout, ...)
  if a:0 == 4
    let [ oldh, newh, oldw, neww ] = a:000
  else
    let old = s:GetSize(a:layout)
    let oldw = old.width
    let neww = &columns
    let oldh = old.height
    " Windows don't take up space occupied by command-line or status-line
    let newh = &lines - &ch
    let newh -= (&laststatus == 2 || (&laststatus == 1 && len(a:layout) > 1))

    if oldh == newh && oldw == neww " Nothing to do
      return
    endif
  endif

  for win in a:layout
    if type(win) == type({})
      let win.L = (win.L - 1) * neww / oldw + 1
      if win.R == oldw
        let win.R = neww
      else
        let win.R = (win.R - 1) * neww / oldw + 1
      endif
      let win.T = (win.T - 1) * newh / oldh + 1
      if win.B == oldh
        let win.B = newh
      else
        let win.B = (win.B - 1) * newh / oldh + 1
      endif
    else
      call s:Scale(win, oldh, newh, oldw, neww)
    endif
    unlet win
  endfor
endfunction

function! s:FixViews(layout)
  redraw
  let windows = s:GetWindowsFromLayout(a:layout)
  let curr = filter(copy(windows), 'has_key(v:val, "curr")')
  let prev = filter(copy(windows), 'has_key(v:val, "prev")')

  for win in windows
    try
      exe win.winnr . "wincmd w"
      exe win.bufnr . "b"
      exe win.midline
      normal zz
      exe win.line
    catch /.*/
    endtry
  endfor

  if len(prev) == 1
    sil! exe prev[0].winnr . "wincmd w"
  endif

  if len(curr) == 1
    sil! exe curr[0].winnr . "wincmd w"
  endif
endfunction

function! s:Expand(dir, layout)
  if type(a:layout) == type({})
    return
  endif

  for i in range(len(a:layout))
    " Create a new window if we need one.
    if i != len(a:layout) - 1
      exe "wincmd " (a:dir == 0 ? "s" : "v")
    endif

    let size = s:GetSize(a:layout[i])
    exe "resize " . size.height
    exe "vert resize " . size.width

    " Expand the things inside us.
    if type(a:layout) != type({})
      call s:Expand(1-a:dir, a:layout[i])
    endif

    " Switch to the newly created window
    if i != len(a:layout) - 1
      exe "wincmd " (a:dir == 0 ? "j" : "l")
    endif
  endfor
endfunction

" Hooks system:
"
" We'll allow for hook functions to be executed as the last step of saving, or
" of restoring, a layout.  A hook function will be called once for each window
" being saved or restored.  It will be passed as an argument the WindowInfo
" dictionary for that window, and that window will be the active window in the
" tab.  No ordering is guaranteed for hook functions.  Hook functions must be
" idempotent.  This lets us get away from the complicated process of tracking
" dependencies, since if hook B relies on information provided by hook A, it
" can simply call hook A directly - no harm will be caused by A later being
" called again.

let s:savehooks = {}
let s:resthooks = {}
let s:usedhooks = []

function! windowlayout#RegisterHook(ident, savefunc, restfunc)
  if windowlayout#HookRegistered(a:ident)
    echoerr "Already have a hook named '" . a:ident . "'."
  endif
  call windowlayout#ForceRegisterHook(a:ident, a:savefunc, a:restfunc)
endfunction

function! windowlayout#ForceRegisterHook(ident, savefunc, restfunc)
  let s:savehooks[a:ident] = a:savefunc
  let s:resthooks[a:ident] = a:restfunc
endfunction

function! windowlayout#UnregisterHook(ident)
  try
    call remove(s:savehooks, a:ident)
  catch /.*/
  endtry
  try
    call remove(s:resthooks, a:ident)
  catch /.*/
  endtry
endfunction

function! windowlayout#ApplyHook(ident)
  if !windowlayout#HookRegistered(a:ident)
    echoerr "No hook registered by name '" . a:ident . "'."
  endif
  call add(s:usedhooks, a:ident)
endfunction

function! windowlayout#UnapplyHook(ident)
  let idx = index(s:usedhooks, a:ident)
  if idx != -1
    call remove(s:usedhooks, idx)
  endif
endfunction

function! windowlayout#HookRegistered(ident)
  return has_key(s:savehooks, a:ident) && has_key(s:resthooks, a:ident)
endfunction

function! windowlayout#HookApplied(ident)
  return index(s:usedhooks, a:ident) != -1
endfunction

" Handle saving and restoring of window-local options.  Otherwise, these are
" lost when the window is closed.
let s:winlocalopts = [ 'arab', 'cuc',  'cul',   'diff', 'fdc', 'fen', 'fde',
                     \ 'fdi',  'fdl',  'fmr',   'fdm',  'fml', 'fdn', 'fdt',
                     \ 'lbr',  'list', 'nu',    'nuw',  'pvw', 'rl',  'rlc',
                     \ 'scr',  'scb',  'spell', 'stl',  'wfh', 'wfw', 'wrap' ]

function! s:savewinopts(wininfo)
  let a:wininfo.winlocalopts = {}
  for opt in s:winlocalopts
    let a:wininfo.winlocalopts[opt] = eval("&l:".opt)
  endfor
endfunction

function! s:restwinopts(wininfo)
  if has_key(a:wininfo, 'winlocalopts')
    for [key, val] in items(a:wininfo.winlocalopts)
      exe "let &l:" . key . "=val"
    endfor
  endif
endfunction

call windowlayout#ForceRegisterHook("winlocalopts", function('s:savewinopts'), function('s:restwinopts'))

" Handle clearing and restoring the value of the bufhidden option.  This lets
" us hide windows that would normally delete all their contents when hidden.
function! s:SaveAndResetBH(wininfo)
  if has_key(a:wininfo, 'bufhiddenreset')
    return " Already saved
  endif
  let a:wininfo.bufhiddenreset = &l:bufhidden
  setlocal bufhidden=hide
endfunction

function! s:RestoreBH(wininfo)
  if exists("a:wininfo.bufhiddenreset")
    if &l:bufhidden == "hide"
      let &l:bufhidden = a:wininfo.bufhiddenreset
    elseif &verbose
      echomsg "Not restoring 'bufhidden' in buffer ".bufnr("")."."
      echomsg "It had been changed since we last set it."
    endif
    unlet a:wininfo.bufhiddenreset
  endif
endfunction

call windowlayout#ForceRegisterHook("bufhiddenreset", function('s:SaveAndResetBH'), function('s:RestoreBH'))

function! s:OptionsWorkaroundS(wininfo)
  if @% == "option-window"
    echomsg "Setting bufhidden to 'wipe'"
    let a:wininfo.optionsworkaround = 1
    let a:wininfo.bufhiddenreset = &l:bufhidden
    setlocal bufhidden=wipe
  endif
endfunction

function! s:OptionsWorkaroundR(wininfo)
  if has_key(a:wininfo, "optionsworkaround")
    let oldtab = tabpagenr()
    tabnew
    let newtab = tabpagenr()
    options
    only
    let bufnr = bufnr("%")
    exe oldtab."tabnext"
    let savefdm = &l:fdm
    setlocal fdm=manual
    exe bufnr."b"
    let &l:fdm = savefdm
    exe newtab."tabnext"
    hide
    exe oldtab."tabnext"
  endif
endfunction

call windowlayout#ForceRegisterHook("optionsworkaround", function('s:OptionsWorkaroundS'), function('s:OptionsWorkaroundR'))

call windowlayout#ApplyHook("winlocalopts")
call windowlayout#ApplyHook("bufhiddenreset")
call windowlayout#ApplyHook("optionsworkaround")
