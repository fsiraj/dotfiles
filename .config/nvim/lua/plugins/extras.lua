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
                ['<C-_>'] = { 'actions.select', opts = { horizontal = true } },
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

    -- Find and replace
    {
        'MagicDuck/grug-far.nvim',
        keys = {
            {
                '<Leader>fr',
                ':GrugFar<CR>',
                mode = { 'n', 'v' },
                desc = '[F]ind [R]eplace',
            },
        },
        config = function() require('grug-far').setup({}) end,
    },

    -- Add indentation guides even on blank lines
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        config = function()
            require('ibl').setup({ exclude = { filetypes = { 'help', 'dashboard' } } })
            vim.keymap.set('n', '<Leader>ti', ':IBLToggle<CR>', { desc = '[T]oggle [I]ndent blank lines' })
        end,
    },

    -- Autopairs automatically adds matching parentheses, quotes, etc.
    { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

    -- Detect tabstop and shiftwidth automatically
    { 'tpope/vim-sleuth' },

    -- Highlight todo, notes, etc in comments
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false },
    },

    -- Collection of various small independent plugins/modules
    {
        'echasnovski/mini.nvim',
        config = function()
            -- Better Around/Inside textobjects
            require('mini.ai').setup({ n_lines = 500 })

            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            require('mini.surround').setup()

            -- Git tools, also used with codecompanion.nvim for single buffer diffs
            require('mini.diff').setup({
                view = { style = 'sign', signs = { add = '+', change = '~', delete = '-' }, priority = 5 },
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
            vim.keymap.set('n', '<Leader>tp', ':MarkdownPreviewToggle<CR>', { desc = '[T]oggle Markdown [P]review' })
        end,
    },
}
