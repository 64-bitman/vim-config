set background=dark
set guioptions+=d!
set guioptions-=rL
set guicursor+=a:blinkon0
set mousemodel=popup_setpos

if has('win32')
    :packadd! lsp
    set lines=40 columns=150
    set guifont=CommitMonoTTF:h10:cANSI:qDRAFT
else
    " set guifont=Fira\ Code
    set guifont=CommitMono
endif
