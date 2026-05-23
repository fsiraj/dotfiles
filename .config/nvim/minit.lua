-- Minimal init file to use with nvim -u minit.lua rather than nvim --clean

-- NOTE: Options
vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.opt.breakindent = true
vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'popup', 'fuzzy' }
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = {'number'}
vim.opt.expandtab = true
vim.opt.fillchars:append({ eob = ' ', fold = ' ' })
vim.opt.ignorecase = true
vim.opt.inccommand = 'split'
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 12
vim.opt.shiftwidth = 4
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 4
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)

-- NOTE: Keymaps
vim.keymap.set('n', 'ga', '<Cmd>e #<CR>', { desc = 'Toggle Buffer Alternative (#)' })
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>')
vim.keymap.set('i', '<M-Esc>', '<Esc>', { remap = true })
vim.keymap.set('t', '<C-]>', '<C-\\><C-n>', { desc = 'Terminal Normal Mode' })
vim.keymap.set('n', '<C-]>', '<Nop>')
vim.keymap.set('n', '<C-Bslash>', '<Cmd>vsp<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<C-->', '<Cmd>sp<CR>', { desc = 'Horizontal split' })
vim.keymap.set('n', '<C-_>', '<Cmd>sp<CR>', { desc = 'Horizontal split' })

-- Neovim/Tmux pane navigation
local function nav(wincmd_dir, tmux_dir)
   local prev = vim.api.nvim_get_current_win()
   vim.cmd('wincmd ' .. wincmd_dir)
   if prev == vim.api.nvim_get_current_win() and vim.env.TMUX then
      vim.fn.system({ 'tmux', 'select-pane', '-' .. tmux_dir })
   end
end

for _, dirs in ipairs({ { 'h', 'L' }, { 'j', 'D' }, { 'k', 'U' }, { 'l', 'R' } }) do
   local lhs = '<C-' .. dirs[1] .. '>'
   vim.keymap.set('n', lhs, function() nav(dirs[1], dirs[2]) end, { desc = 'Navigate ' .. dirs[1] })
   vim.keymap.set('t', lhs, function()
      vim.cmd('stopinsert')
      nav(dirs[1], dirs[2])
   end, { desc = 'Navigate ' .. dirs[1] })
end

-- NOTE: Theme
for _, group in ipairs({ 'Normal', 'NormalNC', 'SignColumn', 'EndOfBuffer', 'StatusLine', 'StatusLineNC' }) do
   vim.api.nvim_set_hl(0, group, { bg = 'none' })
end

-- NOTE: Statusline
vim.api.nvim_set_hl(0, 'StatusLineItem', { link = 'PMenu' })
local hl = function(s) return '%#StatusLineItem#' .. s .. '%*' end
vim.o.statusline = table.concat({
   hl(' %{toupper(mode())} '),
   hl("%{expand('%:~:.')}%m%r "),
   '%=',
   hl('%{%v:lua.vim.diagnostic.status()%}'),
   hl(' %y '),
})

-- NOTE: Plugins
local gh = function(x) return 'https://github.com/' .. x end
vim.pack.add({ gh('ibhagwan/fzf-lua'), gh('nvim-mini/mini.nvim'), gh('nmac427/guess-indent.nvim') })

--Fzflua
local fzf = require('fzf-lua')
fzf.setup({ 'borderless' })
vim.keymap.set('n', '<Leader>sf', fzf.files, { desc = 'Search Files' })
vim.keymap.set('n', '<Leader>sh', fzf.help_tags, { desc = 'Search Help' })
vim.keymap.set('n', '<Leader>sb', fzf.builtin, { desc = 'Search Builtin' })

--Mini
require('mini.diff').setup()
require('mini.jump').setup()
require('mini.surround').setup()
require('mini.ai').setup()

--QOL
require('guess-indent').setup()
