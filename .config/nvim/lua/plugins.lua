-- Language support
local treesitter_parsers = {
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
}

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
    -- Bash
    bashls = {
        filetypes = { 'bash', 'sh' },
    },
    -- Markdown
    marksman = {},
    -- TOML
    taplo = {},
}

local formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
    markdown = { 'markdownlint' },
    zsh = { 'shfmt', 'shellcheck' },
    sh = { 'shfmt', 'shellcheck' },
}

local linters_by_ft = {
    json = { 'jsonlint' },
    markdown = { 'markdownlint' },
}

-- Add tools here that you want Mason to install
local ensure_installed = vim.tbl_keys(language_servers or {})
vim.list_extend(ensure_installed, {
    'stylua',
    'ruff',
    'debugpy',
    'markdownlint',
    'jsonlint',
    'shellcheck',
    'shfmt',
})

local dashboard_header = {
    '                                                                                   ',
    '                                        ▒▓▓▓▓▒▒                                    ',
    '                                    ▒   ▓▓▓▓▓▓▒▒▓▒                                 ',
    '                               ▒  ▒▓   ▒▓▓▓▓▓▓▓▓▒▓▓                                ',
    '                              ▓▒  ▓▓   ▒▒▒▒▓▓▓▓▓▒▓▓▓                               ',
    '                              ▓▒  ▒  ▒▒▓▓▓▓▒▓▓▓▓▓▓▓▓▒                              ',
    '     .:                      ▒▓▒  ▒▒▒   ▒▒▒▒▒▓▓▓▓▓▓▓▓                       :.     ',
    '   -%#*:                     ▓▓ ▒▒ ▒▒▓▓▓▓▓▓▓▓▓▒▒▓▓▓▓▓▒                     :*#%=   ',
    '   @+                       ▒▒   ▒▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▓                        +@.  ',
    '   @*                         ▒▒▒▓▓▓▓▓▓▓▓         ▒▒▒▒▓                       +@.  ',
    '   #%                        ▓▓▒ ▒▒▒▒▓▓▓▓       ▒  ▓▓▒▓▒                      %%   ',
    '   *@                      ▒▓▓▓▒  ▓▓▓▒▒ ▓  ▒▒▓▓▓▓  ▓▓▓▒▓                      @*   ',
    '   %%                      ▓▓▓▓ ▒▓▒▓▓▓▒▒▓    ▒▒    ▓▓▓▓▒▒                     #%   ',
    ':#@#                       ▓▓▓▓▒▒▓▓▓▓▓▓▓▓       ▒▒▒▓▓▓▓▒▒                      #@#:',
    ' .=@=                       ▓▓▓▓▒▒▒▒▓▓▓▓▓      ▒▒▓▓▓▓ ▒▓                      =@=: ',
    '   *@                        ▓▓▓▓▓▒ ▒▓▓▓▓▓     ▒▓▓▓▓  ▒                       @*   ',
    '   *@                          ▓▓▓▒  ▓▓▓▒      ▒▓▓▓  ▓▒                       @#   ',
    '   @#                  ▒▒▓▓▓▒   ▒▓▓▓▒ ▒▓▓▒   ▒▓▓▓▒ ▒▒▓▓▓▓▒▒                   *@   ',
    '  .@+                ▓▓▓▓▓▓▓▓▓ ▒ ▒▓▓▓▓ ▒▓   ▓▒▓▓▒▒▓▒▓▓▓▓▓▓▓▓▓                 =@.  ',
    '   %#.                 ▒▒▓▓▓▓▓▓▒▒▒ ▓▓▒▒▓▓▓▓▓▓▒▓▒▓▒▒▓▓▓▓▓▓▓▒                  .#%   ',
    '    =*#:                   ▒▓▓▓▓▒▒▒ ▓▒▒▓▓▓ ▓▒▒▒▓▒▓▓▓▓▓▓▒                   :#*=    ',
    '                              ▒▒▓▒ ▒▒▒ ▓▒▒ ▓▒▒▓▒▓▓▓▒                               ',
    '                                 ▒  ▒▒ ▒▒  ▓▒▒ ▓▒                                  ',
    '                                    ▒▒ ▒   ▒▒                                      ',
    '                                     ▒                                             ',
    '                                                                                   ',
}

