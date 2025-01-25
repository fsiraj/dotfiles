-- Colletion of small convenience plugins with minimal configuration.

return {

    -- Copilot
    {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        build = ':Copilot auth',
        event = 'InsertEnter',
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
        },
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
            { '<Bslash>', '<Cmd>ToggleTerm name=Terminal<CR>', mode = 'n', desc = 'Open Terminal' },
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
                    vim.keymap.set(
                        { 't', 'n' },
                        '<Esc><Esc>',
                        '<Cmd>ToggleTerm<CR>',
                        { buffer = true, desc = '[T]oggle [T]erm' }
                    )
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

    -- Highlight todo, notes, etc in comments
    {
        'folke/todo-comments.nvim',
        event = 'VeryLazy',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false },
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
}
