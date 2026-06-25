vim9script

var cur_buf: number = -1
var cur_win: number = -1
var cur_title: string = ""
var notif_win: number = -1
var notif_spinner: number = 0

const spinner_chars: list<string> = [
    "-", "\\", "|", "/"
]

def CreateSpinner(): string
    const str: string = $"'{cur_title}'  {spinner_chars[notif_spinner]}  "

    notif_spinner += 1
    if notif_spinner >= len(spinner_chars)
        notif_spinner = 0
    endif
    return str
enddef

def CreateProgress(): void
    notif_spinner = 0
    notif_win = popup_create(CreateSpinner(), {
        line: 1,
        zindex: 999999,
        resize: false,
        drag: false,
        border: [1, 1, 1, 1],
        borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
    })
enddef

def CloseProgress(): void
    if notif_win != -1
        popup_close(notif_win)
        notif_win = -1
    endif
enddef

export def DoMake(bang: bool, args: string): void
    if bang || (cur_buf != -1 && term_getstatus(cur_buf) == "running")
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
        term_finish: "noclose",
        norestore: true,
        hidden: true,
        callback: (_, _) => {
            if notif_win != -1
                popup_settext(notif_win, CreateSpinner())
            endif
        }
    })
    cur_buf = buf

    setbufvar(buf, "&bufhidden", "hide")
    setbufvar(buf, "&number", false)
    setbufvar(buf, "&relativenumber", false)

    OpenMake()

    var job: job = term_getjob(buf)

    job_setoptions(job, {
        exit_cb: (_, _) => {
            term_wait(buf)
            CloseProgress()

            execute($"cgetbuffer {buf}")
            setqflist([], 'r', {title: cur_title})
        }
    })
enddef

def OpenMake(): void
    if cur_win != -1 || cur_buf == -1
        return
    endif

    CloseProgress()

    var width: number = float2nr(&columns * 0.90)
    var height: number = float2nr((&lines - 2) * 0.85) - 2

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
        borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        callback: (_, _) => {
            cur_win = -1
            if term_getstatus(cur_buf) == "running"
                CreateProgress()
            endif
        }
    })

    win_execute(cur_win, "setlocal fillchars+=eob:\\ ")
    execute($"nnoremap <nowait> <buffer> q <cmd>call popup_close({cur_win})<cr>")
    execute($"tnoremap <nowait> <buffer> <C-q> <cmd>call popup_close({cur_win})<cr>")
    nnoremap <nowait> <buffer> <C-q> q
enddef

# Taken from habamax
export def MakeComplete(_, _, _): string
    if has("win32")
        return ""
    endif
    return system("make -npq : 2> /dev/null | awk -v RS= -F: '$1 ~ /^[^#%.]+$/ { print $1 }' | sort -u")
enddef
