vim9script

if exists("b:md_did_ftplugin")
    :unlet b:md_did_ftplugin
    finish
endif
b:md_did_ftplugin = 1

setlocal spell
setlocal nonumber
setlocal norelativenumber
setlocal nomodeline
setlocal textwidth=80

setlocal concealcursor= conceallevel=3

g:vim_markdown_no_default_key_mappings = 1
g:vim_markdown_toc_autofit = 1
g:vim_markdown_strikethrough = 1
g:vim_markdown_autowrite = 1

packadd vim-markdown
doautocmd <nomodeline> Filetype markdown
