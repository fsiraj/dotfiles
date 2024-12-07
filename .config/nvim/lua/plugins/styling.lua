return {
  -- Themes
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
  { 'folke/tokyonight.nvim', priority = 1000 },

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
      vim.api.nvim_set_hl(0, 'DashboardHeader', { link = '@comment.note' })
      vim.api.nvim_set_hl(0, 'DashboardFooter', { link = '@constant' })
      vim.api.nvim_set_hl(0, 'DashboardFiles', { link = '@text' })
      vim.api.nvim_set_hl(0, 'DashboardShortcut', { link = '@string' })
      require('dashboard').setup({
        theme = 'hyper',
        config = {
          header = {
            '                                     .::                                     ',
            '                                .:. .=%%%#=:                                 ',
            '                              -=:=- -#%%%%##*=.                              ',
            '                            .=*:=*::*%%%%%%*#%=.                             ',
            '                            :*=:*=:-==**%%%%%%#-                             ',
            '                    =%=.=+**++**#%%%%%%=.                    ',
            '                          :*#=+==*%%%%%%#*#%%%#:                           ',
            '                          -*=-+%%%       ++*##%=.                          ',
            '                          -%#*==     -     ==*#%-                          ',
            '                         :*##%+*%*=:.-.:=*%*+%##*:                         ',
            '                        .=##%#-:=%%*:-:*%%=:-#%##=.                        ',
            '                        .=##%%*+=:.  -  .:=+*%%##=.                        ',
            '                         :*+*%%**-.  =  .-**%%*+*:                         ',
            '                          -*=*%%#=:::*:::=#%%*=*-                          ',
            '                       ..:=**=*%%=..:+:..=%%*=**=:.                        ',
            '                    .-*%%%%%%#**%%*:.=.:*%%**#%%%%%*=.                     ',
            '                    .=#%%%%%%%##*%%%***%%%*##%%%%%%#=.                     ',
            '                ..=#%%%%%##*%%%%%*##%%%%%#=.                 ',
            '                           .:*%*+*=****#***#%%*-.                            ',
            '                              .-=:=++==##*#*-.                               ',
            '                                 .=+======:.                                 ',
            '                                 .====-:::                                   ',
            '                                  :-::. ::                                   ',
            '                                     :.                                      ',
            '                                                                             ',
            '                                                                             ',
          },
          shortcut = {
            { desc = '󰦘 Update', group = '@type', action = 'Lazy update', key = 'u' },
            {
              desc = ' Files',
              group = 'Label',
              action = 'Telescope find_files',
              key = 'f',
            },
          },
          project = { enable = true, limit = 3 },
          mru = { enable = true, limit = 5 },
          footer = {
            '',
            '',
            "```  It's about how hard you can get hit and keep moving forward  ```",
          },
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
          theme = 'catppuccin',
          section_separators = { left = '', right = '' },
          component_separators = { left = '|', right = '|' },
        },
        extensions = { 'nvim-dap-ui' },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = {
            { noice.api.status.mode.get, cond = noice.api.status.mode.has }, ---@diagnostic disable-line
            { noice.api.status.command.get, cond = noice.api.status.command.has }, ---@diagnostic disable-line
            'filetype',
            'copilot',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
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
    },
    config = function(_, opts)
      require('noice').setup(opts)
      vim.keymap.set('ca', 'messages', 'NoiceAll')
    end,
  },
}
