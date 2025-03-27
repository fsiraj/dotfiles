-- NOTE: Options

-- Colorscheme
vim.g.colorscheme = 'catppuccin-mocha'

-- Set these before plugins are loaded
vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.have_nerd_font = true

-- Tabs and spaces
vim.g.tabstop = 4
vim.g.shiftwidth = 4
vim.g.expandtab = true

-- Enable relative line numbering
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode
vim.opt.mouse = 'a'

-- Lualine using winbar as status line
vim.opt.laststatus = 0
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 12

-- Disable tabline, shown with lualine instead
vim.opt.showtabline = 0

--NOTE: Keymaps

-- Buffer keymaps
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
vim.keymap.set('n', '<Leader>tb', '<Cmd>e #<CR>', { desc = '[T]oggle [B]uffer Alternative (#)' })
vim.keymap.set('n', '<C-\\>', '<Cmd>vsp<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<C-->', '<Cmd>sp<CR>', { desc = 'Horizontal split' })

-- Find Replace
vim.keymap.set('n', '<Leader>fr', ':%s/<C-r><C-w>/', { desc = '[F]ind [R]eplace Word' })
vim.keymap.set('v', '<Leader>fr', '"zy:%s/<C-r>z/', { desc = '[F]ind [R]eplace Selection' })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>')

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Easier pasting in insert mode
vim.keymap.set('i', '<C-p>', '<C-r>+', { desc = 'Paste from register +' })

-- Escape insert mode in terminal easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Normal Mode' })

-- Keymaps to scroll lsp hover and signature
vim.keymap.set({ 'n', 'i', 's' }, '<C-d>', function()
    if not require('noice.lsp').scroll(4) then return '10jzz' end
end, { silent = true, expr = true })
vim.keymap.set({ 'n', 'i', 's' }, '<C-u>', function()
    if not require('noice.lsp').scroll(-4) then return '10kzz' end
end, { silent = true, expr = true })

--NOTE: Autocommands

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.highlight.on_yank({ timeout = 300 }) end,
})

vim.api.nvim_create_autocmd('TermOpen', {
    desc = 'Set buffer local options for terminals',
    group = vim.api.nvim_create_augroup('terminal-options', { clear = true }),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
        local winid = vim.api.nvim_get_current_win()
        vim.wo[winid][0].winhighlight = 'Normal:NormalFloat'
        vim.keymap.set('n', 'cc', 'icc', { buffer = true, remap = true })
        vim.keymap.set('n', '<CR>', 'i', { buffer = true })
    end,
})

--NOTE: Plugins

-- Bootstrap lazy
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require('lazy').setup('plugins', {
    defaults = { version = nil },
})
vim.cmd.colorscheme(vim.g.colorscheme)
vim.keymap.set('n', '<Leader>il', '<Cmd>Lazy<CR>', { desc = '[L]azy' })
