vim9script

var LspOptions: dict<bool> = {
    autoComplete: false,
    omniComplete: true,
    showInlayHints: false,
    useBufferCompletion: false,
    filterCompletionDuplicates: true,
    showSignature: true,
    snippetSupport: false,
    popupBorder: true,
}

var LspServers: list<dict<any>> = [
    {
        name: 'clangd',
        filetype: ['c', 'cpp'],
        path: 'clangd',
        args: [
            '--background-index',
            '--clang-tidy',
            '--pch-storage=memory',
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
    },
    {
        name: 'rust-analyzer',
        filetype: ['rust'],
        path: 'rust-analyzer',
        args: [],
        syncInit: true,
    },
    {
        name: 'tinymist',
        filetype: ['typst'],
        path: 'tinymist',
        args: ['lsp'],
    },
    {
        name: 'luals',
        filetype: ['lua'],
        path: 'lua-language-server',
        args: []
    }
]

for [idx: number, server: dict<any>] in items(LspServers)
    if !executable(server.path)
        remove(LspServers, idx)
        continue
    endif

    if has('unix')
        if server.path == 'clangd'
            server.args += ['--malloc-trim']
        endif
    endif
endfor

export def Load(): void
    if &buftype == ""
        :packadd lsp
        :silent! helptags ALL
    endif
enddef

augroup CustomLsp
    au User LspSetup {
        g:LspOptionsSet(LspOptions)
        g:LspAddServer(LspServers)
    }
    au User LspAttached {
        setlocal tagfunc=lsp#lsp#TagFunc
        setlocal omnifunc=g:LspOmniFunc
        # setlocal keywordprg=:LspHover
        # setlocal formatexpr=lsp#lsp#FormatExpr()

        noremap <buffer> <leader>g <cmd>LspDiag current<cr>
        noremap <buffer> <leader>= :LspFormat<cr>
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
        noremap <buffer> <leader>lf <cmd>LspDocumentSymbol<cr>
        noremap <buffer> <leader>ss <cmd>LspShowSignature<cr>
        noremap <buffer> <leader>lh <cmd>LspHover<cr>
        inoremap <buffer> <C-X><C-X> <cmd>LspShowSignature<cr>
    }
augroup END
    
