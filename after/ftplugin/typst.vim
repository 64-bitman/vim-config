vim9script

if executable("typst") != 1
    finish
endif

import autoload "dist/vim9.vim" as v9

command! -buffer -nargs=0 TypstSave job_start(["typst", "compile", expand("%:p")])
command! -buffer -nargs=0 TypstOpen v9.Open("http://127.0.0.1:23625")
