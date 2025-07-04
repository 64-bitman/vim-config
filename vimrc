vim9script

&t_SI = "\<Esc>[6 q"
&t_SR = "\<Esc>[4 q"
&t_EI = "\<Esc>[2 q"

:packadd! comment
:packadd! editorconfig
:packadd! hlyank
:packadd! helptoc
:packadd! justify
:packadd! cfilter
:packadd! matchit
:runtime ftplugin/man.vim

:packadd! conflict-marker.vim

silent! :helptags ALL

if &term == "xterm-kitty"
    runtime kitty.vim
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
nnoremap <leader>m <cmd>ls<CR>:b<Space>
nnoremap <leader>M <cmd>ls<CR>:bd<Space>
nnoremap <S-Tab> <C-o>
noremap <C-j> <C-d>
noremap <C-k> <C-u>
noremap j gj
noremap k gk
noremap gj j
noremap gk k
noremap <leader>f <cmd>silent! w<cr><cmd>FZF<cr>
tnoremap <C-n> <C-\><C-n>
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
nnoremap <silent> <F5> <cmd>call <SID>PreciseTrimWhiteSpace()<cr>
nnoremap <leader>tt <cmd>call <SID>AddTermdebug()<cr><cmd>Termdebug<cr>
nnoremap <leader>ls <cmd>doautocmd User LspAttached<cr>
nnoremap <leader>be <cmd>syntax on<cr>
nnoremap <leader>bd <cmd>syntax off<cr>
nnoremap <leader>uu <cmd>UndotreeToggle<CR>
nnoremap <leader>uf <cmd>UndotreeFocus<CR>

set laststatus=2 number relativenumber ruler cursorline showcmd mouse=a ttymouse=sgr title background=dark
set wildmenu completeopt=menuone,preview,popup wildignorecase wildoptions=pum pumheight=25 keywordprg=:Man
set expandtab tabstop=4 softtabstop=4 shiftwidth=4 shiftround smarttab smartindent autoindent
set nohlsearch incsearch ignorecase smartcase nojoinspaces
set lazyredraw termguicolors signcolumn=number omnifunc=syntaxcomplete#Complete
set linebreak scrolloff=10 wrap nostartofline cpoptions+=n nofoldenable foldlevelstart=99 foldmethod=indent showbreak=>>>\
set autoread autowrite backspace=indent,eol,start textwidth=80
set backupcopy=auto backup writebackup undofile
set nohidden history=1000 sessionoptions-=options sessionoptions-=folds viewoptions-=cursor diffopt+=vertical
set encoding=utf8 ffs=unix,dos,mac termwinscroll=100000
set showmatch matchtime=1 matchpairs+=<:> ttimeoutlen=0 wrapmargin=15
set spelllang=en_ca,en_us,en_gb spelloptions=camel spellsuggest=best,20 dictionary+=/usr/share/dict/words complete+=k
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case grepformat+=%f:%l:%c:%m
&statusline = " %f%m%r%h %w%y %= CWD: %{" .. expand("<SID>") .. "GetCwd()}  (%l,%c) [%p%%,%P]"

var LspServers = [
    {
        name: 'clangd',
        filetype: ['c', 'cpp'],
        path: 'clangd',
        args: [
            '--background-index',
            '--clang-tidy',
            '--pch-storage=memory',
            '--malloc-trim',
            '--background-index-priority=normal',
            '--completion-style=detailed',
            '--header-insertion=never'
        ]
    },
    {
        name: 'pyright',
        filetype: ['python'],
        path: 'pyright-langserver',
        args: ['--stdio'],
        workspaceConfig: {
            python: {
                pythonPath: '/usr/bin/python'
            }
        }
    }
]

var LspOptions = {
    autoComplete: true,
    omniComplete: false,
    showInlayHints: false,
    useBufferCompletion: false,
    filterCompletionDuplicates: true,
    showSignature: true,
    snippetSupport: true,
    vsnipSupport: true,
    popupBorder: true,
}
g:termdebug_config = { evaluate_in_popup: true, wide: 163, variables_window: true, variables_window_height: 15 }
g:vim_json_warnings = 0
g:helptoc = {'shell_prompt': '^\[\w\+@\w\+\s.\+\]\d*\$\s.*$'}
g:vsnip_integ_create_autocmd = false
g:saveroot_nomatch = "current"


