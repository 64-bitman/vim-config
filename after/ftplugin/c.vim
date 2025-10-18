vim9script

g:c_no_curly_error = 1 # disable error highlight for c compound literals
g:c_no_bracket_error = 1
g:c_gnu = 1
highlight link cParenError NONE

setlocal matchpairs+==:;
