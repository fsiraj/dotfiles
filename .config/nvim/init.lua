-- Set <space> as the leader key
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Options ]]
require 'options'

-- [[ Keymaps ]]
require 'keymaps'

-- [[ Autocommands ]]
require 'autocommands'

-- [[ Plugins ]]
require 'lazy-plugins'

-- vim: ts=2 sts=2 sw=2 et
