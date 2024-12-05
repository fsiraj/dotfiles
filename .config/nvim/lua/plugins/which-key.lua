-- Useful plugin to show you pending keybinds.
return {
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
}
