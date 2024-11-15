vim9script

&t_SI = "\<Esc>[6 q"
&t_SR = "\<Esc>[4 q"
&t_EI = "\<Esc>[2 q"

:packadd! comment
:packadd! editorconfig
:runtime ftplugin/man.vim

filetype plugin indent on
syntax on
g:mapleader = " "

augroup ColorschemeCustom
    au!
    au Colorscheme * {
        :highlight Normal ctermbg=NONE guibg=NONE
        :highlight link Normal NonText

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
    }
augroup END
:colorscheme retrobox

nnoremap <leader>l <C-^>
nnoremap <leader>n <cmd>bn<cr>
nnoremap <leader>p <cmd>bp<cr>
nnoremap <leader>o o<esc>
nnoremap <leader>O O<esc>
nnoremap <leader>m <cmd>ls<CR>:b<Space>
nnoremap <leader>M <cmd>ls<CR>:bd<Space>
noremap <leader>/ <cmd>set hlsearch!<cr>
noremap <C-l> <C-l><cmd>nohlsearch<cr><cmd>match<cr><cmd>diffupdate<cr>
nnoremap <S-Tab> <C-o>
noremap <C-j> <C-d>
noremap <C-k> <C-u>
noremap j gj
noremap k gk
noremap gj j
noremap gk k
noremap <leader>f <cmd>FZF<cr>
tnoremap <C-n> <C-\><C-n>
noremap <leader>q <cmd>stop<cr>
noremap <leader>e <cmd>wqa<cr>
noremap <C-S-Left> <C-W>>
noremap <C-S-Right> <C-W><
noremap <C-S-Up> <C-W>+
noremap <C-S-Down> <C-W>-
map <leader>s "+
noremap <leader>r <cmd>registers<cr>
noremap <leader>ww <cmd>w<cr>
noremap <leader>wa <cmd>wa<cr>
noremap <leader>co <cmd>copen<cr>
noremap <leader>cw <cmd>cwindow<cr>
noremap <leader>cc <cmd>cclose<cr>
noremap <leader>cl <cmd>cc<cr>
noremap <leader>cn <cmd>cnext<cr>
noremap <leader>cp <cmd>cprev<cr>
noremap <leader>cb <cmd>cabove<cr>
noremap <leader>cu <cmd>cbelow<cr>
noremap <leader>v <cmd>silent! loadview<cr>
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"
inoremap <expr> <C-Y> pumvisible() ? "\<CR>" : "\<C-Y>"
vnoremap <leader>gr "hy:%s/<C-r>h//gc<left><left><left>
nnoremap <silent> <F5> <cmd>call <SID>PreciseTrimWhiteSpace()<cr>
nnoremap <leader>t <cmd>call <SID>AddTermdebug()<cr><cmd>Termdebug<cr>
noremap ! :!
noremap <leader><leader> <Cmd>call stargate#OKvim(v:count1)<CR>
nnoremap <C-w><leader> <Cmd>call stargate#Galaxy()<CR>
tnoremap <C-w><leader> <Cmd>call stargate#Galaxy()<CR>

set laststatus=2 number relativenumber ruler cursorline showcmd mouse=a title background=dark
set wildmenu completeopt=menuone,preview,popup wildignorecase wildoptions=pum pumheight=25 keywordprg=:Man
set expandtab tabstop=4 softtabstop=4 shiftwidth=4 shiftround smarttab smartindent autoindent
set nohlsearch incsearch ignorecase smartcase
set lazyredraw termguicolors signcolumn=number omnifunc=syntaxcomplete#Complete
set linebreak scrolloff=10 wrap nostartofline cpoptions+=n nofoldenable foldlevelstart=99 foldmethod=manual showbreak=>>>\ 
set autoread autowrite backspace=indent,eol,start
set backupcopy=auto backup writebackup undofile
set hidden history=1000 sessionoptions-=options sessionoptions-=folds viewoptions-=cursor
set encoding=utf8 ffs=unix,dos,mac nrformats-=octal
set showmatch matchtime=1 matchpairs+=<:> ttimeoutlen=0 wrapmargin=15
set spelllang=en_ca,en_us,en_gb spelloptions=camel spellsuggest=best,20 dictionary+=/usr/share/dict/words complete+=k
&statusline = " %f%m%r%h %w%y %= CWD: %{pathshorten(substitute(getcwd(winnr()),$HOME,'~',''),4)}  (%l,%c) [%p%%,%P]"

