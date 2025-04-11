vim9script

export def FindRoot(markers: list<string>): tuple<string, string>
    var path: string = fnamemodify(expand('%'), ':p')

    if path[0] != '/'
        return ('', '')
    endif

    while true
        path = fnamemodify(path, ':h')

        # stop if in home dir ('~')
        # stop if in root dir ('/')
        if path == expand('$HOME') || path == '/'
            return ('', fnamemodify(expand('%'), ':p:h'))
        endif

        for marker in markers
            var fn: string = path .. '/' .. marker
            if filereadable(fn) || isdirectory(fn)
                return (marker, path)
            endif
        endfor
    endwhile
    return ('', '')
enddef

export def ChangeRoot(): void
    if !exists('b:root_dir')
        var root_dir_info: tuple<string, string> = FindRoot(g:cdroot_markers)

        b:root_dir = root_dir_info[1]
        b:root_marker = root_dir_info[0]
    elseif g:cdroot_cd_once
        return
    endif

    try
        if strlen(b:root_dir) > 0 && b:root_dir !=# getcwd()
            execute(':lcd ' .. fnameescape(b:root_dir))
        endif
    catch
    endtry
enddef
