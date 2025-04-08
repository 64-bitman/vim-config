if exists("g:loaded_cdroot_plugin") || &cpo
    finish
endif

let g:loaded_cdroot_plugin = 1
let s:keepcpo=&cpo
set cpo&vim

if !exists("g:cdroot_markers")
    let g:cdroot_markers = ['.projectroot', '.git', '.hg', '.bzr', '.svn', '.projectroot_git']
endif

if !exists("g:cdroot_cd_once")
    let g:cdroot_cd_once = 0
endif

augroup cdroot
    autocmd!
    autocmd VimEnter,BufEnter * call cdroot#change_root() | doautocmd User CdRootChange
augroup END

let &cpo=s:keepcpo
unlet s:keepcpo
