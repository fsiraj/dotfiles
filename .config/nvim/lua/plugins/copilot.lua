return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = '<M-l>',
            accept_word = '<M-h>',
          },
        },
        panel = {
          enabled = true,
          keymap = {
            jump_prev = '[[',
            jump_next = ']]',
            accept = '<cr>',
            refresh = 'gr',
            open = '<m-cr>',
          },
          layout = {
            position = 'bottom',
            ratio = 0.4,
          },
        },
      }
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim' },
    },
    keys = {
      { '<C-i>', mode = { 'n', 'v' }, desc = 'Toggle Inline Copilot Chat' },
      { '<M-i>', mode = { 'n', 'v' }, desc = 'Toggle Vertical Copilot Chat' },
    },
    build = 'make tiktoken',
    config = function()
      require('CopilotChat').setup()

      -- Toggle Floating Chat
      vim.keymap.set({ 'n', 'v' }, '<C-i>', function()
        require('CopilotChat').toggle { window = { layout = 'float' } }
      end, { desc = 'Toggle Inline Copilot Chat' })

      -- Toggle Tabbed Chat
      vim.keymap.set({ 'n', 'v' }, '<M-i>', function()
        require('CopilotChat').toggle { window = { layout = 'vertical' } }
      end, { desc = 'Toggle Vertical Copilot Chat' })
    end,
  },
}
