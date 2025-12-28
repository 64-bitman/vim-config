vim9script

if executable("typst") != 1
    finish
endif

import autoload "../../autoload/typst.vim" as typst
import autoload "../../autoload/lsp.vim" as lsp

command! -buffer -nargs=* TypstWatch typst.Watch(<f-args>)
command! -buffer -nargs=0 TypstWatchStop typst.StopWatch()
command! -buffer -nargs=0 TypstSave typst.Save()
command! -buffer -nargs=0 TypstOpen typst.Open(<f-args>)

augroup CustomTypst
    autocmd!
    autocmd VimLeave * typst.Cleanup()
augroup END

lsp.Load()
