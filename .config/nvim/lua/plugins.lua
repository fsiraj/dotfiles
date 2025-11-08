local autostyle = require('autostyle')

-- Applies hihglight overrides on ColorScheme event
autostyle.hl_autocmd()

-- Language support

local language_servers = {
    -- Python
    basedpyright = {
        settings = {
            basedpyright = {
                analysis = {
                    diagnosticMode = 'openFilesOnly',
                    typeCheckingMode = 'standard',
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticSeverityOverrides = {},
                },
            },
        },
    },
    -- Lua
    lua_ls = {
        settings = {
            Lua = {
                completion = { callSnippet = 'Replace' },
                diagnostics = {
                    globals = { 'vim', 'require' },
                    disable = { 'missing-fields' },
                },
            },
        },
    },
    -- C++
    clangd = {},
    -- Bash
    bashls = {
        filetypes = { 'bash', 'sh' },
    },
    -- Markdown
    marksman = {},
    -- TOML
    taplo = {},
    -- JSON
    jsonls = {},
    -- YAML
    yamlls = {},
    -- Rust handled by Rustaceanvim
}

local formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
    markdown = { 'markdownlint' },
    zsh = { 'shfmt', 'shellcheck' },
    sh = { 'shfmt', 'shellcheck' },
}

local linters_by_ft = {
    markdown = { 'markdownlint' },
}

-- Add tools here for Mason to install
local ensure_installed = vim.tbl_keys(language_servers or {})
vim.list_extend(ensure_installed, {
    'stylua',
    'ruff',
    'debugpy',
    'markdownlint',
    'shellcheck',
    'shfmt',
    'codelldb',
    'rust-analyzer',
})