g:local_vimrc = {cache_file: $HOME .. "/.cache/vim/local_vimrc_cache"}

var LspServers = [{name: 'clangd',
    filetype: ['c', 'cpp'],
    path: '/bin/clangd',
    args: [
        '--background-index',
        '--clang-tidy',
        '--pch-storage=memory',
        '--malloc-trim',
        '--background-index-priority=background',
        '--completion-style=detailed'
    ]
}]
var LspOptions = {
    autoComplete: false,
    omniComplete: true,
    useBufferCompletion: false,
    filterCompletionDuplicates: true,
}
g:termdebug_config = { evaluate_in_popup: true, wide: 163, variables_window: true, variables_window_height: 15 }
g:vim_json_warnings = 0

augroup Custom
    au!
    au FileType * setlocal formatoptions+=j formatoptions-=cro
    autocmd BufRead,BufNewFile *.h setlocal filetype=c
    au FileType qf Use_q_AsExit()
    au CmdWinEnter * Use_q_AsExit()
    au BufReadPost * {
        var line = line("'\"")
        if line >= 1 && line <= line("$") && &filetype !~# 'commit'
                && index(['xxd', 'gitrebase'], &filetype) == -1
            :execute "normal! g`\""
        endif
    }
    au Filetype c,cpp ++once {
        :packadd lsp

        call LspOptionsSet(LspOptions)
        call LspAddServer(LspServers)

        augroup LspAttach
            au User LspAttached OnLspAttach()
        augroup END
    }
    au VimResume * :silent! checktime
    au VimResized * :wincmd =
    au VimLeavePre * {
        if v:this_session != ""
            execute ':mksession! ' .. v:this_session
        endif
    }
    au BufWinLeave ?* :silent! mkview!
    au User TermdebugStartPre {
        var nr = bufnr("%")
        var save_cursor = getcurpos()

        :tabnew
        execute ":buffer " .. nr
        setpos('.', save_cursor)
    }
    au User TermdebugStartPost {
        :Source
    }
    au User TermdebugStopPost {
        :tabclose
    }
    # Don't screw up folds when inserting text that might affect them, until
    # leaving insert mode. Foldmethod is local to the window. Protect against
    # screwing up folding when switching between windows.
    autocmd InsertEnter * {
        if !exists('w:last_fdm') 
            w:last_fdm = &foldmethod
            setlocal foldmethod=manual
        endif
    }
    autocmd InsertLeave,WinLeave * {
        if exists('w:last_fdm') 
            &l:foldmethod = w:last_fdm 
            unlet w:last_fdm 
        endif
    }
augroup END

command! DiffOrig DiffOrig()
command -nargs=* -complete=file Make make! <args>

def OnLspAttach()
    setlocal tagfunc=lsp#lsp#TagFunc
    augroup LspCustom
        au!
        au BufWritePre <buffer> {
            :execute "LspFormat"
        }
    augroup END

    noremap <buffer> <leader>g <cmd>LspDiag current<cr>
    noremap <buffer> <leader>= <cmd>LspFormat<cr>
    noremap <buffer> <leader>i <cmd>LspHover<cr>
    noremap <buffer> <leader>sh <cmd>LspSwitchSourceHeader<cr>
    noremap <buffer> <leader>hh <cmd>LspHighlight<cr>
    noremap <buffer> <leader>hc <cmd>LspHighlightClear<cr>
    noremap <buffer> <leader>a <cmd>LspCodeAction<cr>
    noremap <buffer> <leader>dd <cmd>LspGotoDeclaration<cr>
    noremap <buffer> <leader>de <cmd>LspGotoDefinition<cr>
    noremap <buffer> <leader>R <cmd>LspRename<cr>
enddef

def PreciseTrimWhiteSpace()
    var saved_view = winsaveview()
    :keepjumps exe ":%s/\\s\\+$//ge"
    winrestview(saved_view)
enddef

def Use_q_AsExit()
    nnoremap <nowait> <buffer> q <cmd>quit<cr>
    nnoremap <nowait> <buffer> <C-q> q
enddef

def AddTermdebug()
    if !get(g:, "termdebug_loaded") 
        packadd termdebug
    endif
enddef

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
