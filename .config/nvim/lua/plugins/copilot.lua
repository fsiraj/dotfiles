return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = { accept = '<C-h>', accept_word = '<C-l>' },
        },
        panel = {
          enabled = true,
          keymap = { jump_prev = '[[', jump_next = ']]', accept = '<cr>', refresh = 'gr', open = '<m-cr>' },
          layout = { position = 'bottom', ratio = 0.4 },
        },
      })
    end,
  },
  {
    'olimorris/codecompanion.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.diff' },
    opts = {
      display = { diff = { provider = 'mini_diff' }, chat = { show_header_separator = false } },
    },
    config = function(_, opts)
      require('codecompanion').setup(opts)
      vim.keymap.set('ca', 'cc', 'CodeCompanion')
      vim.keymap.set({ 'n', 'v' }, '<Leader>cc', '<Cmd>CodeCompanionChat Toggle<CR>', { desc = 'Toggle [C]ode [C]ompanion chat' })
    end,
  },
}
