-- LSPs, Linters, Formatters, Completions

return {

    -- Install and configure LSPs and other external tools
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            -- Allows extra capabilities provided by blink.cmp
            'saghen/blink.cmp',
        },
        config = function()
            vim.keymap.set('n', '<Leader>is', '<Cmd>LspInfo<CR>', { desc = 'L[S]P' })
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
                callback = function(event)
                    -- Keymaps
                    local telescope = require('telescope.builtin')
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end
                    map('<Leader>cd', telescope.lsp_definitions, '[C]ode [D]efinition')
                    map('<Leader>cD', vim.lsp.buf.declaration, '[C]ode [D]eclaration')
                    map('<Leader>cr', telescope.lsp_references, '[C]ode [R]eferences')
                    map('<Leader>ci', telescope.lsp_implementations, '[C]ode [I]mplementation')
                    map('<Leader>ct', telescope.lsp_type_definitions, '[C]ode [T]ype Definition')
                    map('<Leader>cb', telescope.lsp_document_symbols, '[C]ode Symbols [B]uffer')
                    map('<Leader>cw', telescope.lsp_workspace_symbols, '[C]ode Symbols [W]orkspace')
                    map('<Leader>cv', vim.lsp.buf.rename, '[C]ode [V]ariable Rename')
                    map('<Leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
                    map('<Leader>cq', vim.diagnostic.setloclist, '[C]ode [Q]uickfix List')
                    map('<Leader>ck', vim.diagnostic.open_float, '[C]ode Diagnotic Float ([K]eywordprog)')
                    -- <Leader>cf = [C]ode [F]ormat (Conform)
                    -- <Leader>cc = [C]ode [C]ompanion Chat (Codecompanion)

                    -- Highliht references on hover
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })
                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds({
                                    group = 'lsp-highlight',
                                    buffer = event2.buf,
                                })
                            end,
                        })
                    end

                    -- If LSP supports inlay hints, enable them
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<Leader>th', function()
                            local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
                            vim.lsp.inlay_hint.enable(not is_enabled)
                            vim.print('Inlay Hints: ' .. tostring(not is_enabled))
                        end, '[T]oggle Inlay [H]ints')
                    end
                end,
            })

            -- Change diagnostic symbols in the sign column (gutter)
            if vim.g.have_nerd_font then
                local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
                local diagnostic_signs = {}
                for type, icon in pairs(signs) do
                    diagnostic_signs[vim.diagnostic.severity[type]] = icon
                end
                vim.diagnostic.config({ signs = { text = diagnostic_signs } })
            end

            -- Enable the following language servers
            local servers = {
                -- Python
                basedpyright = {
                    settings = {
                        basedpyright = {
                            analysis = {
                                diagnosticMode = 'openFilesOnly',
                                typeCheckingMode = 'standard',
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                            },
                        },
                    },
                },
                -- Markdown
                marksman = {},
                -- Lua
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = { callSnippet = 'Replace' },
                            diagnostics = { globals = { 'vim', 'require' }, disable = { 'missing-fields' } },
                        },
                    },
                },
                -- Bash
                bashls = {
                    filetypes = { 'bash', 'sh' },
                },
            }

            -- Mason installs external tools
            require('mason').setup()
            vim.keymap.set('n', '<Leader>im', '<Cmd>Mason<CR>', { desc = '[M]ason' })

            -- Add tools here that you want Mason to install
            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                'stylua',
                'black',
                'isort',
                'markdownlint',
                'jsonlint',
                'shellcheck',
                'shfmt',
            })
            require('mason-tool-installer').setup({ ensure_installed = ensure_installed })
            require('mason-lspconfig').setup({
                handlers = {
                    function(server_name)
                        local server_config = servers[server_name] or {}
                        -- Adds additional capabilities from blink.cmp
                        server_config.capabilities =
                            require('blink.cmp').get_lsp_capabilities(server_config.capabilities)
                        require('lspconfig')[server_name].setup(server_config)
                    end,
                },
            })
        end,
    },

    -- Autocompletion engine and sources
    {
        'saghen/blink.cmp',
        dependencies = {
            { 'saghen/blink.compat', version = '*', opts = {} },
            'rafamadriz/friendly-snippets',
            'giuxtaposition/blink-cmp-copilot',
            'rcarriga/cmp-dap',
        },
        version = '*',
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            enabled = function() return vim.bo.buftype ~= 'prompt' or require('cmp_dap').is_dap_buffer() end,
            completion = {
                menu = { auto_show = function(ctx) return ctx.mode ~= 'cmdline' end },
                documentation = { auto_show = true, auto_show_delay_ms = 50 },
            },
            keymap = {
                preset = 'enter',
                ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
                ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
                cmdline = {
                    preset = 'enter',
                    ['<Tab>'] = { 'show', 'select_next', 'fallback' },
                    ['<S-Tab>'] = { 'select_prev', 'fallback' },
                },
            },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = 'mono',
            },
            sources = {
                default = function()
                    local sources = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' }
                    if require('cmp_dap').is_dap_buffer() then table.insert(sources, 'dap') end
                    return sources
                end,
                per_filetype = {
                    codecompanion = { 'codecompanion' },
                },
                providers = {
                    copilot = {
                        name = 'copilot',
                        module = 'blink-cmp-copilot',
                        score_offset = 100,
                        async = true,
                        min_keyword_length = 10,
                    },
                    codecompanion = {
                        name = 'CodeCompanion',
                        module = 'codecompanion.providers.completion.blink',
                    },
                    dap = {
                        name = 'dap',
                        module = 'blink.compat.source',
                    },
                },
            },
        },
    },

    -- Code formatter
    {
        'stevearc/conform.nvim',
        event = 'BufEnter',
        keys = {
            {
                '<Leader>cf',
                function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
                mode = { 'n', 'v' },
                desc = '[C]ode [F]ormat Buffer/Selection',
            },
        },
        init = function() vim.g.disable_autoformat = true end,
        opts = {
            notify_on_error = false,
            format_on_save = function(_)
                if vim.g.disable_autoformat then return end
                return {
                    timeout_ms = 500,
                    lsp_format = 'fallback',
                }
            end,
            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'isort', 'black' },
                markdown = { 'markdownlint' },
                zsh = { 'shfmt', 'shellcheck' },
                sh = { 'shfmt', 'shellcheck' },
            },
        },
        config = function(_, opts)
            require('conform').setup(opts)

            -- Toggle format on save
            vim.api.nvim_create_user_command('ToggleFormatOnSave', function()
                vim.g.disable_autoformat = not vim.g.disable_autoformat
                vim.print('Format On Save: ' .. tostring(not vim.g.disable_autoformat))
            end, {
                desc = 'Toggle autoformat-on-save with conform',
            })
            vim.keymap.set('n', '<Leader>tf', ':ToggleFormatOnSave<CR>', { desc = '[T]oggle [F]ormat on save' })
        end,
    },

    -- Linters
    {
        'mfussenegger/nvim-lint',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            local lint = require('lint')
            -- Disable all default linters, enable manually if needed
            lint.linters_by_ft = {}

            -- Autocommand to start linting
            local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
            vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
                group = lint_augroup,
                callback = function()
                    -- Only run in modifiable buffers
                    if vim.opt_local.modifiable:get() then lint.try_lint() end
                end,
            })
        end,
    },

    -- Intellisense for neovim api and plugins
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                { path = 'luvit-meta/library', words = { 'vim%.uv' } },
            },
        },
    },
    { 'Bilal2453/luvit-meta', lazy = true },
}