local textobjects = {
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

-- To make UIs multiples of 50
local unit_width = 50

local M = {
    -- NOTE: Essentials

    --Mini
    {
        'echasnovski/mini.nvim',
        event = 'VeryLazy',
        config = function()
            -- Enhanced jump motions
            require('mini.jump').setup()
            require('mini.jump2d').setup({ view = { n_steps_ahead = 1 } })
            vim.keymap.set(
                'n',
                '<CR>',
                '<Cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character)<CR>',
                { desc = 'Jump 2D' }
            )

            -- Better Around/Inside textobjects
            local ai = require('mini.ai')
            ai.setup({
                n_lines = 500,
                custom_textobjects = {
                    -- NOTE: The textobjects below are manually added to WhichKey
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
            })
            vim.keymap.set(
                'n',
                '<Leader>gd',
                MiniDiff.toggle_overlay,
                { desc = 'Toggle Git Overlay' }
            )

            -- Session management
            local sessions = require('mini.sessions')
            sessions.setup({
                hooks = {
                    post = {
                        read = function()
                            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                                -- Targetting dead CodeCompanion buffers
                                if
                                    string.match(vim.api.nvim_buf_get_name(buf), 'CodeCompanion')
                                then
                                    vim.api.nvim_buf_delete(buf, {})
                                    vim.cmd('CodeCompanionChat Toggle')
                                    vim.cmd('wincmd =')
                                end
                            end
                        end,
                    },
                },
            })
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
            preset = 'modern',
            win = { width = { max = unit_width * 3 } },
            triggers = {
                { '<auto>', mode = 'nixsotc' },
                { 's', mode = { 'n', 'v' } },
            },
            icons = {
                mappings = vim.g.have_nerd_font,
                keys = {},
            },
            spec = {
                {
                    '<Leader>i',
                    group = '[I]nfo',
                    icon = { icon = ' ', color = 'cyan' },
                },
                {
                    '<Leader>c',
                    group = '[C]ode',
                    mode = { 'n', 'x' },
                    icon = { icon = ' ', color = 'orange' },
                },
                {
                    '<Leader>d',
                    group = '[D]ebug',
                    icon = { icon = ' ', color = 'red' },
                },
                {
                    '<Leader>s',
                    group = '[S]earch',
                    icon = { icon = ' ', color = 'green' },
                },
                {
                    '<Leader>S',
                    group = '[S]essions',
                    icon = { icon = '󰙰 ', color = 'purple' },
                },
                {
                    '<Leader>f',
                    group = '[F]',
                    icon = { icon = '󰈢 ', color = 'azure' },
                },
                {
                    '<Leader>t',
                    group = '[T]oggle',
                    icon = { icon = ' ', color = 'yellow' },
                },
                {
                    '<Leader>g',
                    group = '[G]it',
                    mode = { 'n', 'v' },
                    icon = { cat = 'filetype', name = 'git' },
                },
                {
                    '<Leader>n',
                    group = '[N]eotest',
                    icon = { icon = ' ', color = 'azure' },
                },
            },
        },
        config = function(_, opts)
            require('which-key').setup(opts)

            local ret = { mode = { 'o', 'x' } }
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
                for _, obj in ipairs(textobjects) do
                    local desc = obj.desc
                    if prefix:sub(1, 1) == 'i' then desc = desc:gsub(' with ws', '') end
                    ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
                end
            end

            require('which-key').add(ret, { notify = false })
        end,
    },

    --Telescope
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
            { 'nvim-tree/nvim-web-devicons' },
        },
        config = function()
            require('telescope').setup({
                defaults = {
                    layout_strategy = 'horizontal',
                    sorting_strategy = 'ascending',
                    layout_config = {
                        horizontal = {
                            prompt_position = 'top',
                            preview_width = 0.6,
                            width = math.min(unit_width * 3, math.floor(0.8 * vim.o.columns)),
                        },
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
                    buffers = {
                        previewer = false,
                        layout_config = { width = unit_width, height = 16 },
                        path_display = { 'tail' },
                    },
                    live_grep = { path_display = { 'tail' } },
                    help_tags = {
                        mappings = { i = { ['<CR>'] = 'select_vertical' } },
                    },
                    colorscheme = { enable_preview = true },
                    lsp_references = { path_display = { 'tail' } },
                    current_buffer_fuzzy_find = { previewer = false },
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
            vim.keymap.set(
                'n',
                '<Leader>sh',
                builtin.help_tags,
                { desc = 'Telescope: [S]earch [H]elp' }
            )
            vim.keymap.set(
                'n',
                '<Leader>sH',
                builtin.highlights,
                { desc = 'Telescope: [S]earch [H]ighlights' }
            )
            vim.keymap.set(
                'n',
                '<Leader>sk',
                builtin.keymaps,
                { desc = 'Telescope: [S]earch [K]eymaps' }
            )
            vim.keymap.set(
                'n',
                '<Leader>sf',
                builtin.find_files,
                { desc = 'Telescope: [S]earch [F]iles' }
            )
            vim.keymap.set(
                'n',
                '<Leader>sb',
                builtin.builtin,
                { desc = 'Telescope: [S]earch [B]uiltin' }
            )
            vim.keymap.set(
                'n',
                '<Leader>sw',
                builtin.grep_string,
                { desc = 'Telescope: [S]earch Current [W]ord' }
            )
            vim.keymap.set(
                'n',
                '<Leader>sg',
                builtin.live_grep,
                { desc = 'Telescope: [S]earch by [G]rep' }
            )
            vim.keymap.set(
                'n',
                '<Leader>sq',
                builtin.diagnostics,
                { desc = 'Telescope: [S]earch [Q]uickfix' }
            )
            vim.keymap.set(
                'n',
                '<Leader>sr',
                builtin.resume,
                { desc = 'Telescope: [S]earch [R]esume' }
            )
            vim.keymap.set(
                'n',
                '<Leader><Leader>',
                builtin.buffers,
                { desc = ' [ ] Telescope: Find Existing Buffers' }
            )
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

    --Treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        event = 'VeryLazy',
        build = ':TSUpdate',
        main = 'nvim-treesitter.configs',
        opts = {
            ensure_installed = treesitter_parsers,
            auto_install = true,
            highlight = {
                enable = true,
            },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = false,
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
    { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

    --VimSleuth
    { 'tpope/vim-sleuth' },

    -- NOTE: Styling

    --Catppuccin
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        opts = {
            flavor = 'mocha',
            custom_highlights = function(colors)
                local mauve = colors.mauve
                local mantle = colors.mantle
                local base = colors.base
                return {
                    FloatTitle = { fg = mantle, bg = mauve, bold = true },
                    FloatBorder = { fg = mantle, bg = mantle },
                    Pmenu = { link = 'NormalFloat' },
                    CursorLineNr = { fg = mauve },
                    StatusLine = { fg = base, bg = base },
                    StatusLineNC = { fg = base, bg = base },
                }
            end,
            default_integrations = true,
            integrations = {
                -- Most common plugins enabled by default
                noice = true,
                which_key = true,
                mason = true,
                blink_cmp = true,
                neotest = true,
                diffview = true,
                notify = true,
            },
        },
    },

    --Tokyonight
    {
        'folke/tokyonight.nvim',
        priority = 1000,
        opts = { plugins = { auto = true } },
    },

    --TinyDeviconsAutoColors
    {
        'rachartier/tiny-devicons-auto-colors.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        event = 'VeryLazy',
        config = function() require('tiny-devicons-auto-colors').setup() end,
    },

    -- Dashboard
    {
        'nvimdev/dashboard-nvim',
        event = 'VimEnter',
        config = function()
            require('dashboard').setup({
                theme = 'hyper',
                config = {
                    header = dashboard_header,
                    shortcut = {},
                    project = { enable = true, limit = 3 },
                    mru = { enable = true, limit = 5 },
                    footer = {},
                },
            })

            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'dashboard',
                callback = function()
                    local winid = vim.api.nvim_get_current_win()
                    vim.wo[winid][0].winhighlight = 'Normal:NormalFloat'
                end,
            })
        end,
        dependencies = { 'nvim-tree/nvim-web-devicons' },
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
            local tabs = {
                'tabs',
                cond = function() return #vim.fn.gettabinfo() > 1 end,
                show_modified_status = true,
            }
            local showmode = { noice.api.status.mode.get, cond = noice.api.status.mode.has } ---@diagnostic disable-line
            local showcmd = {
                noice.api.status.command.get, ---@diagnostic disable-line
                cond = noice.api.status.command.has, ---@diagnostic disable-line
            } ---@diagnostic disable-line

            -- Minimal
            local minimal = {
                winbar = {
                    lualine_a = { 'filetype' },
                    lualine_b = { tabs },
                    lualine_x = { showcmd },
                },
                inactive_winbar = { lualine_c = { 'filetype' } },
                filetypes = {
                    'codecompanion',
                    'Outline',
                    'DiffviewFiles',
                    'dap-view-term',
                    'neotest-summary',
                },
            }

            -- Terminal (No filetype)
            local terminal = {
                winbar = { lualine_a = { mode }, lualine_x = { showcmd } },
                inactive_winbar = { lualine_a = { mode } },
                filetypes = { '' },
            }

            -- Lualine config
            require('lualine').setup({
                options = {
                    icons = vim.g.have_nerd_font,
                    theme = 'auto',
                    section_separators = { left = '', right = '' },
                    component_separators = { left = '󰇝', right = '󰇝' },
                    disabled_filetypes = {
                        winbar = { 'dap-repl', 'dap-view', 'dashboard', 'toggleterm' },
                    },
                },
                extensions = { minimal, terminal },
                sections = {},
                inactive_sections = {},
                winbar = {
                    lualine_a = { mode, 'filename' },
                    lualine_b = { tabs },
                    lualine_c = { 'branch', 'diff', 'diagnostics' },
                    lualine_x = { showmode, showcmd, 'filetype', 'location' },
                    lualine_y = {},
                    lualine_z = {},
                },
                inactive_winbar = {
                    lualine_a = { 'filename' },
                },
            })
        end,
    },

    --Noice
    {
        'folke/noice.nvim',
        event = 'VeryLazy',
        dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
        opts = {
            cmdline = {
                enabled = true,
                format = {},
            },
            messages = { enabled = true },
            popupmenu = { enabled = true },
            lsp = {
                hover = { enabled = true },
                signature = { enabled = true },
                override = {
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                    ['vim.lsp.util.stylize_markdown'] = true,
                },
            },
            views = {
                cmdline_popup = {
                    size = { width = unit_width, max_width = unit_width },
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
            },
        },
        config = function(_, opts)
            require('notify').setup({
                render = 'wrapped-compact',
                stages = 'static',
                minimum_width = unit_width,
                max_width = unit_width,
            })
            for format, _ in pairs(require('noice.config').defaults().cmdline.format) do
                opts.cmdline.format[format] = { conceal = false }
            end
            require('noice').setup(opts)
        end,
    },

    --NOTE: Extras

    --Neogit
    {
        'NeogitOrg/neogit',
        keys = {
            { '<Leader>N', '<Cmd>Neogit<CR>', desc = ' [N]eogit: Git' },
        },
        dependencies = {
            'nvim-lua/plenary.nvim',
            'sindrets/diffview.nvim',
            'nvim-telescope/telescope.nvim',
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
                view = {
                    ['q'] = '<Cmd>DiffviewClose<CR>',
                },
                file_panel = {
                    ['q'] = '<Cmd>DiffviewClose<CR>',
                },
            },
        },
    },

    --Copilot
    {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        build = ':Copilot auth',
        event = 'InsertEnter',
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
            server = { type = 'binary' }
        },
    },

    --Codecompanion
    {
        'olimorris/codecompanion.nvim',
        event = 'VeryLazy',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-treesitter/nvim-treesitter',
            'echasnovski/mini.diff',
        },
        opts = {
            adapters = {
                copilot = function()
                    return require('codecompanion.adapters').extend('copilot', {
                        schema = { model = { default = 'claude-3.7-sonnet' } },
                    })
                end,
            },
            display = {
                diff = { provider = 'mini_diff' },
                chat = { show_header_separator = false, auto_scroll = false, show_settings = true },
            },
        },
        config = function(_, opts)
            require('codecompanion').setup(opts)
            vim.keymap.set('ca', 'cc', 'CodeCompanion')
            vim.keymap.set(
                { 'n', 'v' },
                '<Leader>cc',
                '<Cmd>CodeCompanionChat Toggle<CR><C-w>=',
                { desc = 'Toggle [C]ode [C]ompanion chat' }
            )
        end,
    },

    --Toggleterm
    {
        'akinsho/toggleterm.nvim',
        version = '*',
        keys = {
            {
                '<Bslash>',
                '<Cmd>ToggleTerm name=Terminal<CR>',
                mode = 'n',
                desc = 'Open Terminal',
            },
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
                    vim.keymap.set(
                        'n',
                        'q',
                        '<Cmd>ToggleTerm<CR>',
                        { buffer = true, desc = '[T]oggle [T]erm' }
                    )
                    vim.keymap.set(
                        { 't', 'n' },
                        '<Bslash>',
                        '<Cmd>ToggleTerm<CR>',
                        { buffer = true, desc = '[T]oggle [T]erm' }
                    )
                end,
            })
        end,
    },

    --Oil
    {
        'stevearc/oil.nvim',
        keys = {
            {
                '<Leader>fs',
                function() require('oil').open_float() end,
                mode = { 'n' },
                desc = '[F]ile [S]ystem',
            },
        },
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            view_options = { show_hidden = true },
            float = { max_width = 0.4, max_height = 0.8 },
            keymaps = {
                ['q'] = { 'actions.close' },
                ['<C-h>'] = { 'actions.show_help' },
                ['<C-->'] = { 'actions.select', opts = { horizontal = true } },
                ['<C-Bslash>'] = {
                    'actions.select',
                    opts = { vertical = true },
                },
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
                    if
                        vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry()
                    then
                        oil.open_preview()
                    end
                end),
            })
        end,
    },

    --Outline
    {
        'hedyhli/outline.nvim',
        cmd = { 'Outline', 'OutlineOpen' },
        keys = {
            { '<leader>fo', '<cmd>Outline<CR>', desc = '[F]ile [O]utline' },
        },
        opts = {
            outline_window = {
                split_command = unit_width .. 'vsplit',
                winhl = 'Normal:NormalFloat',
                auto_close = true,
            },
            outline_items = { show_symbol_details = true },
            preview_window = { winhl = 'NormalFloat:NormalFloat' },
        },
    },

    --TodoComments
    {
        'folke/todo-comments.nvim',
        event = 'VeryLazy',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false },
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

    -- NOTE: Language Tools

    --Lspconfig
    {
        'neovim/nvim-lspconfig',
        event = 'VeryLazy',
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
                        vim.keymap.set(
                            mode,
                            keys,
                            func,
                            { buffer = event.buf, desc = 'LSP: ' .. desc }
                        )
                    end
                    map('<Leader>cd', telescope.lsp_definitions, '[C]ode [D]efinition')
                    map('<Leader>cD', vim.lsp.buf.declaration, '[C]ode [D]eclaration')
                    map('<Leader>cr', telescope.lsp_references, '[C]ode [R]eferences')
                    map('<Leader>ci', telescope.lsp_implementations, '[C]ode [I]mplementation')
                    map('<Leader>ct', telescope.lsp_type_definitions, '[C]ode [T]ype Definition')
                    map('<Leader>cs', telescope.lsp_document_symbols, '[C]ode [S]ymbols Buffer')
                    map('<Leader>cS', telescope.lsp_workspace_symbols, '[C]ode [S]ymbols Workspace')
                    map('<Leader>cv', vim.lsp.buf.rename, '[C]ode [V]ariable Rename')
                    map('<Leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
                    map('<Leader>cq', vim.diagnostic.setloclist, '[C]ode [Q]uickfix List')
                    map(
                        '<Leader>ck',
                        vim.diagnostic.open_float,
                        '[C]ode Diagnotic Float ([K]eywordprog)'
                    )
                    -- <Leader>cf = [C]ode [F]ormat (Conform)
                    -- <Leader>cc = [C]ode [C]ompanion Chat (Codecompanion)

                    -- Highliht references on hover
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

                    -- If LSP supports inlay hints, enable them
                    if
                        client
                        and client:supports_method(
                            vim.lsp.protocol.Methods.textDocument_inlayHint,
                            event.buf
                        )
                    then
                        map('<Leader>ti', function()
                            local is_enabled = vim.lsp.inlay_hint.is_enabled({
                                bufnr = event.buf,
                            })
                            vim.lsp.inlay_hint.enable(not is_enabled)
                            vim.print('Inlay Hints: ' .. tostring(not is_enabled))
                        end, '[T]oggle [I]nlay Hints')
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

            -- Toggle diagnostic information
            vim.keymap.set(
                'n',
                '<Leader>td',
                function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
                { desc = 'LSP: [T]oggle [D]iagnostics' }
            )

            -- Mason installs external tools
            require('mason').setup()
            vim.keymap.set('n', '<Leader>im', '<Cmd>Mason<CR>', { desc = '[M]ason' })

            require('mason-tool-installer').setup({
                ensure_installed = ensure_installed,
            })
            require('mason-lspconfig').setup({
                handlers = {
                    function(server_name)
                        local server_config = language_servers[server_name] or {}
                        -- Adds additional capabilities from blink.cmp
                        server_config.capabilities =
                            require('blink.cmp').get_lsp_capabilities(server_config.capabilities)
                        require('lspconfig')[server_name].setup(server_config)
                    end,
                },
            })
        end,
    },

    --Blink
    {
        'saghen/blink.cmp',
        event = 'VeryLazy',
        dependencies = {
            { 'saghen/blink.compat', version = '*', opts = {} },
            'rafamadriz/friendly-snippets',
            'fang2hou/blink-copilot',
            'rcarriga/cmp-dap',
        },
        version = '*',
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            cmdline = {
                enabled = true,
                keymap = { preset = 'cmdline', ['<CR>'] = { 'accept', 'fallback' } },
                completion = { ghost_text = { enabled = false } },
            },
            enabled = function()
                local disabled_filetypes = { 'oil', 'gitcommit' }
                return not vim.tbl_contains(disabled_filetypes, vim.bo.filetype)
                    and (vim.bo.buftype ~= 'prompt' or require('cmp_dap').is_dap_buffer())
            end,
            completion = {
                menu = {
                    auto_show = function(ctx) return ctx.mode ~= 'cmdline' end,
                    draw = { components = { label = { width = { max = unit_width / 2 } } } },
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
                kind_icons = {
                    Copilot = '',
                },
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
                        module = 'blink-copilot',
                        async = true,
                        opts = {
                            max_completions = 1,
                            max_attempts = 2,
                        },
                        score_offset = -10,
                    },
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
                desc = '[C]ode [F]ormat Buffer/Selection',
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
                vim.print('Format On Save: ' .. tostring(vim.g.format_on_save))
            end, { desc = '[T]oggle [F]ormat On Save' })
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
            vim.keymap.set(
                'n',
                '<Leader>nr',
                function() neotest.run.run() end,
                { desc = '[N]eotest [R]un' }
            )
            vim.keymap.set(
                'n',
                '<Leader>nl',
                function() neotest.run.run_last() end,
                { desc = '[N]eotest Run [L]ast' }
            )
            vim.keymap.set(
                'n',
                '<Leader>nf',
                function() neotest.run.run(vim.fn.expand('%')) end,
                { desc = '[N]eotest Run [F]ile' }
            )
            vim.keymap.set(
                'n',
                '<Leader>na',
                function() neotest.run.run({ suite = true }) end,
                { desc = '[N]eotest Run [A]ll' }
            )
            vim.keymap.set(
                'n',
                '<Leader>nw',
                function() neotest.watch.toggle() end,
                { desc = '[N]eotest [W]atch' }
            )
            vim.keymap.set(
                'n',
                '<Leader>no',
                function() neotest.output.open({ enter = true }) end,
                { desc = '[N]eotest [O]utput' }
            )
            vim.keymap.set('n', '<Leader>ns', function()
                neotest.summary.toggle()
                vim.cmd('wincmd =')
            end, { desc = '[N]eotest [S]ummary' })
            vim.keymap.set(
                'n',
                ']n',
                function() neotest.jump.next({ status = 'failed' }) end,
                { desc = '[N]eotest [N]ext' }
            )
            vim.keymap.set(
                'n',
                '[n',
                function() neotest.jump.prev({ status = 'failed' }) end,
                { desc = '[N]eotest [P]revious' }
            )

            -- Window highlight and close window keymap
            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'neotest-summary',
                callback = function() vim.wo.winhl = 'Normal:NormalFloat' end,
            })
            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'neotest-output',
                callback = function()
                    vim.keymap.set(
                        'n',
                        'q',
                        '<Cmd>:q<CR>',
                        { buffer = true, desc = 'Close Window' }
                    )
                end,
            })
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
                display = { 'Classic', 'VirtualText' },
                selected_interpreters = { 'Python3_fifo', 'Lua_nvim' },
                repl_enable = { 'Python3_fifo' },
            })
            vim.keymap.set({ 'n', 'v' }, '<Leader>r', '<Plug>SnipRun', { desc = ' [R]un Code' })
        end,
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
    { 'Bilal2453/luvit-meta', lazy = true },

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
                icons = { '󰉫 : ', '󰉬 : ', '󰉭 : ', '󰉮 : ', '󰉯 : ', '󰉰 : ' },
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

    --Dap
    {
        'mfussenegger/nvim-dap',
        event = 'VeryLazy',
        dependencies = {
            -- UI
            'igorlfs/nvim-dap-view',
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
            vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
            vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
            vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
            vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
            vim.keymap.set('n', '<F4>', dap.run_to_cursor, { desc = 'Debug: Run to cursor' })

            vim.keymap.set(
                'n',
                '<Leader>db',
                dap.toggle_breakpoint,
                { desc = '[D]ebug [B]reakpoint Toggle ' }
            )
            vim.keymap.set(
                'n',
                '<Leader>dc',
                dap.continue,
                { desc = '[D]ebug [C]ontinue Session.' }
            )
            vim.keymap.set(
                'n',
                '<Leader>dt',
                dap.terminate,
                { desc = '[D]ebug [T]erminate Session.' }
            )
            vim.keymap.set('n', '<Leader>dr', dap.restart, { desc = '[D]ebug [R]estart Session.' })
            vim.keymap.set('n', '<Leader>dv', dv.toggle, { desc = '[D]ebug [V]iew Toggle ' })

            vim.keymap.set(
                'n',
                '<Leader>ds',
                function() widgets.centered_float(widgets.scopes) end,
                { desc = '[D]ebug [S]cope' }
            )
            vim.keymap.set(
                'n',
                '<Leader>dk',
                function() widgets.hover(nil, { border = 'none' }) end,
                { desc = '[D]ebug Symbol ([K]eywordprog)' }
            )

            vim.api.nvim_create_autocmd('FileType', {
                pattern = { 'dap-float' },
                callback = function(event)
                    vim.keymap.set('n', 'q', '<C-w>q', { silent = true, buffer = event.buf })
                end,
            })

            -- Installs all dependencies with mason
            require('mason-nvim-dap').setup({
                automatic_installation = true,
                handlers = {},
                ensure_installed = {
                    'python',
                },
            })

            -- Dap setup
            dap.defaults.fallback.switchbuf = 'useopen'
            local repl = require('dap.repl')
            repl.commands = vim.tbl_extend('force', repl.commands, {
                help = { '.h', '.help' },
                into = { '.i', '.into' },
                next_ = { '.o', '.over' },
                out = { '.out' },
                exit = {},
                custom_commands = {
                    ['.restart'] = dap.restart,
                    ['.terminate'] = dap.terminate,
                },
            })

            -- Dap View setup
            vim.api.nvim_create_autocmd('FileType', {
                pattern = { 'dap-view', 'dap-repl' },
                callback = function() vim.wo.winhl = 'Normal:NormalFloat' end,
            })

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
                vim.fn.stdpath('data'), ---@diagnostic disable-line
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

-- Override plugin colors using colorscheme
local color_overrides = function(accent, mantle, palette)
    local theme = {}
    theme = vim.tbl_extend('error', {
        DashboardHeader = { fg = accent },
        DashboardMruTitle = { link = 'DashboardDesc' },
        DashboardProjectTitle = { link = 'DashboardDesc' },
        DashboardFiles = { link = 'NormalFloat' },
    }, theme)
    theme = vim.tbl_extend('error', theme, {
        TelescopePromptTitle = { bg = accent, fg = mantle },
        TelescopeResultsTitle = { fg = mantle },
        TelescopePreviewTitle = { bg = palette.green, fg = mantle },
        TelescopePromptPrefix = { bg = mantle, fg = accent },
    })
    for _, section in ipairs({ 'Prompt', 'Results', 'Preview' }) do
        theme['Telescope' .. section .. 'Normal'] = { link = 'NormalFloat' }
    end
    for _, level in ipairs({ 'ERROR', 'WARN', 'INFO', 'DEBUG', 'TRACE' }) do
        theme['Notify' .. level .. 'Body'] = { link = 'NormalFloat' }
        theme['Notify' .. level .. 'Border'] = { link = 'FloatBorder' }
    end
    theme = vim.tbl_extend('error', theme, {
        MiniJump = { bg = accent, fg = mantle, bold = true },
        MiniJump2dSpot = { link = 'MiniJump' },
        MiniJump2dSpotAhead = { link = 'MiniJump' },
        MiniJump2dSpotUnique = { link = 'MiniJump' },
    })
    theme.DapBreak = { fg = palette.red }
    theme.DapStop = { fg = palette.yellow }
    theme.NoiceCmdlinePopupTitleInput = { link = 'FloatTitle' }
    theme.WhichKeyDesc = { fg = accent }
    theme.TreesitterContextBottom = { sp = accent, underline = true }
    theme.SniprunVirtualTextOk = { bg = palette.green, fg = mantle }
    theme.SniprunVirtualTextErr = { bg = palette.red, fg = mantle }
    -- Apply themes
    for hl, col in pairs(theme) do
        vim.api.nvim_set_hl(0, hl, col)
    end
end

-- Run overrides when colorscheme enabled
vim.api.nvim_create_autocmd('Colorscheme', {
    pattern = 'catppuccin-mocha',
    callback = function()
        vim.api.nvim_create_autocmd('UIEnter', {
            desc = 'Override plugin themes with catppuccin',
            callback = function()
                local colors = require('catppuccin.palettes').get_palette('mocha')
                color_overrides(colors.mauve, colors.mantle, colors)
            end,
        })
    end,
})

return M
