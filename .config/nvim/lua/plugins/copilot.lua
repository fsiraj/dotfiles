return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    'olimorris/codecompanion.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'echasnovski/mini.diff',
    },
    opts = {
      display = { diff = { provider = 'mini_diff' }, chat = { show_header_separator = false } },
    },
    config = function(_, opts)
      require('codecompanion').setup(opts)
      vim.keymap.set('ca', 'cc', 'CodeCompanion')
      vim.keymap.set(
        { 'n', 'v' },
        '<Leader>cc',
        '<Cmd>CodeCompanionChat Toggle<CR>',
        { desc = 'Toggle [C]ode [C]ompanion chat' }
      )
    end,
  },
}
