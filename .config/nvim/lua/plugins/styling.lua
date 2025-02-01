-- Colorschemes
-- Dashboard
-- Lualine
-- Noice

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

local M = {
    -- Themes
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
            },
        },
    },
    { 'folke/tokyonight.nvim', priority = 1000, opts = { plugins = { auto = true } } },

    -- Apply theme colors to dev icons
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

            -- Custom components
            local mode = { function() return string.upper(vim.api.nvim_get_mode().mode) end }
            local tabs = {
                'tabs',
                cond = function() return #vim.fn.gettabinfo() > 1 end,
                show_modified_status = true,
            }
            local showmode = { noice.api.status.mode.get, cond = noice.api.status.mode.has } ---@diagnostic disable-line
            local showcmd = { noice.api.status.command.get, cond = noice.api.status.command.has } ---@diagnostic disable-line

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

            -- Outline and Diffview
            local side_panel = {
                winbar = { lualine_a = { 'filetype' }, lualine_b = { tabs }, lualine_x = { showcmd } },
                inactive_winbar = { lualine_c = { 'filetype' } },
                filetypes = { 'Outline', 'DiffviewFiles' },
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
                    disabled_filetypes = { winbar = { 'dap-repl', 'dashboard', 'toggleterm' } },
                },
                extensions = { dapui, side_panel, terminal },
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
                    size = { width = 60, max_width = 60 },
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
