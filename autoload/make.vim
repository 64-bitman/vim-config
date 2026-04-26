vim9script

var cur_buf: number = -1
var cur_win: number = -1
var cur_title: string = ""

augroup CustomMake
    au!
    au WinClosed * {
        if cur_win == str2nr(expand("<afile>"))
            cur_win = -1
        endif
    }
augroup END

export def DoMake(bang: bool, args: string): void
    if bang
        OpenMake()
        return
    endif
    if cur_win != -1
        popup_close(cur_win)
    endif
    if cur_buf != -1
        execute($":bw! {cur_buf}")
    endif

    if &autowrite
        wall
    endif

    var cmd: string = $"{expandcmd(&makeprg)} {args}"

    cur_title = $":make {args}"

    var buf: number = term_start(cmd, {
        term_name: cur_title,
        term_finish: "open",
        norestore: true,
        hidden: true
    })
    cur_buf = buf

    setbufvar(buf, "&number", false)
    setbufvar(buf, "&relativenumber", false)

    OpenMake()

    var job: job = term_getjob(buf)

    job_setoptions(job, {
        exit_cb: (_, code: number) => {
            term_wait(buf)

            execute($"cgetbuffer {buf}")
            setqflist([], 'r', {title: cur_title})
        }
    })
enddef

def OpenMake(): void
    if cur_win != -1 || cur_buf == -1
        return
    endif

    var width: number = float2nr(&columns * 0.90)
    var height: number = float2nr(&lines * 0.85)

    cur_win = popup_create(cur_buf, {
        pos: "center",
        title: cur_title,
        zindex: 32000,
        resize: false,
        drag: false,
        wrap: true,
        border: [1, 1, 1, 1],
        minwidth: width,
        minheight: height,
        maxwidth: width,
        maxheight: height,
        highlight: "Terminal",
        callback: (winid, _) => {
            cur_win = -1
        }
    })

    win_execute(cur_win, "setlocal fillchars+=eob:\\ ")
    execute($"nnoremap <nowait> <buffer> q <cmd>call popup_close({cur_win})<cr>")
    nnoremap <nowait> <buffer> <C-q> q
enddef

# Taken from habamax
export def MakeComplete(_, _, _): string
    if has("win32")
        return ""
    endif
    return system("make -npq : 2> /dev/null | awk -v RS= -F: '$1 ~ /^[^#%.]+$/ { print $1 }' | sort -u")
enddef
