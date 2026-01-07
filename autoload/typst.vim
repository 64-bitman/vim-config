vim9script

import autoload "./misc.vim" as misc

var typst_job: job
var quiet: bool = false
var file_is_temp: bool = false
var file: string
var restart: bool = false

def WatchErrCallback(channel: channel, msg: string): void
    var errors: list<dict<any>> = []
    var lines: list<string> = msg->split("\n")

    for line: string in lines
        var match: list<string> =
            matchlist(line, '\v^([^:]+):(\d+):(\d+):\s*(.+)$')

        if len(match) == 0
            continue
        endif

        errors += [{
            filename: match[1],
            lnum: match[2],
            col: match[3],
            text: match[4]
        }]
    endfor

    if len(errors) > 0
        setqflist(errors)
        misc.LogError("'typst' program had an error")
    endif
enddef

export def Cleanup(): void
    if file != null_string && file_is_temp
        delete(file)
    endif
enddef

def WatchExitCallback(job: job, exit: number): void
    if restart
        quiet = false
        Watch(file)
        restart = false
        return
    else
        echom $"'typst' program exited with exit code {exit}"
    endif

    Cleanup()
    typst_job = null_job
    file = null_string
enddef

def GetTempDir(): string
    var tempdir: string = getenv("XDG_RUNTIME_DIR")

    if tempdir == null_string
        tempdir = $"/run/user/{expand("$UID")}"
    endif

    if !isdirectory(tempdir)
        misc.LogError($"No temporary directory: {tempdir}")
        return null_string
    endif

    tempdir ..= "/vim-typst"

    if !isdirectory(tempdir)
        mkdir(tempdir)
    endif

    return tempdir
enddef

export def Watch(...args: list<string>): void
    if &buftype != ""
        misc.LogError("Current buffer is not a regular file")
        return
    endif

    if typst_job != null_job && !restart
        misc.LogError("'typst' program is already running")
        return
    endif

    var out_file: string = file_is_temp ? null_string : file
    var temp: bool = !filereadable($"{expand("%:p:r")}.pdf")
    var open: bool = false

    for arg: string in args
        if arg =~ "--temp"
            temp = true
        elseif arg =~ "--no-temp"
            temp = false
        elseif arg =~ "--open"
            open = true
        else
            out_file = arg
        endif
    endfor

    if out_file == null_string
        if temp && has("unix")
            var tempdir: string = GetTempDir()
            
            if tempdir == null_string
                return
            endif

            var out: string = expand("%:p:r") .. ".pdf"

            out_file = $"{tempdir}/{substitute(out, "/", "%", "g")}"
        else
            out_file = expand("%:p:r") .. ".pdf"
        endif
    endif

    var cmd: list<string> = [
        "typst",
        "watch",
        "--no-serve",
        expand("%:p"),
        out_file
    ]

    if open
        cmd += ["--open"]
    endif
    
    typst_job = job_start(cmd, {
        err_mode: "raw",
        err_cb: WatchErrCallback,
        exit_cb: WatchExitCallback
    })

    if job_status(typst_job) == "fail"
        typst_job = null_job
        misc.LogError("Failed to launch 'typst' program")
        return
    endif

    file_is_temp = temp
    file = out_file
enddef

export def StopWatch()
    if typst_job == null_job
        misc.LogError("'typst' program not running")
        return
    endif
    job_stop(typst_job)
enddef

export def Save(...args: list<string>): void
    var tempdir: string = GetTempDir()

    if tempdir == null_string
        return
    endif

    var target: string = expand("%:p:r") .. ".pdf"
    var loc: string = len(args) > 0 ? args[0] : expand("%:p:r") .. ".pdf"
    var out: string = expand("%:p:r") .. ".pdf"

    target = $"{tempdir}/{substitute(out, "/", "%", "g")}"

    if !filereadable(target)
        job_start(["typst", "compile", expand("%:p"), loc])
        file_is_temp = false
        file = loc
        return
    endif

    if rename(target, loc) != 0
        misc.LogError($"Failed renaming {target} to {loc}")
        return
    endif

    restart = true
    file = loc
    StopWatch()
enddef

export def Open(...args: list<string>)
    var target: string = file

    if target == null_string
        target = len(args) > 0 ? args[0] : expand("%:p:r") .. ".pdf"

        if !filereadable(target)
            target = null_string
        endif
    endif

    if target == null_string
        misc.LogError("File does not exist")
        return
    endif

    job_start(["xdg-open", target])
enddef
