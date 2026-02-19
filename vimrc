vim9script

:packadd! comment
# :packadd! editorconfig
:packadd! hlyank
:packadd! helptoc
:packadd! justify
:packadd! cfilter
:packadd! matchit
:packadd! vim-fugitive
:packadd osc52
:runtime ftplugin/man.vim

silent! :helptags ALL

set termguicolors
set clipmethod+=osc52

if &term == "xterm-kitty"
    runtime kitty.vim
else
    &t_SI = "\<Esc>[6 q"
    &t_SR = "\<Esc>[4 q"
    &t_EI = "\<Esc>[2 q"
endif

filetype plugin indent on
syntax on
g:mapleader = " "
g:maplocalleader = "\\"

augroup ColorschemeCustom
    au!
    au Colorscheme * {
        highlight link Normal NonText

        # gruvbox for terminal
        g:terminal_ansi_colors = [
                    '#282828', '#CC241D', '#98971A', '#D79921',
                    '#458588', '#B16286', '#689D6A', '#D65D0E',
                    '#fb4934', '#b8bb26', '#fabd2f', '#83a598',
                    '#d3869b', '#8ec07c', '#fe8019', '#FBF1C7' ]

        highlight Terminal guibg=#282828 guifg=#ebdbb2

        hi Pmenu ctermbg=233 guibg=#171717
        hi! link PmenuSbar Pmenu
        hi! link PmenuExtra Pmenu
        hi PmenuKind ctermbg=233 guibg=#171717
        hi PmenuMatch ctermbg=233 guibg=#171717
        hi PmenuSel ctermbg=237 guibg=#212121 ctermfg=109 guifg=#83a598
        hi PmenuKindSel ctermbg=237 guibg=#212121
        hi PmenuMatchSel ctermbg=237 guibg=#212121
        hi! link PmenuExtraSel PmenuSel

        highlight ConflictMarkerOurs guibg=#2e5049
        highlight ConflictMarkerTheirs guibg=#344f69
        highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
    }
augroup END
:colorscheme retrobox

nnoremap <leader>p <C-^>
nnoremap <leader>bn <cmd>bn<cr>
nnoremap <leader>bp <cmd>bp<cr>
nnoremap <leader>o o<esc>
nnoremap <leader>O O<esc>
nnoremap <leader>m <cmd>FuzzyBuffer<CR>
nnoremap <leader>fa <cmd>FuzzyFilesRoot<CR>
nnoremap <S-Tab> <C-o>
noremap <C-j> <C-d>
noremap <C-k> <C-u>
noremap j gj
noremap k gk
noremap gj j
noremap gk k
tnoremap <A-n> <C-\><C-n>
for i in range(1, 9)
    execute "nnoremap <C-w>" .. i .. " <cmd>silent! tabn " .. i .. "<CR>"
    execute "tnoremap <C-w>" .. i .. " <cmd>silent! tabn " .. i .. "<CR>"
