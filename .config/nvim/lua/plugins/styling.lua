return {
  -- Themes
  { 'folke/tokyonight.nvim', priority = 1000, opts = { plugins = { auto = true } } },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      integrations = {
        -- Most common plugins enabled by default
        noice = true,
        which_key = true,
        mason = true,
      },
    },
  },

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
      vim.api.nvim_set_hl(0, 'DashboardHeader', { link = '@keyword' })
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
        callback = function() vim.opt.statusline=' ' end,
      })

      -- Lualine config
      require('lualine').setup({
        options = {
          icons = vim.g.have_nerd_font,
          theme = 'auto',
          section_separators = { left = '', right = '' },
          component_separators = { left = '󰇝', right = '󰇝' },
          disabled_filetypes = { winbar = { 'dap-repl' } },
        },
        extensions = { dapui },
        sections = {},
        inactive_sections = {},
        winbar = {
          lualine_a = { function() return string.upper(vim.api.nvim_get_mode().mode) end },
          lualine_b = {},
          lualine_c = { 'branch', 'diff', 'diagnostics', 'filename' },
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
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      cmdline = { enabled = true, view = 'cmdline_popup' },
      messages = { enabled = true },
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
        },
      },
      presets = { long_message_to_split = true },
    },
  },
}
