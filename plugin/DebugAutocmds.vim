if exists("g:debugautocmds_loaded")
  finish
endif

let g:debugautocmds_loaded = 1

function DebugAutocmdsOn()
  augroup DebugAutocmds
    au!
    au BufNewFile           * echomsg "Type: BufNewFile           File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufReadPre           * echomsg "Type: BufReadPre           File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufReadPost          * echomsg "Type: BufReadPost          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
   "au BufReadCmd           * echomsg "Type: BufReadCmd           File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FileReadPre          * echomsg "Type: FileReadPre          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FileReadPost         * echomsg "Type: FileReadPost         File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
   "au FileReadCmd          * echomsg "Type: FileReadCmd          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FilterReadPre        * echomsg "Type: FilterReadPre        File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FilterReadPost       * echomsg "Type: FilterReadPost       File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au StdinReadPre         * echomsg "Type: StdinReadPre         File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au StdinReadPost        * echomsg "Type: StdinReadPost        File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufWritePre          * echomsg "Type: BufWritePre          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufWritePost         * echomsg "Type: BufWritePost         File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
   "au BufWriteCmd          * echomsg "Type: BufWriteCmd          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FileWritePre         * echomsg "Type: FileWritePre         File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FileWritePost        * echomsg "Type: FileWritePost        File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
   "au FileWriteCmd         * echomsg "Type: FileWriteCmd         File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FileAppendPre        * echomsg "Type: FileAppendPre        File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FileAppendPost       * echomsg "Type: FileAppendPost       File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
   "au FileAppendCmd        * echomsg "Type: FileAppendCmd        File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FilterWritePre       * echomsg "Type: FilterWritePre       File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FilterWritePost      * echomsg "Type: FilterWritePost      File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufAdd               * echomsg "Type: BufAdd               File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufDelete            * echomsg "Type: BufDelete            File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufWipeout           * echomsg "Type: BufWipeout           File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufFilePre           * echomsg "Type: BufFilePre           File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufFilePost          * echomsg "Type: BufFilePost          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufEnter             * echomsg "Type: BufEnter             File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufLeave             * echomsg "Type: BufLeave             File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufWinEnter          * echomsg "Type: BufWinEnter          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufWinLeave          * echomsg "Type: BufWinLeave          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufUnload            * echomsg "Type: BufUnload            File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufHidden            * echomsg "Type: BufHidden            File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au BufNew               * echomsg "Type: BufNew               File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au SwapExists           * echomsg "Type: SwapExists           File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FileType             * echomsg "Type: FileType             File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au Syntax               * echomsg "Type: Syntax               File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au EncodingChanged      * echomsg "Type: EncodingChanged      File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au TermChanged          * echomsg "Type: TermChanged          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au VimEnter             * echomsg "Type: VimEnter             File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au GUIEnter             * echomsg "Type: GUIEnter             File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au TermResponse         * echomsg "Type: TermResponse         File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au VimLeavePre          * echomsg "Type: VimLeavePre          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au VimLeave             * echomsg "Type: VimLeave             File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FileChangedShell     * echomsg "Type: FileChangedShell     File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FileChangedShellPost * echomsg "Type: FileChangedShellPost File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FileChangedRO        * echomsg "Type: FileChangedRO        File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au ShellCmdPost         * echomsg "Type: ShellCmdPost         File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au ShellFilterPost      * echomsg "Type: ShellFilterPost      File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FuncUndefined        * echomsg "Type: FuncUndefined        File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au SpellFileMissing     * echomsg "Type: SpellFileMissing     File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au SourcePre            * echomsg "Type: SourcePre            File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
   "au SourceCmd            * echomsg "Type: SourceCmd            File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au VimResized           * echomsg "Type: VimResized           File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FocusGained          * echomsg "Type: FocusGained          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au FocusLost            * echomsg "Type: FocusLost            File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au CursorHold           * echomsg "Type: CursorHold           File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au CursorHoldI          * echomsg "Type: CursorHoldI          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au CursorMoved          * echomsg "Type: CursorMoved          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au CursorMovedI         * echomsg "Type: CursorMovedI         File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au WinEnter             * echomsg "Type: WinEnter             File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au WinLeave             * echomsg "Type: WinLeave             File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au TabEnter             * echomsg "Type: TabEnter             File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au TabLeave             * echomsg "Type: TabLeave             File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au CmdwinEnter          * echomsg "Type: CmdwinEnter          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au CmdwinLeave          * echomsg "Type: CmdwinLeave          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au InsertEnter          * echomsg "Type: InsertEnter          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au InsertChange         * echomsg "Type: InsertChange         File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au InsertLeave          * echomsg "Type: InsertLeave          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au ColorScheme          * echomsg "Type: ColorScheme          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au RemoteReply          * echomsg "Type: RemoteReply          File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au QuickFixCmdPre       * echomsg "Type: QuickFixCmdPre       File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au QuickFixCmdPost      * echomsg "Type: QuickFixCmdPost      File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au SessionLoadPost      * echomsg "Type: SessionLoadPost      File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au MenuPopup            * echomsg "Type: MenuPopup            File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
    au User                 * echomsg "Type: User                 File: '" . expand('<afile>') . "'  Buf: '" . expand('<abuf>') . "'  Match: '" . expand('<amatch>') . "'"
  augroup END
endfunction

function DebugAutocmdsOff()
  augroup DebugAutocmds
    au!
  augroup END
endfunction

function DebugAutocmdsToggle()
  if exists("s:state") && s:state == 'on'
    call DebugAutocmdsOff
  else
    call DebugAutocmdsOn
  endif
endfunction

command -bar DebugAutocmdsOn     call DebugAutocmdsOn()
command -bar DebugAutocmdsOff    call DebugAutocmdsOff()
command -bar DebugAutocmdsToggle call DebugAutocmdsToggle()
