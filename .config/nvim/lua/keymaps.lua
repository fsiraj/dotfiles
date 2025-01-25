-- Buffer keymaps
vim.keymap.set('n', '<Leader>bt', '<cmd>e #<CR>', { desc = '[B]uffer [T]oggle Alternative (#)' })
vim.keymap.set('n', '<Leader>bd', '<cmd>bp | sp | bn | bd<CR>', { desc = '[B]uffer [D]elete (preserves Window)' })
vim.keymap.set('n', '<C-\\>', '<cmd>vsp<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<C-->', '<cmd>sp<CR>', { desc = 'Horizontal split' })

-- Find Replace
vim.keymap.set('n', '<Leader>fr', ':%s/<C-r><C-w>/', { desc = '[F]ind [R]eplace Word'})
vim.keymap.set('v', '<Leader>fr', '"zy:%s/<C-r>z/', { desc = '[F]ind [R]eplace Selection'})

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Resize windows with Meta + arrow keys
vim.keymap.set('n', '<M-Up>', '<cmd>resize +2<CR>', { desc = 'Increase window height' })
vim.keymap.set('n', '<M-Down>', '<cmd>resize -2<CR>', { desc = 'Decrease window height' })
vim.keymap.set('n', '<M-Left>', '<cmd>vertical resize -2<CR>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<M-Right>', '<cmd>vertical resize +2<CR>', { desc = 'Increase window width' })

-- Easier pasting in insert mode
vim.keymap.set('i', '<C-p>', '<C-r>+', { desc = 'Paste from register +' })

-- Escape insert mode in terminal easier
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Normal Mode' })
