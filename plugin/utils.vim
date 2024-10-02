vim9script

if exists("g:loaded_utils")
    finish
endif
g:loaded_utils = true

import autoload 'utils.vim'

command! DiffOrig utils.DiffOrig()

command -nargs=* -complete=file Make make! <args>

augroup Utils
    au VimResume * :silent! checktime
    au VimResized * :wincmd =
    au VimLeavePre * {
        if v:this_session != ""
            execute ':mksession! ' .. v:this_session
        endif
    }
    au TextYankPost * utils.GetSysClipboard()
augroup END

