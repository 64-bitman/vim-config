vim9script

import autoload "../../autoload/lsp.vim" as lsp

&makeprg = "cargo --color=always $*"
:compiler cargo

lsp.Load()
