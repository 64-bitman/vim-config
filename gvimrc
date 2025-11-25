set background=dark
set guioptions+=d

if has('windows')
    :packadd! lsp
    set guioptions-=rL
    set guicursor+=a:blinkon0
    set lines=40 columns=150
endif
