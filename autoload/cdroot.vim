function! cdroot#find_root(markers)
    let l:path = fnamemodify(expand('%'), ':p')

    if l:path[0] != '/'
        return ''
    endif

    while 1
        let l:path = fnamemodify(l:path, ':h')

        " stop if in home dir ('~')
        " stop if in root dir ('/')
        if l:path == expand('$HOME') || l:path == '/'
            return fnamemodify(expand('%'), ':p:h')
        endif

        for marker in a:markers
            let l:fn = l:path . '/' . marker
            if filereadable(fn) || isdirectory(fn)
                return (marker, l:path)
            endif
        endfor
    endwhile
endfunction

function! cdroot#change_root()
    if !exists('b:root_dir')
        let l:root_dir_info = cdroot#find_root(g:cdroot_markers)

        let b:root_dir = l:root_dir_info[1]
        let b:root_marker = l:root_dir_info[0]
    elseif g:cdroot_cd_once
        return ''
    endif

    try
        if strlen(b:root_dir) && b:root_dir !=# getcwd()
            execute ':cd' fnameescape(b:root_dir)
        endif
    catch
    endtry
endfunction
