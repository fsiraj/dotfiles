-- Collection of small convenience plugins with minimal configuration.
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

  -- Plugin to show pending keybinds.
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    keys = {
      {
        '<leader>?',
        function() require('which-key').show({ global = false }) end,
        desc = 'Buffer Local Keymaps (which-key)',
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
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' }, icon = { icon = ' ', color = 'orange' } },
        { '<leader>b', group = '[B]uffer', icon = { icon = '󰈔 ', color = 'cyan' } },
        { '<leader>d', group = '[D]ebug', icon = { icon = ' ', color = 'red' } },
        { '<leader>s', group = '[S]earch', icon = { icon = ' ', color = 'green' } },
        { '<leader>w', group = '[W]orkspace', icon = { icon = '󰈢 ', color = 'azure' } },
        { '<leader>t', group = '[T]oggle', icon = { icon = ' ', color = 'yellow' } },
        { '<leader>g', group = '[G]it', mode = { 'n', 'v' }, icon = { cat = 'filetype', name = 'git' } },
      },
    },
  },

  -- Nicer LSP messages and command line
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
    },
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

  -- Neo-tree is a Neovim plugin to browse the file system
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<Leader>tn', ':Neotree toggle<CR>', desc = '[T]oggle [N]eotree', silent = true },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          never_show = { '.git' },
        },
      },
    },
  },

  -- Session management
  {
    'rmagatti/auto-session',
    lazy = false,
    keys = {
      { '<leader>wr', '<cmd>SessionSearch<CR>', desc = '[W]orkspace [R]estore' },
    },
    opts = {
      suppressed_dirs = { '~/', '~/Downloads', '/' },
      pre_save_cmds = { 'Neotree close' },
      session_lens = { mappings = { delete_session = { 'i', '<C-x>' } } },
    },
  },

  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      require('ibl').setup()
      vim.keymap.set('n', '<leader>ti', ':IBLToggle<CR>', { desc = '[T]oggle [I]ndent blank lines' })
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
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/noice.nvim' },
    config = function()
      local noice = require('noice')
      require('lualine').setup({
        options = {
          icons = vim.g.have_nerd_font,
          theme = 'catppuccin',
          section_separators = { left = '', right = '' },
          component_separators = { left = '|', right = '|' },
        },
        extensions = { 'neo-tree', 'nvim-dap-ui' },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = {
            { noice.api.status.mode.get, cond = noice.api.status.mode.has }, ---@diagnostic disable-line
            { noice.api.status.command.get, cond = noice.api.status.command.has }, ---@diagnostic disable-line
            'filetype',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      })
    end,
  },
  -- Render markdown nicely
  {
    'MeanderingProgrammer/render-markdown.nvim',
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
      vim.keymap.set('n', '<Leader>tp', ':MarkdownPreviewToggle<CR>', { desc = '[T]oggle Markdown [P]review' })
    end,
  },
}
