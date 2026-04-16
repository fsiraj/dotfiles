-- NOTE: Options

-- Colorscheme
vim.g.colorscheme = 'github_dark_default'

-- Set these before plugins are loaded
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Tabs and spaces
vim.g.tabstop = 4
vim.g.shiftwidth = 4
vim.g.expandtab = true

-- Enable relative line numbering
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.fillchars:append({ eob = ' ', fold = ' ' })

-- Enable mouse mode
vim.opt.mouse = 'a'

-- Lualine using winbar as status line
vim.opt.laststatus = 3
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
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how Neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 12

-- Disable tabline, shown with lualine instead
vim.opt.showtabline = 0

-- Disable defualt cmdline
vim.opt.cmdheight = 1

-- Show dialogue instead of error
vim.opt.confirm = true

-- Use treesitter for folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldtext = ''

-- Diagnostics
vim.diagnostic.config({
   severity_sort = true,
   float = { border = 'none', source = true },
   underline = true,
   signs = {
      text = {
         [vim.diagnostic.severity.ERROR] = '󰅚 ',
         [vim.diagnostic.severity.WARN] = '󰀪 ',
         [vim.diagnostic.severity.INFO] = '󰋽 ',
         [vim.diagnostic.severity.HINT] = '󰌶 ',
      },
   },
   virtual_text = false,
})

--NOTE: Keymaps

-- <CR> expands abbreviations without needing to type <Space> or <Tab>
vim.keymap.set('c', '<CR>', function() return vim.fn.getcmdtype() == ':' and '<C-]><CR>' or '<CR>' end, { expr = true })

-- :wqa works even when terminal buffers are open
vim.keymap.set('ca', 'wqa', 'wa | qa')

-- Navigate wrapped lines as multiple lines
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- Mouse scroll behaves like keyboard
vim.keymap.set({ 'n', 'v' }, '<ScrollWheelDown>', '5j')
vim.keymap.set({ 'n', 'v' }, '<ScrollWheelUp>', '5k')

-- Buffer keymaps
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
vim.keymap.set('n', 'gb', '<Cmd>e #<CR>', { desc = 'Toggle Buffer Alternative (#)' })
vim.keymap.set('n', '<C-Bslash>', '<Cmd>vsp<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<C-->', '<Cmd>sp<CR>', { desc = 'Horizontal split' })

-- Find Replace
vim.keymap.set('n', '<Leader>fr', ':%s/<C-r><C-w>/', { desc = 'Find Replace Word' })
vim.keymap.set('v', '<Leader>fr', '"zy:%s/<C-r>z/', { desc = 'Find Replace Selection' })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>')

-- Leave terminal mode without stealing plain <Esc> from terminal apps
vim.keymap.set('t', '<C-]>', '<C-\\><C-n>', { desc = 'Terminal Normal Mode' })
vim.keymap.set('n', '<C-]>', '<Nop>')

-- Toggle diagnostic information
vim.keymap.set('n', '<Leader>td', function()
   vim.diagnostic.enable(not vim.diagnostic.is_enabled())
   vim.notify('Diagnostics: ' .. tostring(vim.diagnostic.is_enabled()))
end, { desc = 'LSP: Toggle Diagnostics' })

--NOTE: Autocommands

vim.api.nvim_create_autocmd('TermOpen', {
   desc = 'Set buffer local options for terminals',
   group = vim.api.nvim_create_augroup('terminal', { clear = true }),
   callback = function(args)
      local bo = vim.bo[args.buf]
      if bo.filetype == '' then bo.filetype = 'terminal' end
      vim.wo.number = false
      vim.wo.relativenumber = false
      vim.wo.cursorline = false
      vim.keymap.set('n', '<CR>', 'i', { buffer = args.buf })
   end,
})

vim.api.nvim_create_autocmd('VimResized', {
   desc = 'Equalize splits when nvim is resized',
   group = vim.api.nvim_create_augroup('vim-resize', { clear = true }),
   command = 'wincmd =',
})

local function open_diagnostic_float(focus)
   if vim.diagnostic.is_enabled() then
      vim.diagnostic.open_float({
         scope = 'cursor',
         focusable = true,
         focus = focus,
      })
   end
end

vim.api.nvim_create_autocmd({ 'CursorHold' }, {
   desc = 'Display floating diagnostic window',
   group = vim.api.nvim_create_augroup('diagnostics', { clear = true }),
   callback = function() open_diagnostic_float(false) end,
})

vim.keymap.set('n', '<Leader>cq', function() open_diagnostic_float(true) end, { desc = 'Focus diagnostic float' })

--Prevent W12 prompt everytime a change is made to the buffer outside Neovim
vim.api.nvim_create_autocmd('FileChangedShell', {
   callback = function(args)
      if vim.bo[args.buf].modified then
         vim.v.fcs_choice = 'ask'
         return
      end
      vim.v.fcs_choice = 'reload'
      vim.notify(
         ('Reloaded %s because it changed on disk'):format(vim.fn.fnamemodify(args.file, ':~:.')),
         vim.log.levels.WARN
      )
   end,
})

--NOTE: Plugins

-- Bootstrap lazy
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
   local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
   local out = vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      '--branch=stable',
      lazyrepo,
      lazypath,
   })
   if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require('lazy').setup('plugins', {
   defaults = { version = nil },
})
vim.keymap.set('n', '<Leader>il', '<Cmd>Lazy<CR>', { desc = 'Lazy' })
vim.cmd.colorscheme(vim.g.colorscheme)