endfor
noremap <leader>q <cmd>stop<cr>
noremap <leader>e <cmd>wqa<cr>
noremap <leader>h <cmd>HelpToc<cr>
noremap <leader>r <cmd>registers<cr>
noremap <leader>jh <cmd>jumps<cr>
noremap <leader>jt <cmd>tags<cr>
noremap <leader>jm <cmd>marks<cr>
noremap <leader>jj :tag<Space>
noremap <leader>ww <cmd>w<cr>
noremap <leader>wa <cmd>wa<cr>
noremap <leader>co <cmd>bot copen<cr>
noremap <leader>cw <cmd>bot cwindow<cr>
noremap <leader>cc <cmd>cclose<cr>
noremap <leader>cl <cmd>cc<cr>
noremap <leader>cn <cmd>cnext<cr>
noremap <leader>cp <cmd>cprev<cr>
noremap <leader>ca <cmd>cabove<cr>
noremap <leader>cb <cmd>cbelow<cr>
noremap <leader>lo <cmd>lopen<cr>
noremap <leader>lw <cmd>lwindow<cr>
noremap <leader>lc <cmd>lclose<cr>
noremap <leader>ll <cmd>ll<cr>
noremap <leader>ln <cmd>lnext<cr>
noremap <leader>lp <cmd>lprev<cr>
noremap <leader>la <cmd>labove<cr>
noremap <leader>lb <cmd>lbelow<cr>
noremap <leader>le <cmd>lnewer<cr>
noremap <leader>lo <cmd>lolder<cr>
noremap <leader>v <cmd>silent! loadview<cr>
vnoremap <leader>gr "hy:%s/<C-r>h//gc<left><left><left>
nnoremap <leader>tt <cmd>call <SID>AddTermdebug()<cr><cmd>Termdebug<cr>
nnoremap <leader>ls <cmd>doautocmd User LspAttached<cr>
nnoremap <leader>be <cmd>syntax on<cr>
nnoremap <leader>bd <cmd>syntax off<cr>
nnoremap <leader>uu <cmd>UndotreeToggle<CR><cmd>UndotreeFocus<cr>
nnoremap <leader>uf <cmd>UndotreeFocus<CR>

set laststatus=2 number relativenumber ruler cursorline showcmd mouse=a ttymouse=sgr title background=dark
set wildmenu completeopt=menuone,preview,popup wildignorecase wildoptions=pum pumheight=25 keywordprg=:Man
set expandtab tabstop=4 softtabstop=4 shiftwidth=4 shiftround smarttab smartindent autoindent
set nohlsearch incsearch ignorecase smartcase nojoinspaces virtualedit=block
set lazyredraw signcolumn=number omnifunc=syntaxcomplete#Complete
set linebreak scrolloff=10 wrap nostartofline cpoptions+=n nofoldenable foldlevelstart=99 foldmethod=indent showbreak=>>>\
set autoread autowrite backspace=indent,eol,start textwidth=80
set backupcopy=auto backup writebackup undofile
set nohidden history=1000 sessionoptions-=options sessionoptions-=folds viewoptions-=cursor
set diffopt-=inline:simple diffopt+=vertical,inline:char
set encoding=utf8 ffs=unix,dos,mac termwinscroll=100000
set showmatch matchtime=1 matchpairs+=<:> ttimeoutlen=0 wrapmargin=15 shortmess-=S
set spelllang=en_ca,en_us,en_gb spelloptions=camel spellsuggest=best,20 dictionary+=/usr/share/dict/words complete+=k
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case grepformat+=%f:%l:%c:%m

if has("win32")
    set shell=pwsh
    set ffs=dos,unix,mac
    set viminfofile=~/vimfiles/viminfo
    set undodir=~/vimfiles/undo
    set backupdir^=~/vimfiles/backup
    set directory^=~/vimfiles/swap
    set belloff=all
endif

g:termdebug_config = {
    evaluate_in_popup: true,
    wide: 163,
    variables_window: true,
    variables_window_height: 15
}
g:vim_json_warnings = false
g:helptoc = {'shell_prompt': '^\[\w\+@\w\+\s.\+\]\d*\$\s.*$'}
g:saveroot_nomatch = "current"
g:EditorConfig_max_line_indicator = "none"
g:vim_markdown_math = true

g:fuzzbox_keymaps = {
    'menu_up': ["\<C-k>", "\<C-p>", "\<Up>"],
    'menu_down': ["\<C-j>", "\<C-n>", "\<Down>"],
}
g:fuzzbox_preview = false
g:fuzzbox_scrollbar = true

