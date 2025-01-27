-- Colletion of small convenience plugins with minimal configuration.

return {

    -- Copilot
    {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'InsertEnter',
        config = function()
            require('copilot').setup({
                suggestion = { enabled = false },
                panel = { enabled = false },
            })
        end,
    },
    {
        'olimorris/codecompanion.nvim',
        event = 'VeryLazy',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-treesitter/nvim-treesitter',
            'echasnovski/mini.diff',
        },
        opts = {
            display = {
                diff = { provider = 'mini_diff' },
                chat = {
                    show_header_separator = false,
                    window = { layout = 'float' },
                },
            },
            strategies = {
                chat = {
                    keymaps = {
                        close = { modes = { n = 'q' } },
                        stop = { modes = { n = '<C-c>' } },
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
                '<Cmd>CodeCompanionChat Toggle<CR>',
                { desc = 'Toggle [C]ode [C]ompanion chat' }
            )
        end,
    },

    -- Floating terminal
    {
        'akinsho/toggleterm.nvim',
        version = '*',
        keys = {
            { '<Leader>tt', '<Cmd>ToggleTerm name=Terminal<CR>', mode = 'n', desc = '[T]oggle [T]erm' },
        },
        ---@module 'toggleterm'
        ---@type ToggleTermConfig
        opts = {
            direction = 'float',
            highlights = {
                NormalFloat = { link = 'NormalFloat' },
                FloatBorder = { link = 'FloatBorder' },
            },
            float_opts = {
                width = math.floor(vim.o.columns * 0.6),
                height = math.floor(vim.o.lines * 0.8),
                border = 'single',
                title_pos = 'center',
            },
        },
        config = function(_, opts)
            require('toggleterm').setup(opts)
            vim.api.nvim_create_autocmd('TermOpen', {
                pattern = 'term://*toggleterm#*',
                callback = function()
                    vim.keymap.set('n', 'q', '<Cmd>ToggleTerm<CR>', { buffer = true, desc = '[T]oggle [T]erm' })
                    vim.keymap.set('t', '<Esc><Esc>', '<Cmd>ToggleTerm<CR>', { buffer = true, desc = '[T]oggle [T]erm' })
                end,
            })
        end,
    },

    -- Filesystem manager
    {
        'stevearc/oil.nvim',
        keys = {
            {
                '<Leader>ft',
                function() require('oil').open_float() end,
                mode = { 'n' },
                desc = '[F]ile [T]ree',
            },
        },
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            view_options = { show_hidden = true },
            float = { max_width = 0.45, max_height = 0.8 },
            keymaps = {
                ['q'] = { 'actions.close' },
                ['<C-h>'] = { 'actions.show_help' },
                ['<C-->'] = { 'actions.select', opts = { horizontal = true } },
                ['<C-Bslash>'] = { 'actions.select', opts = { vertical = true } },
            },
            -- Optional dependencies
            dependencies = { 'nvim-tree/nvim-web-devicons' },
        },
        config = function(_, opts)
            require('oil').setup(opts)
            -- Automatically open preview
            vim.api.nvim_create_autocmd('User', {
                pattern = 'OilEnter',
                callback = vim.schedule_wrap(function(args)
                    local oil = require('oil')
                    if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
                        oil.open_preview()
                    end
                end),
            })
        end,
    },

    -- Symbol Outline
    {
        'hedyhli/outline.nvim',
        cmd = { 'Outline', 'OutlineOpen' },
        keys = {
            { '<leader>fo', '<cmd>Outline<CR>', desc = '[F]ile [O]utline' },
        },
        opts = {
            outline_window = { split_command = '40vsplit', winhl = 'Normal:NormalFloat' },
            outline_items = { show_symbol_details = false },
            preview_window = { winhl = 'NormalFloat:NormalFloat' },
        },
    },

    -- Add indentation guides even on blank lines
    {
        'lukas-reineke/indent-blankline.nvim',
        event = 'VeryLazy',
        main = 'ibl',
        opts = {
            scope = { char = '┊', highlight = 'Keyword', show_start = false, show_end = false },
            indent = { char = '┊' },
            exclude = { filetypes = { 'help', 'dashboard' } },
        },
    },

    -- Autopairs automatically adds matching parentheses, quotes, etc.
    { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

    -- Detect tabstop and shiftwidth automatically
    { 'tpope/vim-sleuth' },

    -- Highlight todo, notes, etc in comments
    {
        'folke/todo-comments.nvim',
        event = 'VeryLazy',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false },
    },

    -- Collection of various small independent plugins/modules
    {
        'echasnovski/mini.nvim',
        event = 'VeryLazy',
        config = function()
            -- Better Around/Inside textobjects
            local ai = require('mini.ai')
            ai.setup({
                n_lines = 500,
                custom_textobjects = {
                    -- NOTE: The textobjects below are manually added to WhichKey
                    o = ai.gen_spec.treesitter({ -- code block
                        a = { '@block.outer', '@conditional.outer', '@loop.outer' },
                        i = { '@block.inner', '@conditional.inner', '@loop.inner' },
                    }),
                    f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }), -- function
                    c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }), -- class
                    u = ai.gen_spec.function_call(), -- u for "Usage"
                    U = ai.gen_spec.function_call({ name_pattern = '[%w_]' }), -- without dot in function name
                },
            })

            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            require('mini.surround').setup()

            -- Git tools, also used with codecompanion.nvim for single buffer diffs
            require('mini.diff').setup({
                view = { style = 'sign', signs = { add = '▎', change = '▎', delete = '' }, priority = 5 },
                mappings = {
                    apply = '<Leader>ga',
                    reset = '<Leader>gr',
                    goto_prev = '<Leader>gp',
                    goto_next = '<Leader>gn',
                    goto_first = '<Leader>gg',
                    goto_last = '<Leader>gG',
                },
            })
            vim.keymap.set('n', '<Leader>tg', MiniDiff.toggle_overlay, { desc = '[T]oggle [G]it overlay' })

            -- Session management
            local sessions = require('mini.sessions')
            sessions.setup()
            vim.keymap.set('n', '<Leader>Sw', function()
                sessions.write(vim.fn.fnamemodify(vim.uv.cwd(), ':t')) ---@diagnostic disable-line
            end, { desc = '[S]ession [W]rite' })
            vim.keymap.set(
                'n',
                '<Leader>Sr',
                function() sessions.read(vim.fn.fnamemodify(vim.uv.cwd(), ':t')) end, ---@diagnostic disable-line
                { desc = '[S]ession [R]estore' }
            )
            vim.keymap.set(
                'n',
                '<Leader>Sd',
                function() sessions.delete(vim.fn.fnamemodify(vim.uv.cwd(), ':t')) end, ---@diagnostic disable-line
                { desc = '[S]ession [D]elete' }
            )
            vim.keymap.set('n', '<Leader>Ss', sessions.select, { desc = '[S]ession [S]elect' })
        end,
    },

    -- Navigate between tmux and neovim seamlessly
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

    -- Render markdown nicely
    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown', 'codecompanion' },
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },

    -- Preview markdown in browser
    {
        'iamcco/markdown-preview.nvim',
        cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
        ft = { 'markdown' },
        build = function(plugin)
            -- Install markdown preview, use npx if available.
            if vim.fn.executable('npx') then
                vim.cmd('!cd ' .. plugin.dir .. ' && cd app && npx --yes yarn install')
            else
                vim.cmd([[Lazy load markdown-preview.nvim]])
                vim.fn['mkdp#util#install']()
            end
        end,
        init = function()
            if vim.fn.executable('npx') then vim.g.mkdp_filetypes = { 'markdown' } end
        end,
    },
}
