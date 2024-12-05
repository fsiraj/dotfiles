-- Set before loading plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.g.disable_autoformat = false

-- [[ Options ]]
require('options')

-- [[ Keymaps ]]
require('keymaps')

-- [[ Autocommands ]]
require('autocommands')

-- [[ Plugins ]]
require('lazy-plugins')

-- [[ Theme ]]
vim.cmd.colorscheme('catppuccin-mocha')
vim.cmd.hi('Comment gui=none')
