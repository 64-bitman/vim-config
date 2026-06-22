set background=dark
set guioptions+=d!k
set guioptions-=rL
set renderoptions=type:directx
set guicursor=n-v-c:block-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci-sm:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,a:blinkon0
set mousemodel=popup_setpos

if has('win32')
    :packadd! lsp
    set lines=40 columns=150
    set guifont=CommitMonoTTF:h10:cANSI:qDRAFT
else
    " set guifont=Fira\ Code
    set guifont=CommitMono
endif
