vim9script

var notif_win: number = -1
var notif_timer: number = -1

def LspProgress(): string
    var progress: dict<any> = get(g:, "LspProgress", {})

    if empty(progress)
        return ""
    endif

    var res: list<string> = []

    for info in values(progress)
        var p: string = "0%"

        if info.percentage >= 0
            p = string(info.percentage) .. "%"
        endif

        var str: list<string> =<< trim eval END
        LSP: {info.serverName}
        {info.title} {info.message} completed {p}
        END

        res->add(str->join(" "))
    endfor

    return res->join(", ")
enddef

export def ProgressUpdate(): void
    const str: string = LspProgress()

    if str == ""
        popup_close(notif_win)
        notif_win = -1
        return
    endif

    if notif_win == -1
        notif_win = popup_create("", {
            line: 1,
            zindex: 999999,
            resize: false,
            drag: false,
            close: "click",
            border: [1, 1, 1, 1],
            borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        })
    endif

    if notif_timer != -1
        timer_stop(notif_timer)
    endif
    notif_timer = timer_start(500, (_) => {
            if notif_win != -1
                popup_close(notif_win)
                notif_win = -1
            endif
            notif_timer = -1
        }, {})

    if str != ""
        popup_settext(notif_win, str)
    endif
enddef

