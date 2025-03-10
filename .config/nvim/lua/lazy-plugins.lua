-- Bootstrap lazy
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Setup plugins, use `:Lazy` and `:che` to debug
require('lazy').setup('plugins', {
    defaults = { version = nil },
})
vim.cmd.colorscheme(vim.g.colorscheme)
vim.keymap.set('n', '<Leader>il', '<Cmd>Lazy<CR>', { desc = '[L]azy' })
