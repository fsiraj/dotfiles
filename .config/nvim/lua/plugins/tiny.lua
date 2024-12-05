return {
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
    },
  },
  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
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
      -- If you want to automatically add `(` after selecting a function or method
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
  { -- Collection of various small independent plugins/modules
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
}
