vim9script

var cur_buf = -1

export def DoMake(bang: bool, args: string): void
    if cur_buf != -1
        execute($":bw! {cur_buf}")
    endif

    var cmd: string = expandcmd(&makeprg) .. " " .. args
    var title: string = ":make" .. (bang ? "!" : "") .. " " .. args

    write
    tabnew

    var buf: number = term_start(cmd, {
        term_name: title,
        hidden: bang,
        term_finish: "open",
        curwin: true,
        norestore: true
    })
    cur_buf = buf
    execute($"autocmd BufDelete <buffer={buf}> ++once cur_buf = -1")

    setlocal nonumber norelativenumber fillchars+=eob:\  winhighlight+=!(:Terminal

    var job: job = term_getjob(buf)

    job_setoptions(job, {
        exit_cb: (_, code: number) => {
            term_wait(buf)

            execute($"cgetbuffer {buf}")
            setqflist([], 'r', {title: title})

            var cur: number = bufnr('%')

            execute('buffer ' .. buf)
            nnoremap <nowait> <buffer> q <cmd>quit!<cr>
            nnoremap <nowait> <buffer> <C-q> q
            execute('buffer ' .. cur)
        }
    })
enddef

# Taken from habamax
export def MakeComplete(_, _, _): string
    if has("win32")
        return ""
    endif
    return system("make -npq : 2> /dev/null | awk -v RS= -F: '$1 ~ /^[^#%.]+$/ { print $1 }' | sort -u")
enddef
