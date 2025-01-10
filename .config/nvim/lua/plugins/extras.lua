-- Colletion of small convenience plugins with minimal configuration.

return {
  -- Plugin to show pending keybinds.
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    keys = {
      {
        '<Leader>?',
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
        { '<Leader>i', group = '[I]nfo', icon = { icon = ' ', color = 'cyan' } },
        {
          '<Leader>c',
          group = '[C]ode',
          mode = { 'n', 'x' },
          icon = { icon = ' ', color = 'orange' },
        },
        { '<Leader>b', group = '[B]uffer', icon = { icon = '󰈔 ', color = 'cyan' } },
        { '<Leader>d', group = '[D]ebug', icon = { icon = ' ', color = 'red' } },
        { '<Leader>s', group = '[S]earch', icon = { icon = ' ', color = 'green' } },
        { '<Leader>w', group = '[W]orkspace', icon = { icon = '󰈢 ', color = 'azure' } },
        { '<Leader>t', group = '[T]oggle', icon = { icon = ' ', color = 'yellow' } },
        {
          '<Leader>g',
          group = '[G]it',
          mode = { 'n', 'v' },
          icon = { cat = 'filetype', name = 'git' },
        },
      },
    },
  },

  -- Find and replace
  {
    keys = {
      {
        '<Leader>wf',
        ':GrugFar<CR>',
        mode = { 'n', 'v' },
        desc = '[W]orkspace [F]ind replace',
      },
    },
    'MagicDuck/grug-far.nvim',
    config = function() require('grug-far').setup({}) end,
  },

  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      require('ibl').setup({ exclude = { filetypes = { 'help', 'dashboard' } } })
      vim.keymap.set(
        'n',
        '<Leader>ti',
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
        view = { style = 'sign', signs = { add = '+', change = '~', delete = '-' }, priority = 5 },
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
