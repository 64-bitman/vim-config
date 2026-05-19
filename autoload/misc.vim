vim9script

export def LogError(msg: string): void
    echohl ErrorMsg
    echom msg
    echohl None
enddef

export def TrimWhitespace(): void
    var saved_view: dict<number> = winsaveview()
    :keepjumps exe ":%s/\\s\\+$//ge"
    winrestview(saved_view)
enddef

export def DiffOrig(): void
    var prev_file: number = bufnr()
    var prev_syn: string = &syntax
    :vertical new
    var scratch_buf: number = bufnr()
    set bt=nofile
    &syntax = prev_syn
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

export def SynStack(): void
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
enddef

# Taken from habamax
# toggle colorcolumn at cursor position
# set vartabstop accordingly
export def ToggleCC(all: bool = false)
    if all
        b:cc = &cc ?? get(b:, "cc", "80")
        &cc = empty(&cc) ? b:cc : ""
    else
        var col = virtcol('.')
        var cc = split(&cc, ",")->map((_, v) => str2nr(v))
        if index(cc, col) == -1
            exe "set cc=" .. cc->add(col)->sort('f')->map((_, v) => printf("%s", v))->join(',')
        else
            exe $"set cc-={col}"
        endif
    endif
    var cc = split(&cc, ",")->map((_, v) => str2nr(v))
    if len(cc) > 1 || len(cc) == 1 && cc[0] < 60
        setl vsts&
        var shift = 1
        for v in cc
            if v == 1 | continue | endif
            exe $"set vsts+={v - shift}"
            shift = v
        endfor
        exe $"setl vsts+={&sw}"
    else
        setl vsts&
    endif
enddef
