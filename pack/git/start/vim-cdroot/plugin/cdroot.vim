vim9script

import autoload 'cdroot.vim'

if exists("g:loaded_cdroot_plugin")
    finish
endif

g:loaded_cdroot_plugin = 1

if !exists("g:cdroot_markers")
    g:cdroot_markers = ['.projectroot', '.git', '.hg', '.bzr', '.svn', '.projectroot_git']
endif

if !exists("g:cdroot_cd_once")
    g:cdroot_cd_once = 0
endif

augroup cdroot
    autocmd!
    autocmd VimEnter,BufEnter * {
        cdroot.ChangeRoot()
        doautocmd User CdRootChange
    }
augroup END
