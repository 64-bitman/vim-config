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
set viminfo+=n~/.config/vim/viminfo

augroup ColorschemeCustom
    au!
    au Colorscheme * {
        :highlight Normal ctermbg=NONE guibg=NONE
        :highlight link Normal NonText
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
noremap <leader>s "-
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
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"
inoremap <expr> <C-Y> pumvisible() ? "\<CR>" : "\<C-Y>"
vnoremap <leader>gr "hy:%s/<C-r>h//gc<left><left><left>
nnoremap <silent> <F5> <cmd>call <SID>PreciseTrimWhiteSpace()<cr>

set laststatus=2 number relativenumber ruler cursorline showcmd mouse=a title background=dark
set wildmenu completeopt=menuone,popup,fuzzy,longest wildignorecase wildoptions=pum pumheight=25 keywordprg=:Man
set expandtab tabstop=4 softtabstop=4 shiftwidth=4 shiftround smarttab smartindent autoindent
set nohlsearch incsearch ignorecase smartcase
set lazyredraw termguicolors signcolumn=number omnifunc=syntaxcomplete#Complete
set linebreak scrolloff=10 wrap nostartofline cpoptions+=n nofoldenable foldlevelstart=99 foldmethod=manual showbreak=>>>\
set autoread autowrite backspace=indent,eol,start
set backupcopy=auto backup writebackup backupdir=~/.cache/vim/backup dir=~/.cache/vim/swap
set undofile undodir=~/.cache/vim/undo
set hidden history=1000 sessionoptions-=options sessionoptions-=folds
set encoding=utf8 ffs=unix,dos,mac nrformats-=octal
set showmatch matchtime=1 matchpairs+=<:> ttimeoutlen=0 wrapmargin=15
set spelllang=en_ca,en_us,en_gb spelloptions=camel spellsuggest=best,20 dictionary+=/usr/share/dict/words complete+=k
&statusline = " %f%m%r%h %w%y %= CWD: %{pathshorten(substitute(getcwd(winnr()),$HOME,'~',''),4)}  (%l,%c) [%p%%,%P]"

g:c_no_curly_error = 1 # disable error highlight for c compound literals
g:ft_man_no_sect_fallback = 1
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
    autoComplete: v:false,
    useBufferCompletion: v:true,
    filterCompletionDuplicates: v:true,
}

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
augroup END

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
