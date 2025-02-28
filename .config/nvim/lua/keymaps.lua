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
