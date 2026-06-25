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
        filetype: ['c', 'cpp', 'objc'],
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
        initializationOptions: {
            tinymist: {
                preview: {
                    background: {
                        enabled: true,
                        args: [
                            "--invert-colors=never",
                            "--partial-rendering=true"
                        ]
                    }
                },
                lint: {
                    enabled: true,
                    when: "onSave"
                },
                formatterMode: "typstyle",
                formatterPrintWidth: 80,
                formatterProseWrap: true
            }
        }
    },
    {
        name: 'luals',
        filetype: ['lua'],
        path: 'lua-language-server',
        args: [],
    },
    {
        name: 'codebook',
        filetype: ['typst'],
        path: 'codebook-lsp',
        args: ['serve']
    }
]

var ActualLspServers: list<dict<any>> = []

for server: dict<any> in LspServers
    if executable(server.path) == 1
        ActualLspServers->add(server)
    else
        continue
    endif

    if has('unix')
        if server.path == 'clangd'
            server.args += ['--malloc-trim']
        endif
    endif
endfor

g:LspOptionsSet(LspOptions)
g:LspAddServer(ActualLspServers)

import autoload "../autoload/lsp.vim"

augroup CustomLsp
    au User LspAttached {
        setlocal tagfunc=lsp#lsp#TagFunc
        setlocal omnifunc=g:LspOmniFunc

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
    au User LspProgressUpdate lsp.ProgressUpdate()
augroup END