-- Highlight symbol references on hover
local function lsp_highlight_symbols(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if
        client
        and client:supports_method(
            vim.lsp.protocol.Methods.textDocument_documentHighlight,
            event.buf
        )
    then
        local highlight_augroup =
            vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
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
end

-- If LSP supports inlay hints, enable them
local function lsp_inlay_hints(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if
        client
        and client:supports_method(
            vim.lsp.protocol.Methods.textDocument_inlayHint,
            event.buf
        )
    then
        vim.keymap.set('n', '<Leader>ti', function()
            local is_enabled = vim.lsp.inlay_hint.is_enabled({
                bufnr = event.buf,
            })
            vim.lsp.inlay_hint.enable(not is_enabled)
            vim.notify('Inlay Hints: ' .. tostring(not is_enabled))
        end, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
    end
end

-- To make UIs multiples of consistent width
local unit_width = 40

-- Dashboard header
local neovim_logo = [[
        @@@           @@        
      @@@@@@          @@@@      
    @@@@@@@@@@        @@@@@@    
  ##@@@@@@@@@@@       @@@@@@@@  
  ###@@@@@@@@@@@      @@@@@@@@  
  ####@@@@@@@@@@@     @@@@@@@@  
  ######@@@@@@@@@@@   @@@@@@@@  
  #######@@@@@@@@@@@  @@@@@@@@  
  ########  @@@@@@@@@ @@@@@@@@  
  ########   @@@@@@@@@@@@@@@@@  
  ########    @@@@@@@@@@@@@@@@  
  ########      @@@@@@@@@@@@@@  
  ########       @@@@@@@@@@@@@  
   #######        @@@@@@@@@@@   
     #####         @@@@@@@@     
       ###          @@@@@       
        ##            @@        
]]

-- Plugin config
local M = {
    -- NOTE: Essentials

    --Mini
    {
        'echasnovski/mini.nvim',
        event = 'VeryLazy',
        config = function()
            -- Enhanced jump motions
            require('mini.jump').setup()

            -- Better Around/Inside textobjects
            local ai = require('mini.ai')
            ai.setup({
                n_lines = 500,
                custom_textobjects = {
                    o = ai.gen_spec.treesitter({ -- code block
                        a = {
                            '@block.outer',
                            '@conditional.outer',
                            '@loop.outer',
                        },
                        i = {
                            '@block.inner',
                            '@conditional.inner',
                            '@loop.inner',
                        },
                    }),
                    f = ai.gen_spec.treesitter({
                        a = '@function.outer',
                        i = '@function.inner',
                    }), -- function
                    c = ai.gen_spec.treesitter({
                        a = '@class.outer',
                        i = '@class.inner',
                    }), -- class
                    u = ai.gen_spec.function_call(), -- u for "Usage"
                    U = ai.gen_spec.function_call({ name_pattern = '[%w_]' }), -- without dot in function name
                },
            })

            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            require('mini.surround').setup()

            -- Delete buffers and preserve window layout
            require('mini.bufremove').setup()
            vim.keymap.set('ca', 'bd', 'lua MiniBufremove.delete()')
            vim.keymap.set('ca', 'bw', 'lua MiniBufremove.wipeout()')

            -- Git tools, used for inline diffs (and codecompanion)
            require('mini.diff').setup({
                mappings = { apply = '<Leader>ga', reset = '<Leader>gr' },
                view = {
                    style = 'sign',
                    signs = { add = '▎', change = '▎', delete = '' },
                    priority = 5,
                },
                options = { linematch = 0 },
            })
            vim.keymap.set(
                'n',
                '<Leader>gd',
                MiniDiff.toggle_overlay,
                { desc = 'Toggle Git Overlay' }
            )

            -- Session management
            local sessions = require('mini.sessions')
            sessions.setup()
            -- stylua: ignore start
            vim.keymap.set(
                'n', '<Leader>Sw',
                function() sessions.write(vim.fn.fnamemodify(vim.uv.cwd(), ':t')) end,
                { desc = 'Session Write' }
            )
            vim.keymap.set(
                'n', '<Leader>Sr',
                function() sessions.read(vim.fn.fnamemodify(vim.uv.cwd(), ':t')) end,
                { desc = 'Session Restore' }
            )
            vim.keymap.set(
                'n', '<Leader>Sd',
                function() sessions.delete(vim.fn.fnamemodify(vim.uv.cwd(), ':t')) end,
                { desc = 'Session Delete' }
            )
            vim.keymap.set(
                'n', '<Leader>Ss',
                sessions.select,
                { desc = 'Session Select' }
            )
            -- stylua: ignore end
        end,
    },

    --Snacks
    {
        'folke/snacks.nvim',
        opts = {
            image = { enabled = true },
            bigfile = { enabled = true },
            git = { enabled = true },
            dashboard = {
                enabled = true,
                sections = { { section = 'header' }, { section = 'startup' } },
                preset = { header = neovim_logo },
            },
        },
        config = function(_, opts)
            require('snacks').setup(opts)
            vim.keymap.set(
                'n',
                '<Leader>gb',
                Snacks.git.blame_line,
                { desc = 'Blame' }
            )
            vim.api.nvim_create_autocmd('User', {
                pattern = 'SnacksDashboardOpened',
                callback = function()
                    vim.cmd('match SnacksDashboardHeaderSecondary /#/')
                    vim.cmd('2match WarningMsg /⚡/')
                    -- stylua: ignore
                    vim.keymap.set(
                        'n', 'r', vim.g.mapleader .. 'Sr',
                        { buffer = true, remap = true, desc = 'Session Restore' }
                    )
                end,
            })
            vim.api.nvim_create_autocmd('User', {
                pattern = 'SnacksDashboardClosed',
                callback = function()
                    vim.cmd('match none')
                    vim.cmd('2match none')
                end,
            })
        end,
    },

    --WhichKey
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        keys = {
            {
                '<Leader>?',
                function() require('which-key').show({ global = false }) end,
                desc = ' [?] Which Key: Buffer Local Keymaps',
            },
        },
        opts = {
            preset = 'helix',
            delay = 500,
            win = { title_pos = 'center' },
            triggers = {
                { '<auto>', mode = 'nixsotc' },
                { 's', mode = { 'n', 'v' } },
            },
            icons = {
                mappings = vim.g.have_nerd_font,
                keys = {},
            },
            -- stylua: ignore
            spec = {
                { '<Leader>i', group = 'Info', icon = { icon = ' ', color = 'cyan' }, },
                { '<Leader>c', group = 'Code', mode = { 'n', 'x' }, icon = { icon = ' ', color = 'orange' }, },
                { '<Leader>d', group = 'Debug', icon = { icon = ' ', color = 'red' }, },
                { '<Leader>s', group = 'Search', icon = { icon = ' ', color = 'green' }, },
                { '<Leader>S', group = 'Sessions', icon = { icon = '󰙰 ', color = 'purple' }, },
                { '<Leader>f', group = 'F', icon = { icon = '󰈢 ', color = 'azure' }, },
                { '<Leader>t', group = 'Toggle', icon = { icon = ' ', color = 'yellow' }, },
                { '<Leader>n', group = 'Neotest', icon = { icon = ' ', color = 'azure' }, },
                { '<Leader>g', group = 'Git', mode = { 'n', 'v' }, icon = { cat = 'filetype', name = 'git' }, },
            },
        },
    },

    --Fzflua
    {
        'ibhagwan/fzf-lua',
        event = 'VeryLazy',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            defaults = { formatter = 'path.filename_first' },
            winopts = {
                width = math.min(
                    unit_width * 4,
                    math.floor(0.8 * vim.o.columns)
                ),
                height = 0.8,
                row = 0.5,
            },
            hls = { title = 'FloatTitle' },
            keymap = {
                builtin = {
                    true,
                    ['<C-u>'] = 'preview-up',
                    ['<C-d>'] = 'preview-down',
                },
            },
            files = {
                hidden = true,
                follow = true,
                fd_opts = [[--color=never --hidden --type f --type l --exclude .git --exclude .venv]],
            },
            grep = { hidden = true },
            buffers = {
                previewer = false,
                winopts = { height = 16, width = unit_width * 2 },
            },
            ui_select = function(fzf_opts, items)
                return vim.tbl_deep_extend('force', fzf_opts, {
                    prompt = ' ',
                    winopts = {
                        title = ' '
                            .. vim.trim(
                                (fzf_opts.prompt or 'Select'):gsub(
                                    '%s*:%s*$',
                                    ''
                                )
                            )
                            .. ' ',
                        title_pos = 'center',
                        width = unit_width * 2,
                        height = math.ceil(
                            math.min(vim.o.lines * 0.8, #items + 4)
                        ),
                    },
                })
            end,
        },
        config = function(_, opts)
            local fzf = require('fzf-lua')
            local actions = require('fzf-lua.actions')
            opts.helptags = { actions = { ['enter'] = actions.help_vert } }
            opts.colorschemes = {
                actions = {
                    ['enter'] = function(selected, _)
                        if #selected == 0 then return end
                        local colorscheme = selected[1]:match('^[^:]+')
                        local ok = pcall(
                            function() autostyle.sync_theme(colorscheme) end
                        )
                        if not ok then
                            vim.notify(
                                'Failed to load ' .. colorscheme,
                                vim.log.levels.ERROR
                            )
                        end
                    end,
                },
            }

            fzf.setup(opts)
            fzf.register_ui_select(opts.ui_select)

            -- Custom pickers
            fzf.magic_colorschemes = function()
                return fzf.colorschemes({ colors = autostyle.colorschemes })
            end
            fzf.plugins = function()
                fzf.files({ cwd = vim.fn.stdpath('data') .. '/lazy' })
            end
            fzf.dotfiles = function() return fzf.files({ cwd = '~/dotfiles' }) end

            -- stylua: ignore
            local keymaps = {
                { 'n', '<Leader>sb', fzf.builtin, 'Search Builtin' },
                { 'n', '<Leader>sr', fzf.resume, 'Search Resume' },
                { 'n', '<Leader>sf', fzf.files, 'Search Files' },
                { 'n', '<Leader>so', fzf.oldfiles, 'Search Oldfiles' },
                { 'n', '<Leader>sw', fzf.grep_cword, 'Search Current Word' },
                { 'n', '<Leader>sg', fzf.live_grep, 'Search by Grep' },
                { 'n', '<Leader>sh', fzf.helptags, 'Search Help' },
                { 'n', '<Leader>sH', fzf.highlights, 'Search Highlights' },
                { 'n', '<Leader>sc', fzf.magic_colorschemes, 'Search Magic Colorschemes', },
                { 'n', '<Leader>sC', fzf.colorschemes, 'Search All Colorschemes' },
                { 'n', '<Leader>sk', fzf.keymaps, 'Search Keymaps' },
                { 'v', '<Leader>ss', fzf.grep_visual, 'Search Selection' },
                { 'n', '<Leader>/' , fzf.lgrep_curbuf, ' [/] Fuzzy Search Current Buffer', },
                { 'n', '<Leader>sd', fzf.dotfiles, 'Search Dotfiles', },
                { 'n', '<Leader>sp', fzf.plugins, 'Search Plugins', },
                { 'n', '<Leader><Leader>', fzf.buffers, ' [ ] Find Existing Buffers', },
            }
            -- <Leader>ss = Search Symbol Buffer (Namu)
            -- <Leader>sS = Search Symbol Workspace (Namu)
            -- <Leader>sq = Search Quickfix (Namu)

            for _, map in ipairs(keymaps) do
                vim.keymap.set(
                    map[1],
                    map[2],
                    map[3],
                    { desc = 'FzfLua: ' .. map[4] }
                )
            end
        end,
    },

    --Treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        event = 'VeryLazy',
        build = ':TSUpdate',
        main = 'nvim-treesitter.configs',
        opts = {
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
            incremental_selection = { enable = true },
        },
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        event = 'VeryLazy',
    },
    {
        'nvim-treesitter/nvim-treesitter-context',
        event = 'VeryLazy',
        opts = { enable = true, max_lines = 12 },
    },

    --IndentBlankline
    {
        'lukas-reineke/indent-blankline.nvim',
        event = 'VeryLazy',
        main = 'ibl',
        opts = {
            scope = {
                char = '┊',
                highlight = 'Keyword',
                show_start = false,
                show_end = false,
            },
            indent = { char = '┊' },
            exclude = { filetypes = { 'help', 'dashboard' } },
        },
    },

    --Autopairs
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = true,
    },

    --VimSleuth
    {
        'tpope/vim-sleuth',
        lazy = false,
    },

    -- NOTE: Styling

    --Catppuccin
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        opts = {
            flavor = 'mocha',
            default_integrations = true,
            integrations = {
                -- Most common plugins enabled by default
                noice = true,
                which_key = true,
                mason = true,
                blink_cmp = true,
                neotest = true,
                diffview = true,
            },
        },
    },

    --Tokyonight
    {
        'folke/tokyonight.nvim',
        priority = 1000,
        opts = { style = 'night', plugins = { auto = true } },
    },

    --RosePine
    {
        'rose-pine/neovim',
        priority = 1000,
        name = 'rose-pine',
        opts = { variant = 'main' },
    },

    --Nord
    {
        'shaunsingh/nord.nvim',
        priority = 1000,
        lazy = false,
        name = 'nord',
    },

    --Everforest
    {
        'neanias/everforest-nvim',
        priority = 1000,
        config = function()
            require('everforest').setup({
                background = 'hard',
                on_highlights = function(hl, palette)
                    hl.Normal = { bg = palette.bg_dim }
                end,
            })
        end,
    },

    --Github
    {
        'projekt0n/github-nvim-theme',
        name = 'github-theme',
        priority = 1000,
    },

    --TinyDeviconsAutoColors
    {
        'rachartier/tiny-devicons-auto-colors.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        event = 'VeryLazy',
        config = function()
            require('tiny-devicons-auto-colors').setup({ autoreload = true })
        end,
    },

    --Lualine
    {
        'nvim-lualine/lualine.nvim',
        event = 'VeryLazy',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'folke/noice.nvim',
        },
        config = function()
            -- Has several useful components
            local noice = require('noice')

            -- Custom components
            local mode = {
                function() return string.upper(vim.api.nvim_get_mode().mode) end,
            }
            local branch = { 'branch', icon = '' }
            local tabs = {
                'tabs',
                cond = function() return #vim.fn.gettabinfo() > 1 end,
                show_modified_status = true,
            }
            local lsp_status = {
                'lsp_status',
                icon = '󱚠 ',
                ignore_lsp = { 'copilot' },
            }
            local showmode = {
                noice.api.status.mode.get, ---@diagnostic disable-line
                cond = noice.api.status.mode.has, ---@diagnostic disable-line
            }
            local showcmd = {
                noice.api.status.command.get, ---@diagnostic disable-line
                cond = noice.api.status.command.has, ---@diagnostic disable-line
            }
            local text = function(t)
                return function() return t end
            end

            -- Minimal
            local minimal = {
                winbar = {
                    lualine_b = { 'filetype' },
                },
                inactive_winbar = { lualine_a = { 'filetype' } },
                filetypes = {
                    'Outline',
                    'DiffviewFiles',
                    'dap-view-term',
                    'neotest-summary',
                    'neo-tree',
                    'checkhealth',
                    'noice',
                },
            }

            -- Terminal (No filetype)
            local terminal = {
                winbar = {
                    lualine_a = { text('Terminal') },
                    lualine_y = { showcmd },
                },
                inactive_winbar = {
                    lualine_a = { text('Terminal') },
                    lualine_c = { text(' ') },
                },
                filetypes = { 'terminal' },
            }

            -- Codecompanion
            local codecompanion = {
                winbar = {
                    lualine_a = { 'filename' },
                    lualine_c = { text(' ') },
                    lualine_y = {
                        require(
                            'codecompanion._extensions.spinner.styles.lualine'
                        ).get_lualine_component(),
                        text('CodeCompanion'),
                    },
                },
                inactive_winbar = nil,
                filetypes = { 'codecompanion' },
            }
            codecompanion.inactive_winbar = vim.deepcopy(codecompanion.winbar)

            -- Lualine config
            require('lualine').setup({
                options = {
                    icons = vim.g.have_nerd_font,
                    theme = 'custom',
                    section_separators = { left = '', right = '' },
                    component_separators = { left = '|', right = '|' },
                    disabled_filetypes = {
                        winbar = {
                            'dap-repl',
                            'dap-view',
                            'snacks_dashboard',
                            'toggleterm',
                        },
                    },
                },
                extensions = { minimal, terminal, codecompanion },
                sections = {},
                inactive_sections = {},
                winbar = {
                    lualine_a = { mode, 'filename' },
                    lualine_b = { tabs, branch, 'diff', 'diagnostics' },
                    lualine_c = {},
                    lualine_y = {
                        showcmd,
                        showmode,
                        'filetype',
                    },
                    lualine_z = { lsp_status },
                },
                inactive_winbar = {
                    lualine_a = { 'filename' },
                    lualine_c = { text(' ') },
                },
            })
        end,
    },

    --Noice
    {
        'folke/noice.nvim',
        event = 'VeryLazy',
        dependencies = { 'MunifTanjim/nui.nvim' },
        opts = {
            cmdline = {
                enabled = true,
                format = {},
            },
            messages = { enabled = true },
            notify = { enabled = true },
            popupmenu = { enabled = false },
            lsp = {
                progress = { enabled = false },
                hover = { enabled = true },
                signature = { enabled = true },
                override = {
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                    ['vim.lsp.util.stylize_markdown'] = true,
                },
            },
            views = {
                mini = {
                    timeout = 5000,
                    size = { max_width = unit_width * 2 },
                },
                cmdline_popup = {
                    size = {
                        min_width = unit_width,
                        max_width = unit_width * 2,
                    },
                    border = { style = 'none', padding = { 1, 2 } },
                    filter_options = {},
                    win_options = {
                        winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
                        wrap = true,
                    },
                },
                cmdline_input = {
                    border = { style = 'solid', padding = { 0, 2 } },
                },
                confirm = {
                    position = { row = '50%' },
                },
            },
        },
        config = function(_, opts)
            require('noice').setup(opts)
            vim.keymap.set(
                'n',
                '<Leader>ii',
                '<Cmd>NoiceAll<CR>',
                { desc = 'Messages' }
            )
        end,
    },

    -- TinyGlimmer
    {
        'rachartier/tiny-glimmer.nvim',
        event = 'VeryLazy',
        priority = 10,
        config = function()
            require('tiny-glimmer').setup({
                overwrite = {
                    yank = {
                        enabled = true,
                        default_animation = {
                            name = 'fade',
                            settings = { from_color = vim.g.palette.accent },
                        },
                    },
                    paste = {
                        enabled = true,
                        default_animation = {
                            name = 'fade',
                            settings = { from_color = vim.g.palette.green },
                        },
                    },
                    undo = {
                        enabled = true,
                        default_animation = {
                            name = 'fade',
                            settings = { from_color = vim.g.palette.green },
                        },
                    },
                    redo = {
                        enabled = true,
                        default_animation = {
                            name = 'fade',
                            settings = { from_color = vim.g.palette.green },
                        },
                    },
                },
                animations = {
                    fade = { min_duration = 1000, max_duration = 1000 },
                },
            })
        end,
    },

    --NOTE: Extras

    --Neogit
    {
        'NeogitOrg/neogit',
        keys = {
            { '<Leader>N', '<Cmd>Neogit<CR>', desc = ' Neogit: Git' },
        },
        dependencies = {
            'nvim-lua/plenary.nvim',
            'sindrets/diffview.nvim',
            'ibhagwan/fzf-lua',
        },
        config = true,
    },

    --Diffview
    {
        'sindrets/diffview.nvim',
        keys = {
            { '<Leader>gD', '<Cmd>DiffviewOpen<CR>', desc = 'Open Diffview' },
        },
        opts = {
            enhanced_diff_hl = true,
            keymaps = {
                view = { ['q'] = '<Cmd>DiffviewClose<CR>' },
                file_panel = { ['q'] = '<Cmd>DiffviewClose<CR>' },
            },
        },
    },

    --Copilot
    {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        build = ':Copilot auth',
        event = 'VeryLazy',
        opts = {
            suggestion = {
                enabled = true,
                auto_trigger = false,
                keymap = { accept = '<C-l>', accept_word = '<M-l>' },
            },
            panel = { enabled = false },
            server = { type = 'binary' },
        },
        config = function(_, opts)
            require('copilot').setup(opts)
            vim.keymap.set('n', '<Leader>tc', function()
                require('copilot.suggestion').toggle_auto_trigger()
                vim.notify(
                    'Copilot Auto-suggestions: '
                        .. tostring(vim.b.copilot_suggestion_auto_trigger)
                )
            end, {
                desc = 'Toggle Copilot Suggestions',
                silent = true,
            })
        end,
    },

    --Codecompanion
    {
        'olimorris/codecompanion.nvim',
        event = 'VeryLazy',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-treesitter/nvim-treesitter',
            'echasnovski/mini.diff',
            'ravitemer/codecompanion-history.nvim',
            'lalitmee/codecompanion-spinners.nvim',
        },
        opts = {
            adapters = {
                http = {
                    copilot = function()
                        return require('codecompanion.adapters').extend(
                            'copilot',
                            {
                                schema = { model = { default = 'gpt-4.1' } },
                            }
                        )
                    end,
                },
                acp = {
                    gemini_cli = function()
                        return require('codecompanion.adapters').extend(
                            'gemini_cli',
                            {
                                commands = {
                                    flash = {
                                        'gemini',
                                        '--experimental-acp',
                                        '-m',
                                        'gemini-2.5-flash',
                                    },
                                    pro = {
                                        'gemini',
                                        '--experimental-acp',
                                        '-m',
                                        'gemini-2.5-pro',
                                    },
                                },
                                defaults = { auth_method = 'oauth-personal' },
                            }
                        )
                    end,
                },
            },
            display = {
                chat = { auto_scroll = false },
            },
            extensions = {
                history = {
                    opts = {
                        expiration_days = 30,
                        title_generation_opts = { refresh_every_n_prompts = 3 },
                    },
                },
                spinner = {
                    opts = {
                        style = 'lualine',
                    },
                },
            },
        },
        config = function(_, opts)
            require('codecompanion').setup(opts)
            vim.keymap.set('ca', 'cc', 'CodeCompanion')
            vim.keymap.set(
                { 'n', 'v' },
                '<Leader>cc',
                '<Cmd>CodeCompanionChat Toggle<CR><Cmd>wincmd =<CR>',
                { desc = 'Code Companion Toggle Chat' }
            )
            vim.api.nvim_create_autocmd('User', {
                pattern = 'CodeCompanionChatCreated',
                callback = function() vim.wo.winhl = 'NormalFloat:Normal' end,
            })
        end,
    },

    --Floaterm
    {
        'nvzone/floaterm',
        event = 'VeryLazy',
        dependencies = 'nvzone/volt',
        opts = {
            border = false,
            size = { h = 80, w = 60 },
            terminals = {
                { name = 'Terminal' },
            },
            -- stylua: ignore
            mappings = {
                sidebar = function(buf)
                    local api = require('floaterm.api')
                    vim.keymap.set('n', '<C-l>', api.switch_wins, { buffer = buf })
                    vim.keymap.set('n', '<C-h>', api.switch_wins, { buffer = buf })
                    vim.keymap.set('n', '<C-j>', function() api.cycle_term_bufs('next') end, { buffer = buf })
                    vim.keymap.set('n', '<C-k>', function() api.cycle_term_bufs('prev') end, { buffer = buf })
                    pcall(function() vim.keymap.del('n', '<Esc>', { buffer = buf }) end)
                end,
                term = function(buf)
                    local api = require('floaterm.api')
                    vim.keymap.set('n', '<C-l>', api.switch_wins, { buffer = buf })
                    vim.keymap.del('n', '<Esc>', { buffer = buf })
                end,
            },
        },
        config = function(_, opts)
            local floaterm = require('floaterm')
            floaterm.setup(opts)
            vim.keymap.set(
                { 'n', 't' },
                '<Bslash>',
                floaterm.toggle,
                { desc = 'Toggle Floaterm' }
            )
            vim.keymap.set(
                { 't' },
                '<C-Bslash>',
                '<Bslash>',
                { desc = 'Toggle Floaterm' }
            )
            vim.api.nvim_create_autocmd('TermOpen', {
                desc = 'Set Floaterm Normal',
                callback = function()
                    local state = require('floaterm.state')
                    if state.volt_set then
                        vim.wo[state.win].winhl =
                            'Normal:exdarkbg,floatBorder:exdarkborder'
                    end
                end,
            })
        end,
    },

    --Namu
    {
        'bassamsdata/namu.nvim',
        event = 'VeryLazy',
        config = function()
            require('namu').setup({
                namu_symbols = {
                    options = {
                        display = { mode = 'icon', format = 'tree_guides' },
                        window = { relative = 'win' },
                        AllowKinds = {
                            rust = { -- explicit for rust
                                'Function',
                                'Method',
                                'Struct',
                                'Field',
                                'Enum',
                                'Constant',
                                'Variable',
                                'Module',
                                'Property',
                            },
                        },
                    },
                },
            })
            -- stylua: ignore
            local keymaps = {
                { 'n', '<leader>ss', '<Cmd>Namu symbols<CR>', 'Search Symbols Buffer', },
                { 'n', '<leader>sS', '<Cmd>Namu workspace<CR>', 'Search Symbols Workspace', },
                { 'n', '<leader>sq', '<Cmd>Namu diagnostics<CR>', 'Search Quickfix', },
            }

            for _, map in ipairs(keymaps) do
                vim.keymap.set(
                    map[1],
                    map[2],
                    map[3],
                    { desc = 'Namu  : ' .. map[4], silent = true }
                )
            end
        end,
    },

    --Outline
    {
        'hedyhli/outline.nvim',
        keys = {
            { '<leader>fo', '<cmd>Outline<CR>', desc = 'File Outline' },
        },
        opts = {
            outline_window = {
                split_command = unit_width .. 'vsplit',
                winhl = 'Normal:NormalFloat',
            },
            outline_items = { show_symbol_details = true },
            preview_window = { winhl = 'NormalFloat:NormalFloat' },
        },
    },

    --Neotree
    {
        'nvim-neo-tree/neo-tree.nvim',
        keys = {
            { '<leader>ft', '<Cmd>Neotree toggle<CR>', desc = 'File Tree' },
        },
        branch = 'v3.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim',
            'nvim-tree/nvim-web-devicons',
        },
        opts = {
            enable_git_status = false,
            enable_diagnostics = false,
            window = { width = unit_width },
            filesystem = {
                filtered_items = { children_inherit_highlights = false },
            },
        },
    },

    --TodoComments
    {
        'folke/todo-comments.nvim',
        event = 'VeryLazy',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false },
    },

    --HighlightColors
    {
        'brenoprata10/nvim-highlight-colors',
        event = 'VeryLazy',
        opts = {
            render = 'virtual',
            virtual_symbol = '',
            exclude_filetypes = { 'lazy' },
        },
    },

    --VimTmuxNavigator
    {
        'christoomey/vim-tmux-navigator',
        init = function() vim.g.tmux_navigator_no_mappings = 1 end,
        cmd = {
            'TmuxNavigateLeft',
            'TmuxNavigateDown',
            'TmuxNavigateUp',
            'TmuxNavigateRight',
        },
        keys = {
            { '<c-h>', '<cmd>TmuxNavigateLeft<CR>' },
            { '<c-j>', '<cmd>TmuxNavigateDown<CR>' },
            { '<c-k>', '<cmd>TmuxNavigateUp<CR>' },
            { '<c-l>', '<cmd>TmuxNavigateRight<CR>' },
        },
    },

    {
        'kawre/neotab.nvim',
        event = 'VeryLazy',
        config = true,
    },

    -- NOTE: Language Tools

    -- Mason
    {
        'williamboman/mason.nvim',
        dependencies = {
            'WhoIsSethDaniel/mason-tool-installer.nvim',
        },
        config = function()
            -- Mason installs external tools
            require('mason').setup()
            vim.keymap.set(
                'n',
                '<Leader>im',
                '<Cmd>Mason<CR>',
                { desc = 'Mason' }
            )

            require('mason-tool-installer').setup({
                ensure_installed = ensure_installed,
            })
        end,
    },

    --Lspconfig
    {
        'neovim/nvim-lspconfig',
        event = 'VeryLazy',
        dependencies = {
            'williamboman/mason-lspconfig.nvim',
            'saghen/blink.cmp',
            'ibhagwan/fzf-lua',
        },
        config = function()
            -- stylua: ignore start
            vim.keymap.set('n', '<Leader>is', '<Cmd>LspInfo<CR>', { desc = 'LSP' })

            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup( 'lsp-attach', { clear = true }),
                callback = function(event)
                    -- Keymaps
                    local fzf = require('fzf-lua')
                    local map = function(keys, func, desc, mode)
                        vim.keymap.set(
                            mode or 'n', keys, func,
                            { buffer = event.buf, desc = 'LSP: ' .. desc }
                        )
                    end
                    map('<Leader>cd', fzf.lsp_definitions, 'Code Definition')
                    map( '<Leader>cD', vim.lsp.buf.declaration, 'Code Declaration')
                    map('<Leader>cr', fzf.lsp_references, 'Code References')
                    map( '<Leader>cv', vim.lsp.buf.rename, 'Code Variable Rename')
                    map( '<Leader>ca', fzf.lsp_code_actions, 'Code Action', { 'n', 'x' })
                    -- <Leader>cf = Code Format (Conform)
                    -- <Leader>cc = Code Companion Chat (Codecompanion)

                    lsp_highlight_symbols(event)
                    lsp_inlay_hints(event)
                end,
            })
            -- stylua: ignore end

            vim.diagnostic.config({
                severity_sort = true,
                float = { border = 'none', source = 'if_many' },
                underline = { severity = vim.diagnostic.severity.ERROR },
                signs = vim.g.have_nerd_font
                        and {
                            text = {
                                [vim.diagnostic.severity.ERROR] = '󰅚 ',
                                [vim.diagnostic.severity.WARN] = '󰀪 ',
                                [vim.diagnostic.severity.INFO] = '󰋽 ',
                                [vim.diagnostic.severity.HINT] = '󰌶 ',
                            },
                        }
                    or {},
                virtual_text = false,
            })

            -- Toggle diagnostic information
            vim.keymap.set('n', '<Leader>td', function()
                vim.diagnostic.enable(not vim.diagnostic.is_enabled())
                vim.notify(
                    'Diagnostics: ' .. tostring(vim.diagnostic.is_enabled())
                )
            end, { desc = 'LSP: Toggle Diagnostics' })

            -- Display floating diagnostic window
            vim.api.nvim_create_autocmd({ 'CursorHold' }, {
                callback = function()
                    if vim.diagnostic.is_enabled() then
                        vim.diagnostic.open_float({
                            scope = 'line',
                            focusable = false,
                            close_events = {
                                'CursorMoved',
                                'CursorMovedI',
                                'BufLeave',
                            },
                        })
                    end
                end,
            })

            require('mason-lspconfig').setup({
                automatic_enable = { exclude = { 'rust_analyzer' } },
            })

            -- Add custom configs to LSPs
            for server_name, server_config in pairs(language_servers) do
                vim.lsp.config(server_name, server_config)
            end
        end,
    },

    --Blink
    {
        'saghen/blink.cmp',
        event = 'VeryLazy',
        dependencies = {
            { 'saghen/blink.compat', version = '*', opts = {} },
            'rafamadriz/friendly-snippets',
            'rcarriga/cmp-dap',
        },
        version = '*',
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            cmdline = {
                enabled = true,
                keymap = {
                    preset = 'cmdline',
                    ['<CR>'] = { 'accept', 'fallback' },
                },
                completion = { ghost_text = { enabled = false } },
            },
            enabled = function()
                local disabled_filetypes = { 'oil', 'gitcommit' }
                return not vim.tbl_contains(
                        disabled_filetypes,
                        vim.bo.filetype
                    )
                    and (
                        vim.bo.buftype ~= 'prompt'
                        or require('cmp_dap').is_dap_buffer()
                    )
            end,
            completion = {
                menu = {
                    auto_show = function(ctx) return ctx.mode ~= 'cmdline' end,
                    draw = {
                        components = {
                            label = { width = { max = unit_width } },
                        },
                    },
                },
                documentation = { auto_show = true, auto_show_delay_ms = 50 },
            },
            keymap = {
                preset = 'enter',
                ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
                ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
            },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = 'mono',
            },
            sources = {
                default = function()
                    local sources = { 'lsp', 'path', 'snippets' }
                    if require('cmp_dap').is_dap_buffer() then
                        table.insert(sources, 'dap')
                    else
                        table.insert(sources, 'buffer')
                    end
                    return sources
                end,
                per_filetype = {
                    codecompanion = { 'codecompanion' },
                },
                providers = {
                    dap = {
                        name = 'dap',
                        module = 'blink.compat.source',
                    },
                },
            },
        },
    },

    --Conform
    {
        'stevearc/conform.nvim',
        event = 'VeryLazy',
        keys = {
            {
                '<Leader>cf',
                function()
                    require('conform').format({
                        async = true,
                        lsp_format = 'fallback',
                    })
                end,
                mode = { 'n', 'v' },
                desc = 'Code Format Buffer/Selection',
            },
        },
        init = function() vim.g.format_on_save = false end,
        opts = {
            notify_on_error = false,
            format_on_save = function(_)
                if not vim.g.format_on_save then return end
                return {
                    timeout_ms = 500,
                    lsp_format = 'fallback',
                }
            end,
            formatters_by_ft = formatters_by_ft,
        },
        config = function(_, opts)
            require('conform').setup(opts)
            -- Toggle format on save
            vim.keymap.set('n', '<Leader>tf', function()
                vim.g.format_on_save = not vim.g.format_on_save
                vim.notify('Format On Save: ' .. tostring(vim.g.format_on_save))
            end, { desc = 'Toggle Format On Save' })
        end,
    },

    --Lint
    {
        'mfussenegger/nvim-lint',
        event = 'VeryLazy',
        config = function()
            local lint = require('lint')
            -- Disable all default linters, enable manually if needed
            lint.linters_by_ft = linters_by_ft

            -- Configure linters
            lint.linters.markdownlint.args = { '--disable', 'MD013', '--' }

            -- Autocommand to start linting
            local lint_augroup =
                vim.api.nvim_create_augroup('lint', { clear = true })
            vim.api.nvim_create_autocmd(
                { 'BufEnter', 'BufWritePost', 'InsertLeave' },
                {
                    group = lint_augroup,
                    callback = function()
                        -- Only run in modifiable buffers
                        if vim.opt_local.modifiable:get() then
                            lint.try_lint()
                        end
                    end,
                }
            )
        end,
    },

    --Neotest
    {
        'nvim-neotest/neotest',
        event = 'VeryLazy',
        dependencies = {
            'nvim-neotest/nvim-nio',
            'nvim-lua/plenary.nvim',
            'antoinemadec/FixCursorHold.nvim',
            'nvim-treesitter/nvim-treesitter',
            'nvim-neotest/neotest-python',
        },
        config = function()
            local neotest = require('neotest')
            neotest.setup({
                adapters = {
                    require('neotest-python')({}),
                },
                summary = { open = unit_width .. 'vsplit' },
                output = { open_on_run = false },
            })

            -- Keymaps
            -- stylua: ignore start
            local keymaps = {
                { 'n', '<Leader>nr', function() neotest.run.run() end, 'Run' },
                { 'n', '<Leader>nl', function() neotest.run.run_last() end, 'Run Last', },
                { 'n', '<Leader>nf', function() neotest.run.run(vim.fn.expand('%')) end, 'Run File', },
                { 'n', '<Leader>na', function() neotest.run.run({ suite = true }) end, 'Run All', },
                { 'n', '<Leader>nw', function() neotest.watch.toggle() end, 'Watch', },
                { 'n', '<Leader>no', function() neotest.output.open({ enter = true }) end, 'Output', },
                { 'n', '<Leader>ns', function() neotest.summary.toggle() end, 'Summary', },
                { 'n', ']n', function() neotest.jump.next({ status = 'failed' }) end, 'Next', },
                { 'n', '[n', function() neotest.jump.prev({ status = 'failed' }) end, 'Previous', },
            }

            for _, map in ipairs(keymaps) do
                vim.keymap.set( map[1], map[2], map[3], { desc = 'Neotest ' .. map[4] })
            end

            -- Window highlight and close window keymap
            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'neotest-summary',
                callback = function() vim.wo.winhl = 'Normal:NormalFloat' end,
            })
            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'neotest-output',
                callback = function()
                    vim.keymap.set( 'n', 'q', '<Cmd>:q<CR>', { buffer = true, desc = 'Close Window' })
                end,
            })
            -- stylua: ignore end
        end,
    },

    --Sniprun
    {
        'michaelb/sniprun',
        branch = 'master',
        build = 'sh install.sh',
        event = 'VeryLazy',
        config = function()
            require('sniprun').setup({
                display = { 'Classic' },
                selected_interpreters = { 'Python3_fifo', 'Lua_nvim' },
                repl_enable = { 'Python3_fifo' },
                interpreter_options = {
                    Lua_nvim = { use_on_filetypes = { 'codecompanion' } },
                },
            })
            vim.keymap.set(
                { 'n', 'v' },
                '<Leader>r',
                '<Plug>SnipRun',
                { desc = ' Run Code' }
            )
        end,
    },

    --Rustaceanvim
    {
        'mrcjkb/rustaceanvim',
        version = '^6',
        lazy = false,
    },

    --Lazydev
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                { path = 'luvit-meta/library', words = { 'vim%.uv' } },
            },
        },
    },

    --LuvitMeta
    {
        'Bilal2453/luvit-meta',
        lazy = true,
    },

    --RenderMarkdown
    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown', 'codecompanion' },
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            sign = { enabled = false },
            heading = {
                width = 'block',
                icons = {
                    '󰉫 : ',
                    '󰉬 : ',
                    '󰉭 : ',
                    '󰉮 : ',
                    '󰉯 : ',
                    '󰉰 : ',
                },
                right_pad = 1,
            },
            code = {
                width = 'block',
                min_width = unit_width * 2,
                right_pad = 1,
            },
        },
    },

    --MarkdwonPreview
    {
        'iamcco/markdown-preview.nvim',
        cmd = {
            'MarkdownPreviewToggle',
            'MarkdownPreview',
            'MarkdownPreviewStop',
        },
        ft = { 'markdown' },
        build = function(plugin)
            if vim.fn.executable('npx') then
                -- stylua: ignore
                vim.cmd( '!cd ' .. plugin.dir .. ' && cd app && npx --yes yarn install')
            else
                vim.cmd([[Lazy load markdown-preview.nvim]])
                vim.fn['mkdp#util#install']()
            end
        end,
        init = function()
            if vim.fn.executable('npx') then
                vim.g.mkdp_filetypes = { 'markdown' }
            end
        end,
    },

    --Dap
    {
        'mfussenegger/nvim-dap',
        event = 'VeryLazy',
        dependencies = {
            -- UI
            {
                'igorlfs/nvim-dap-view',
                opts = {
                    winbar = { default_section = 'repl' },
                    windows = { terminal = { position = 'right' } },
                },
            },
            -- Installs dependencies
            'williamboman/mason.nvim',
            'jay-babu/mason-nvim-dap.nvim',
            -- Language specific debuggers
            'mfussenegger/nvim-dap-python',
        },
        config = function()
            local dap = require('dap')
            local dv = require('dap-view')
            local widgets = require('dap.ui.widgets')

            -- Keybindings
            -- stylua: ignore start
            vim.keymap.set( 'n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
            vim.keymap.set( 'n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
            vim.keymap.set( 'n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
            vim.keymap.set( 'n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
            vim.keymap.set( 'n', '<F4>', dap.run_to_cursor, { desc = 'Debug: Run to cursor' })

            vim.keymap.set( 'n', '<Leader>db', dap.toggle_breakpoint, { desc = 'Debug Breakpoint Toggle ' })
            vim.keymap.set( 'n', '<Leader>dc', dap.continue, { desc = 'Debug Continue Session.' })
            vim.keymap.set( 'n', '<Leader>dt', dap.terminate, { desc = 'Debug Terminate Session.' })
            vim.keymap.set( 'n', '<Leader>dr', dap.restart, { desc = 'Debug Restart Session.' })
            vim.keymap.set( 'n', '<Leader>dv', dv.toggle, { desc = 'Debug View Toggle ' })

            vim.keymap.set(
                'n', '<Leader>ds',
                function() widgets.centered_float(widgets.scopes) end,
                { desc = 'Debug Scope' }
            )
            vim.keymap.set(
                'n', '<Leader>dk',
                function() widgets.hover(nil, { border = 'none' }) end,
                { desc = 'Debug Symbol (Keywordprog)' }
            )

            vim.api.nvim_create_autocmd('FileType', {
                pattern = { 'dap-float' },
                callback = function(event)
                    vim.keymap.set( 'n', 'q', '<C-w>q', { silent = true, buffer = event.buf })
                end,
            })
            -- stylua: ignore end

            -- Installs all dependencies with mason
            require('mason-nvim-dap').setup({
                automatic_installation = true,
                handlers = {},
                ensure_installed = {
                    'python',
                },
            })

            -- Dap View setup
            vim.api.nvim_create_autocmd('FileType', {
                pattern = { 'dap-view', 'dap-repl' },
                callback = function() vim.wo.winhl = 'Normal:NormalFloat' end,
            })
            dap.defaults.fallback.switchbuf = 'usevisible,useopen,uselast'

            -- Change breakpoint icons
            local breakpoint_icons = vim.g.have_nerd_font
                    and {
                        Breakpoint = '',
                        BreakpointCondition = '',
                        BreakpointRejected = '',
                        LogPoint = '',
                        Stopped = '',
                    }
                or {}
            for type, icon in pairs(breakpoint_icons) do
                local tp = 'Dap' .. type
                local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
                vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
            end

            -- Launch dap view automatically when dap starts
            dap.listeners.before.attach['dap-view-config'] = dv.open
            dap.listeners.before.launch['dap-view-config'] = dv.open
            dap.listeners.before.event_terminated['dap-view-config'] = dv.close
            dap.listeners.before.event_exited['dap-view-config'] = dv.close

            -- Python specific config
            local python_path = vim.fs.joinpath(
                vim.fn.stdpath('data'),
                'mason',
                'packages',
                'debugpy',
                'venv',
                'bin',
                'python'
            )
            require('dap-python').setup(python_path)
        end,
    },
}

return M
