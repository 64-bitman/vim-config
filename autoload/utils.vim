vim9script

export def DiffOrig()
    var prev_file = bufnr()
    :vertical new
    var scratch_buf = bufnr()
    set bt=nofile
    :execute 'read ++edit ' .. bufname(prev_file)
    deletebufline(scratch_buf, 1)
    :diffthis
    :wincmd p
    :diffthis
    g:__diffoff_buf = scratch_buf

    command DiffOff {
        execute 'bdelete ' .. g:__diffoff_buf
        unlet g:__diffoff_buf
        delc DiffOff
    }
enddef

export def GetSysClipboard()
    if v:event.regname ==? "-"
        job_start(['sh', '-c', "echo " .. shellescape(@-) .. " | xclip -i -rmlastnl -selection clipboard "])
    endif
enddef
