-- Collection of small convenience plugins with minimal configuration.

return {
  -- Themes
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
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
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' }, icon = { icon = ' ', color = 'azure' } },
        { '<leader>b', group = '[B]uffer', icon = { icon = '󰈔 ', color = 'cyan' } },
        { '<leader>d', group = '[D]ebug', icon = { icon = ' ', color = 'red' } },
        { '<leader>s', group = '[S]earch', icon = { icon = ' ', color = 'green' } },
        { '<leader>w', group = '[W]orkspace', icon = { icon = '󰈢 ', color = 'azure' } },
        { '<leader>t', group = '[T]oggle', icon = { icon = ' ', color = 'yellow' } },
        { '<leader>g', group = '[G]it', mode = { 'n', 'v' }, icon = { cat = 'filetype', name = 'git' } },
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
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
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
      { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          never_show = { '.git' },
        },
        window = {
          mappings = {
            ['\\'] = 'close_window',
          },
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

      -- Simple and easy statusline.
      require('mini.statusline').setup({ use_icons = vim.g.have_nerd_font })
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
      vim.keymap.set('n', '<Leader>tp', ':MarkdownPreviewToggle<CR>', { desc = 'Markdown [P]review: [T]oggle' })
    end,
  },
}
