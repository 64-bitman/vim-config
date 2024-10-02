vim9script

if exists("b:c_did_ftplugin")
  finish
endif
b:c_did_ftplugin = 1

setlocal matchpairs+==:;