augroup Custom
    au!
    au FileType * {
        setlocal formatoptions+=cqjno
        if &makeprg == "make"
            setlocal makeprg=make\ -j12
        endif
    }
    autocmd BufRead,BufNewFile *.h setlocal filetype=c
    au FileType qf,fugitive Use_q_AsExit()
    au CmdWinEnter * Use_q_AsExit()
    au User SaverootCD {
        if !exists("g:_cdroot")
            if b:saveroot_marker =~# ".git" || b:saveroot_marker =~# ".projectroot_git"
                g:_cdroot = true
                :packadd vim-fugitive
                silent! :helptags ALL
            endif
        endif
    }
    au BufReadPost * {
        var line = line("'\"")
        if !exists("g:SessionLoad") && line >= 1 && line <= line("$") && &filetype !~# 'commit'
                && index(['xxd', 'gitrebase'], &filetype) == -1
            :execute "normal! g`\""
        endif
    }
    au Filetype c,cpp,python,sh,json,jsonc ++once {
        :packadd lsp
        silent! :helptags ALL
    }
    au User LspSetup {
        :packadd vim-vsnip
        :packadd vim-vsnip-integ
        silent! :helptags ALL

        call LspOptionsSet(LspOptions)
        call LspAddServer(LspServers)

        augroup LspAttach
            au!
            au User LspAttached OnLspAttach() | b:lsp_set = true
            au FileType c,cpp,python if !exists("b:lsp_set") | OnLspAttach() | endif
        augroup END
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
        var nr = bufnr("%")
        var save_cursor = getcurpos()
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
            :wa
        endif
    }
    au WinClosed * wincmd p
augroup END

command! DiffOrig DiffOrig()
command! SynStack SynStack()
command -nargs=* -complete=file Make make! <args>

def OnLspAttach(): void
    setlocal tagfunc=lsp#lsp#TagFunc

    noremap <buffer> <leader>g <cmd>LspDiag current<cr>
    noremap <buffer> <leader>= :LspFormat<cr>
    noremap <buffer> <leader>i <cmd>LspHover<cr>
    noremap <buffer> <leader>sh <cmd>LspSwitchSourceHeader<cr>
    noremap <buffer> <leader>hh <cmd>LspHighlight<cr>
    noremap <buffer> <leader>hc <cmd>LspHighlightClear<cr>
    noremap <buffer> <leader>a <cmd>LspCodeAction<cr>
    noremap <buffer> <leader>dd <cmd>LspGotoDeclaration<cr>
    noremap <buffer> <leader>de <cmd>LspGotoDefinition<cr>
    noremap <buffer> <leader>sr <cmd>LspShowReferences<cr>
    noremap <buffer> <leader>R <cmd>LspRename<cr>
    noremap <buffer> <leader>dp <cmd>LspDiagPrev<cr>
    noremap <buffer> <leader>dn <cmd>LspDiagNext<cr>
    noremap <buffer> <leader>L <cmd>LspDiagShow<cr>

    SetupVsnip()
enddef

def DoSnippet(): string
    g:vsnip_dont_complete = false
    return "\<C-y>"
enddef

def SetupVsnip(): void
    g:vsnip_dont_complete = true

    imap <expr> <C-j> pumvisible() ?  DoSnippet() : '<C-j>'

    # Jump forward or backward
    imap <buffer> <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
    smap <buffer> <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
    imap <buffer> <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
    smap <buffer> <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

    augroup CustomVsnip
        au!
        autocmd CompleteDonePre <buffer> {
             if complete_info(['mode']).mode !=? '' && !g:vsnip_dont_complete
               call vsnip_integ#on_complete_done(v:completed_item)
             endif
        }
        autocmd CompleteDone <buffer> {
            g:vsnip_dont_complete = true
        }
    augroup END
enddef

def PreciseTrimWhiteSpace(): void
    var saved_view: dict<number> = winsaveview()
    :keepjumps exe ":%s/\\s\\+$//ge"
    winrestview(saved_view)
enddef

def Use_q_AsExit(): void
    nnoremap <nowait> <buffer> q <cmd>q<cr>
    nnoremap <nowait> <buffer> <C-q> q
enddef

def AddTermdebug(): void
    if !get(g:, "termdebug_loaded")
        packadd termdebug
    endif
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

def SynStack(): void
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
enddef

def GetCwd(): string
    var cwd: string = substitute(getcwd(0, 0), $HOME, '~', '')
    const max_len: number = 50

    while len(cwd) > max_len
        cwd = cwd[stridx(cwd, '/') + 1 :]
    endwhile

    return cwd
enddef
