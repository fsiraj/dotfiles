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
            '                                                                                  ',
          },
          shortcut = {},
          project = { enable = true, limit = 3 },
          mru = { enable = true, limit = 5 },
          footer = {},
        },
      })
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
  },

  -- Status Line
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'folke/noice.nvim',
      'AndreM222/copilot-lualine',
    },
    config = function()
      local noice = require('noice')
      require('lualine').setup({
        options = {
          icons = vim.g.have_nerd_font,
          theme = 'auto',
          section_separators = { left = '', right = '' },
          component_separators = { left = '󰇝', right = '󰇝' },
        },
        extensions = { 'nvim-dap-ui' },
        sections = {
          lualine_a = { function() return string.upper(vim.api.nvim_get_mode().mode) end },
          lualine_b = {},
          lualine_c = { 'branch', 'diff', 'diagnostics', 'filename' },
          lualine_x = {
            { noice.api.status.mode.get, cond = noice.api.status.mode.has }, ---@diagnostic disable-line
            { noice.api.status.command.get, cond = noice.api.status.command.has }, ---@diagnostic disable-line
            'copilot',
            'filetype',
            'progress',
            'location',
          },
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
      messages = { enabled = true },
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      presets = { long_message_to_split = true },
    },
    config = function(_, opts)
      -- Reroute common messages to mini
      local keywords =
        { 'B written', 'change', 'fewer line', 'line less', 'more line', 'lines yanked' }
      opts.routes = {}
      for _, keyword in ipairs(keywords) do
        table.insert(opts.routes, {
          filter = {
            event = 'msg_show',
            kind = '',
            find = keyword,
          },
          view = 'mini',
        })
      end
      require('noice').setup(opts)
      vim.keymap.set('ca', 'messages', 'NoiceAll') -- Use :mes for nvim version
    end,
  },
}
