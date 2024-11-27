return { -- Add indentation guides even on blank lines
  'lukas-reineke/indent-blankline.nvim',
  -- Enable `lukas-reineke/indent-blankline.nvim`
  -- See `:help ibl`
  main = 'ibl',
  config = function()
    require('ibl').setup()
    vim.keymap.set('n', '<leader>ti', ':IBLToggle<CR>', { desc = '[T]oggle [I]ndent blank lines' })
  end,
}
