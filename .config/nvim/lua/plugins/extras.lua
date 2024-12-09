-- Colletion of small convenience plugins with minimal configuration.
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
  {
    'rachartier/tiny-devicons-auto-colors.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    config = function() require('tiny-devicons-auto-colors').setup() end,
  },

  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      vim.api.nvim_set_hl(0, 'DashboardHeader', { link = '@conditional' })
      vim.api.nvim_set_hl(0, 'DashboardFooter', { link = '@error' })
      vim.api.nvim_set_hl(0, 'DashboardFiles', { link = '@text' })
      vim.api.nvim_set_hl(0, 'DashboardShortcut', { link = '@string' })
      require('dashboard').setup({
        theme = 'hyper',
        config = {
          header = {
            '                               .::                              ',
            '                          .:. .=%%%#=:                          ',
            '                        -=:=- -#%%%%##*=.                       ',
            '                      .=*:=*::*%%%%%%*#%=.                      ',
            '                      :*=:*=:-==**%%%%%%#-                      ',
            '                      =%=.=+**++**#%%%%%%=.                     ',
            '                     :*#=+==*%%%%%%#*#%%%#:                     ',
            '                     -*=-+%%%       ++*##%=.                    ',
            '                     -%#*==     -     ==*#%-                    ',
            '                    :*##%+*%*=:.-.:=*%*+%##*:                   ',
            '                   .=##%#-:=%%*:-:*%%=:-#%##=.                  ',
            '                   .=##%%*+=:.  -  .:=+*%%##=.                  ',
            '                    :*+*%%**-.  =  .-**%%*+*:                   ',
            '                     -*=*%%#=:::*:::=#%%*=*-                    ',
            '                  ..:=**=*%%=..:+:..=%%*=**=:.                  ',
            '               .-*%%%%%%#**%%*:.=.:*%%**#%%%%%*=.               ',
            '               .=#%%%%%%%##*%%%***%%%*##%%%%%%#=.               ',
            '                  ..=#%%%%%##*%%%%%*##%%%%%#=.                  ',
            '                     .:*%*+*=****#***#%%*-.                     ',
            '                        .-=:=++==##*#*-.                        ',
            '                           .=+======:.                          ',
            '                           .====-:::                            ',
            '                            :-::. ::                            ',
            '                               :.                               ',
            '                                                                ',
            '                                                                ',
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
            '"""  It\'s about how hard you can get hit and keep moving forward  """',
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

  -- Plugin to show pending keybinds.
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    keys = {
      {
        '<leader>?',
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
        {
          '<leader>c',
          group = '[C]ode',
          mode = { 'n', 'x' },
          icon = { icon = ' ', color = 'orange' },
        },
        { '<leader>b', group = '[B]uffer', icon = { icon = '󰈔 ', color = 'cyan' } },
        { '<leader>d', group = '[D]ebug', icon = { icon = ' ', color = 'red' } },
        { '<leader>s', group = '[S]earch', icon = { icon = ' ', color = 'green' } },
        { '<leader>w', group = '[W]orkspace', icon = { icon = '󰈢 ', color = 'azure' } },
        { '<leader>t', group = '[T]oggle', icon = { icon = ' ', color = 'yellow' } },
        {
          '<leader>g',
          group = '[G]it',
          mode = { 'n', 'v' },
          icon = { cat = 'filetype', name = 'git' },
        },
      },
    },
  },

  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      require('ibl').setup({ exclude = { filetypes = { 'help', 'dashboard' } } })
      vim.keymap.set(
        'n',
        '<leader>ti',
        ':IBLToggle<CR>',
        { desc = '[T]oggle [I]ndent blank lines' }
      )
    end,
  },

  -- Autopairs automatically adds matching parentheses, quotes, etc.
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    -- Optional dependency
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require('nvim-autopairs').setup({})
      -- Automatically add `(` after selecting a function or method
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

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
        view = { style = 'sign', signs = { add = '+', change = '~', delete = '-' } },
        mappings = {
          apply = '<Leader>ga',
          reset = '<Leader>gr',
          goto_prev = '<Leader>gp',
          goto_next = '<Leader>gn',
          goto_first = '<Leader>gg',
          goto_last = '<Leader>gG',
        },
      })
      vim.keymap.set(
        'n',
        '<Leader>tg',
        MiniDiff.toggle_overlay,
        { desc = '[T]oggle [G]it overlay' }
      )
    end,
  },

  -- Navigate between tmux and neovim seamlessly
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
    },
    keys = {
      { '<c-h>', '<cmd>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd>TmuxNavigateRight<cr>' },
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
      vim.keymap.set(
        'n',
        '<Leader>tp',
        ':MarkdownPreviewToggle<CR>',
        { desc = '[T]oggle Markdown [P]review' }
      )
    end,
  },
}
