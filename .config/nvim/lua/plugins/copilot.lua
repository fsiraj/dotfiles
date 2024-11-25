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
          keymap = {
            accept = '<C-h>',
            accept_word = '<C-l>',
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
      })
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim' },
    },
    keys = {
      { '<Leader>cc', mode = { 'n', 'v' }, desc = 'Toggle Inline [C]opilot [C]hat' },
      { '<Leader>cw', mode = { 'n', 'v' }, desc = 'Toggle Vertical [C]opilot [W]indow' },
    },
    build = 'make tiktoken',
    config = function()
      require('CopilotChat').setup({
        auto_insert_mode = true,
        mappings = {
          submit_prompt = { insert = '<CR>' },
          complete = { insert = '<CR>' },
          close = { normal = '<Esc>' },
        },
      })

      -- Toggle Floating Chat
      vim.keymap.set(
        { 'n', 'v' },
        '<Leader>cc',
        function() require('CopilotChat').toggle({ window = { layout = 'float' } }) end,
        { desc = 'Toggle Inline Copilot Chat' }
      )

      -- Toggle Tabbed Chat
      vim.keymap.set(
        { 'n', 'v' },
        '<Leader>cw',
        function() require('CopilotChat').toggle({ window = { layout = 'vertical' } }) end,
        { desc = 'Toggle Vertical Copilot Chat' }
      )
    end,
  },
}