augroup Custom
    au!
    au FileType * {
        setlocal formatoptions+=cqjno
        if &makeprg == "make"
            setlocal makeprg=bear\ --\ make\ -j12
        endif
    }
    au BufEnter,TerminalWinOpen * {
        if &buftype == "terminal"
            setlocal wincolor=Terminal nonumber norelativenumber fillchars+=eob:\ 
        endif
    }
    au BufRead,BufNewFile *.h setlocal filetype=c
    au FileType qf,fugitive Use_q_AsExit()
    au CmdWinEnter * Use_q_AsExit()
    au BufReadPost * {
        var line: number = line("'\"")
        if !exists("g:SessionLoad") && line >= 1 && line <= line("$") && &filetype !~# 'commit'
                && index(['xxd', 'gitrebase'], &filetype) == -1
            :execute "normal! g`\""
        endif
    }
    au VimResume * :silent! checktime
    au VimResized * {
        :wincmd =
    }
    au VimLeavePre * {
        if v:this_session != ""
            execute ':mksession! ' .. v:this_session
        endif
    }
    au BufWinLeave ?* :silent! mkview!
    au User TermdebugStartPre {
        var nr: number = bufnr("%")
        var save_cursor: list<number> = getcurpos()
        g:termdebug_lasttab = tabpagenr()

        :tabnew
        execute ":buffer " .. nr
        setpos('.', save_cursor)
    }
    au User TermdebugStartPost {
        :Source
        noremap <leader>tb <cmd>Break<cr>
        noremap <leader>tr <cmd>Clear<cr>
        noremap <leader>ts <cmd>Step<cr>
        noremap <leader>tn <cmd>Over<cr>
        noremap <leader>to <cmd>Finish<cr>
    }
    au User TermdebugStopPost {
        :tabclose
        if exists("g:termdebug_lasttab")
            execute("tabn " .. g:termdebug_lasttab)
        endif

        unmap <leader>tb
        unmap <leader>tr
        unmap <leader>ts
        unmap <leader>tn
        unmap <leader>to
    }
    au FocusLost * {
        if expand("%:p") != ""
            :silent! checktime
            :silent! wa
        endif
    }
    au WinClosed * {
        wincmd p
    }
    au User FuzzboxOpened {
        execute("write " .. fnameescape(bufname(bufnr("%"))), "silent!")
    }
    autocmd CmdlineEnter [\/\?:] set hlsearch
    autocmd CmdlineLeave [\/\?:] set nohlsearch
augroup END

import autoload "./autoload/misc.vim" as misc

command! DiffOrig misc.DiffOrig()
command! SynStack misc.SynStack()
command! TrimWhitespace misc.TrimWhitespace()
command -nargs=* -complete=file Make make! <args>

def Use_q_AsExit(): void
    nnoremap <nowait> <buffer> q <cmd>q<cr>
    nnoremap <nowait> <buffer> <C-q> q
enddef

def AddTermdebug(): void
    if !get(g:, "termdebug_loaded")
        packadd termdebug
    endif
enddef

def GetCwd(): string
    var cwd: string = substitute(getcwd(0, 0), $HOME, '~', '')
    const max_len: number = 25

    while len(cwd) > max_len
        cwd = cwd[stridx(cwd, '/') + 1 :]
    endwhile

    return cwd
enddef

def LspProgress(): string
    var progress: dict<any> = get(g:, "LspProgress", {})

    if empty(progress)
        return ""
    endif

    var res: list<string> = []

    for info in values(progress)
        var p: string = "0%%"

        if info.percentage >= 0
            p = string(info.percentage) .. "%%"
        endif

        var str: list<string> =<< trim eval END
        LSP: {info.serverName}
        {info.title} {info.message} completed {p}
        END

        res->add(str->join(" "))
    endfor

    return res->join(", ")
enddef

def StatusLine(): string
    var status: list<string> =<< trim eval END
    %f%m%r%h %w%y
    %=
    {LspProgress()}
    %=
    CWD: {GetCwd()}  (%l, %c) [%p%%,%P]
    END

    return " " .. status->join(" ")
enddef

&statusline = $"%{{%{expand("<SID>")}StatusLine()%}}"
