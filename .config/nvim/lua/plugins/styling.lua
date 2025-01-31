return {
    -- Themes
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        opts = {
            flavor = 'mocha',
            custom_highlights = function(colors)
                return {
                    FloatTitle = { fg = colors.mantle, bg = colors.mauve, bold = true },
                    FloatBorder = { fg = colors.mantle, bg = colors.mantle },
                    Pmenu = { link = 'NormalFloat' },
                }
            end,
            integrations = {
                -- Most common plugins enabled by default
                noice = true,
                which_key = true,
                mason = true,
                blink_cmp = true,
            },
        },
        config = function(_, opts)
            require('catppuccin').setup(opts)

            -- Customize other plugins with catppuccin
            local colors = require('catppuccin.palettes').get_palette('mocha')
            local mantle = colors.mantle
            local mauve = colors.mauve

            vim.api.nvim_create_autocmd('UIEnter', {
                desc = 'Override plugin themes with catppuccin',
                callback = function()
                    local theme = {}
                    -- Dashboard
                    theme = vim.tbl_extend('error', {
                        DashboardHeader = { fg = mauve },
                        DashboardMruTitle = { link = 'DashboardDesc' },
                        DashboardProjectTitle = { link = 'DashboardDesc' },
                        DashboardFiles = { link = 'NormalFloat' },
                    }, theme)
                    -- Telescope
                    theme = vim.tbl_extend('error', theme, {
                        TelescopePromptTitle = { bg = mauve, fg = mantle },
                        TelescopeResultsTitle = { fg = mantle },
                        TelescopePreviewTitle = { bg = colors.green, fg = mantle },
                        TelescopePromptPrefix = { bg = mantle, fg = mauve },
                        TelescopeMatching = { fg = colors.flamingo },
                    })
                    for _, section in ipairs({ 'Prompt', 'Results', 'Preview' }) do
                        theme['Telescope' .. section .. 'Normal'] = { link = 'NormalFloat' }
                    end
                    -- Notify
                    for _, level in ipairs({ 'ERROR', 'WARN', 'INFO', 'DEBUG', 'TRACE' }) do
                        theme['Notify' .. level .. 'Body'] = { link = 'NormalFloat' }
                        theme['Notify' .. level .. 'Border'] = { link = 'FloatBorder' }
                    end
                    -- Noice
                    theme.NoiceCmdlinePopupTitleInput = { link = 'FloatTitle' }
                    -- WhichKey
                    theme.WhichKeyDesc = { fg = mauve }
                    -- Treesitter
                    theme.TreesitterContextBottom = { sp = mauve, underline = true }
                    -- Apply themes
                    for hl, col in pairs(theme) do
                        vim.api.nvim_set_hl(0, hl, col)
                    end
                end,
            })
        end,
    },
    { 'folke/tokyonight.nvim', priority = 1000, opts = { plugins = { auto = true } } },

    -- Apply theme colors to dev icons
    {
        'rachartier/tiny-devicons-auto-colors.nvim',
        event = 'VeryLazy',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
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
                    header = {
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
                    },
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

    -- Status Line
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

            -- Custom behaviour for dapui windows
            local dapui = {
                winbar = require('lualine.extensions.nvim-dap-ui').sections,
                filetypes = require('lualine.extensions.nvim-dap-ui').filetypes,
            }
            vim.api.nvim_create_autocmd('FileType', {
                desc = 'Clear statusline for nvim-dap-ui buffers',
                group = vim.api.nvim_create_augroup('nvim-dap-ui', { clear = true }),
                pattern = 'dap*',
                callback = function() vim.opt.statusline = ' ' end,
            })

            -- Outline
            local outline = {
                winbar = { lualine_c = { 'filetype' } },
                filetypes = { 'Outline' },
            }

            -- Lualine config
            require('lualine').setup({
                options = {
                    icons = vim.g.have_nerd_font,
                    theme = 'auto',
                    section_separators = { left = '', right = '' },
                    component_separators = { left = '󰇝', right = '󰇝' },
                    disabled_filetypes = { winbar = { 'dap-repl', 'dashboard', 'toggleterm' } },
                },
                extensions = { dapui, outline },
                sections = {},
                inactive_sections = {},
                winbar = {
                    lualine_a = { function() return string.upper(vim.api.nvim_get_mode().mode) end, 'filename' },
                    lualine_b = {},
                    lualine_c = { 'branch', 'diff', 'diagnostics' },
                    lualine_x = {
                        { noice.api.status.mode.get, cond = noice.api.status.mode.has }, ---@diagnostic disable-line
                        { noice.api.status.command.get, cond = noice.api.status.command.has }, ---@diagnostic disable-line
                        'filetype',
                        'location',
                    },
                    lualine_y = {},
                    lualine_z = {},
                },
                inactive_winbar = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { 'filename' },
                    lualine_x = { 'location' },
                    lualine_y = {},
                    lualine_z = {},
                },
            })
        end,
    },

    -- Nicer LSP messages and command line
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
            presets = { long_message_to_split = true },
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
                    size = { max_width = 100 },
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
                minimum_width = 50,
                max_width = 50,
            })
            for format, _ in pairs(require('noice.config').defaults().cmdline.format) do
                opts.cmdline.format[format] = { conceal = false }
            end
            require('noice').setup(opts)
        end,
    },
}
