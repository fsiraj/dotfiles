-- WhichKey
-- Telescope
-- Treesitter

return {
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
            vim.keymap.set('n', '<Leader>tg', MiniDiff.toggle_overlay, { desc = '[T]oggle [G]it Overlay' })

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

    -- WhichKey: Plugin to show pending keybinds.
    {
        'folke/which-key.nvim',
        event = 'VimEnter',
        keys = {
            {
                '<Leader>?',
                function() require('which-key').show({ global = false }) end,
                desc = ' [?] Which Key: Buffer Local Keymaps',
            },
        },
        opts = {
            preset = 'modern',
            win = { width = { max = 150 } },
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
                { '<Leader>b', group = '[B]uffer', icon = { icon = '󰈔 ', color = 'gray' } },
                { '<Leader>d', group = '[D]ebug', icon = { icon = ' ', color = 'red' } },
                { '<Leader>s', group = '[S]earch', icon = { icon = ' ', color = 'green' } },
                { '<Leader>S', group = '[S]essions', icon = { icon = '󰙰 ', color = 'purple' } },
                { '<Leader>f', group = '[F]', icon = { icon = '󰈢 ', color = 'azure' } },
                { '<Leader>t', group = '[T]oggle', icon = { icon = ' ', color = 'yellow' } },
                {
                    '<Leader>g',
                    group = '[G]it',
                    mode = { 'n', 'v' },
                    icon = { cat = 'filetype', name = 'git' },
                },
            },
        },
        config = function(_, opts)
            require('which-key').setup(opts)

            -- Add Text Objects from mini.ai
            local objects = {
                { ' ', desc = 'whitespace' },
                { '"', desc = '" string' },
                { "'", desc = "' string" },
                { '(', desc = '() block' },
                { ')', desc = '() block with ws' },
                { '<', desc = '<> block' },
                { '>', desc = '<> block with ws' },
                { '?', desc = 'user prompt' },
                { 'U', desc = 'use/call without dot' },
                { '[', desc = '[] block' },
                { ']', desc = '[] block with ws' },
                { '_', desc = 'underscore' },
                { '`', desc = '` string' },
                { 'a', desc = 'argument' },
                { 'b', desc = ')]} block' },
                { 'c', desc = 'class' },
                { 'f', desc = 'function' },
                { 'i', desc = 'indent' },
                { 'o', desc = 'block, conditional, loop' },
                { 'q', desc = 'quote `"\'' },
                { 't', desc = 'tag' },
                { 'u', desc = 'use/call' },
                { '{', desc = '{} block' },
                { '}', desc = '{} with ws' },
            }

            ---@type wk.Spec[]
            local ret = { mode = { 'o', 'x' } }
            ---@type table<string, string>
            local mappings = vim.tbl_extend('force', {}, {
                around = 'a',
                inside = 'i',
                around_next = 'an',
                inside_next = 'in',
                around_last = 'al',
                inside_last = 'il',
            }, opts.mappings or {})
            mappings.goto_left = nil
            mappings.goto_right = nil

            for name, prefix in pairs(mappings) do
                name = name:gsub('^around_', ''):gsub('^inside_', '')
                ret[#ret + 1] = { prefix, group = name }
                for _, obj in ipairs(objects) do
                    local desc = obj.desc
                    if prefix:sub(1, 1) == 'i' then desc = desc:gsub(' with ws', '') end
                    ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
                end
            end
            require('which-key').add(ret, { notify = false })
        end,
    },

    -- Telescope: Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        event = 'VeryLazy',
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
                            ['<C-->'] = 'select_horizontal',
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

            -- Enable Telescope extensions if they are installed
            require('telescope').load_extension('fzf')
            require('telescope').load_extension('ui-select')

            -- Keymaps
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
            vim.keymap.set('n', '<Leader><Leader>', builtin.buffers, { desc = ' [ ] Telescope: Find Existing Buffers' })
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
                { desc = ' [/] Telescope: Fuzzy Search Current Buffer' }
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
        event = 'VeryLazy',
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
            vim.opt.foldlevel = 99
            vim.opt.foldlevelstart = 99
            vim.opt.foldtext = ''
            local configs = require('nvim-treesitter.configs')
            configs.setup(opts)
        end,
    },
    { 'nvim-treesitter/nvim-treesitter-textobjects', event = 'VeryLazy' },
    { 'nvim-treesitter/nvim-treesitter-context', event = 'VeryLazy' },

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
}
