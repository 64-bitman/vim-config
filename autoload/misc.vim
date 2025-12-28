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
