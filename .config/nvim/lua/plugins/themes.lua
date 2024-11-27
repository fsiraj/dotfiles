-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
return {
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
  },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
  },
}
