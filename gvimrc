set background=dark
set guioptions+=d

if has('win32')
    :packadd! lsp
    set guioptions-=rL
    set guicursor+=a:blinkon0
    set lines=40 columns=150
    set guifont=CommitMonoTTF:h10:cANSI:qDRAFT
else
    set guifont=CommitMono
endif
