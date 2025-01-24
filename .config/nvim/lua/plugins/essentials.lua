-- WhichKey
-- Telescope
-- Treesitter

return {

    -- WhichKey: Plugin to show pending keybinds.
    {
        'folke/which-key.nvim',
        event = 'VimEnter',
        keys = {
            {
                '<Leader>?',
                function() require('which-key').show({ global = false }) end,
                desc = 'Which Key: Buffer Local Keymaps',
            },
        },
        opts = {
            preset = 'modern',
            win = { wo = { winblend = 5 } },
            triggers = {
                { '<auto>', mode = 'nixsotc' },
                { 's', mode = { 'n', 'v' } },
            },
            icons = {
                mappings = vim.g.have_nerd_font,
                keys = {},
            },
            spec = {
                { '<Leader>i', group = '[I]nfo', icon = { icon = ' ', color = 'cyan' } },
                {
                    '<Leader>c',
                    group = '[C]ode',
                    mode = { 'n', 'x' },
                    icon = { icon = ' ', color = 'orange' },
                },
                { '<Leader>b', group = '[B]uffer', icon = { icon = '󰈔 ', color = 'cyan' } },
                { '<Leader>d', group = '[D]ebug', icon = { icon = ' ', color = 'red' } },
                { '<Leader>s', group = '[S]earch', icon = { icon = ' ', color = 'green' } },
                { '<Leader>f', group = '[F]ind/[F]ile', icon = { icon = '󰈢 ', color = 'azure' } },
                { '<Leader>t', group = '[T]oggle', icon = { icon = ' ', color = 'yellow' } },
                {
                    '<Leader>g',
                    group = '[G]it',
                    mode = { 'n', 'v' },
                    icon = { cat = 'filetype', name = 'git' },
                },
            },
        },
    },

    -- Telescope: Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        event = 'VimEnter',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                cond = function() return vim.fn.executable('make') == 1 end,
            },
            { 'nvim-telescope/telescope-ui-select.nvim' },
            { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
        },
        config = function()
            require('telescope').setup({
                defaults = {
                    layout_strategy = 'horizontal',
                    sorting_strategy = 'ascending',
                    layout_config = {
                        horizontal = { prompt_position = 'top', preview_width = 0.6 },
                    },
                    wrap_results = false,
                    file_ignore_patterns = { '%.git/' },
                    mappings = {
                        i = {
                            ['<C-y>'] = 'select_default',
                            ['<C-Bslash>'] = 'select_vertical',
                            ['<C-_>'] = 'select_horizontal',
                            ['<C-x>'] = 'delete_buffer',
                        },
                    },
                    vimgrep_arguments = {
                        'rg',
                        '--color=never',
                        '--no-heading',
                        '--with-filename',
                        '--line-number',
                        '--column',
                        '--smart-case',
                        '--hidden',
                    },
                },

                pickers = {
                    find_files = { hidden = true },
                    help_tags = { mappings = { i = { ['<CR>'] = 'select_vertical' } } },
                    colorscheme = { enable_preview = true },
                    lsp_references = { path_display = { 'tail' } },
                },

                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown(),
                    },
                },
            })

            -- Customize appearance
            if vim.g.colors_name == 'catppuccin-mocha' then
                local colors = require('catppuccin.palettes').get_palette()
                local mantle = colors.mantle
                local theme = {
                    TelescopeMatching = { fg = colors.flamingo },
                    TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },
                    TelescopePromptPrefix = { bg = mantle, fg = colors.mauve },
                    TelescopePromptNormal = { bg = mantle },
                    TelescopeResultsNormal = { bg = mantle },
                    TelescopePreviewNormal = { bg = mantle },
                    TelescopePromptBorder = { bg = mantle, fg = mantle },
                    TelescopeResultsBorder = { bg = mantle, fg = mantle },
                    TelescopePreviewBorder = { bg = mantle, fg = mantle },
                    TelescopePromptTitle = { bg = colors.mauve, fg = mantle },
                    TelescopeResultsTitle = { fg = mantle },
                    TelescopePreviewTitle = { bg = colors.green, fg = mantle },
                }
                for hl, col in pairs(theme) do
                    vim.api.nvim_set_hl(0, hl, col)
                end
            end

            -- Enable Telescope extensions if they are installed
            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<Leader>sh', builtin.help_tags, { desc = 'Telescope: [S]earch [H]elp' })
            vim.keymap.set('n', '<Leader>sH', builtin.highlights, { desc = 'Telescope: [S]earch [H]ighlights' })
            vim.keymap.set('n', '<Leader>sk', builtin.keymaps, { desc = 'Telescope: [S]earch [K]eymaps' })
            vim.keymap.set('n', '<Leader>sf', builtin.find_files, { desc = 'Telescope: [S]earch [F]iles' })
            vim.keymap.set('n', '<Leader>sb', builtin.builtin, { desc = 'Telescope: [S]earch [B]uiltin' })
            vim.keymap.set('n', '<Leader>sw', builtin.grep_string, { desc = 'Telescope: [S]earch Current [W]ord' })
            vim.keymap.set('n', '<Leader>sg', builtin.live_grep, { desc = 'Telescope: [S]earch by [G]rep' })
            vim.keymap.set('n', '<Leader>sd', builtin.diagnostics, { desc = 'Telescope: [S]earch [D]iagnostics' })
            vim.keymap.set('n', '<Leader>sr', builtin.resume, { desc = 'Telescope: [S]earch [R]esume' })
            vim.keymap.set('n', '<Leader>so', builtin.oldfiles, { desc = 'Telescope: [S]earch [O]ld Files' })
            vim.keymap.set('n', '<Leader><Leader>', builtin.buffers, { desc = 'Telescope: [ ] Find Existing Buffers' })
            vim.keymap.set(
                'v',
                '<Leader>ss',
                '"zy<Cmd>Telescope grep_string<CR><C-r>z',
                { desc = 'Telescope: [S]earch [S]election' }
            )
            vim.keymap.set(
                'n',
                '<Leader>/',
                builtin.current_buffer_fuzzy_find,
                { desc = 'Telescope: [/] Fuzzy Search Current Buffer' }
            )
            vim.keymap.set(
                'n',
                '<Leader>sd',
                function() builtin.find_files({ cwd = '~/dotfiles' }) end,
                { desc = 'Telescope: [S]earch [D]otfiles' }
            )
        end,
    },

    -- Treesitter: Highlight, edit, and navigate code
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        main = 'nvim-treesitter.configs',
        opts = {
            ensure_installed = {
                'python',
                'bash',
                'c',
                'diff',
                'html',
                'lua',
                'luadoc',
                'markdown',
                'markdown_inline',
                'query',
                'vim',
                'vimdoc',
                'tmux',
                'yaml',
                'regex',
            },
            auto_install = true,
            highlight = {
                enable = true,
            },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = 'gnn',
                    node_incremental = 'grn',
                    scope_incremental = 'grc',
                    node_decremental = 'grm',
                },
            },
        },
        config = function(_, opts)
            vim.opt.foldmethod = 'expr'
            vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.opt.foldlevelstart = 99
            vim.opt.foldtext = ''
            local configs = require('nvim-treesitter.configs')
            configs.setup(opts)
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter-context',
    },
}
