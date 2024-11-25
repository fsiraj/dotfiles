-- Buffer keymaps
vim.keymap.set('n', '<leader>bd', '<cmd>bp<bar>sp<bar>bn<bar>bd<CR>', { desc = '[B]uffer [D]elete (without deleting window)' })
vim.keymap.set('n', '<leader>bt', '<cmd>e #<CR>', { desc = '[Buffer] [T]oggle Alternative (#)' })
vim.keymap.set('n', '<C-\\>', '<cmd>vsp<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<C-_>', '<cmd>sp<CR>', { desc = 'Horizontal split' })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>cq', vim.diagnostic.setloclist, { desc = 'Open [C]ode diagnostic [Q]uickfix list' })

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Resize windows with Meta + arrow keys
vim.keymap.set('n', '<M-Up>', '<cmd>resize +1<CR>', { desc = 'Increase window height' })
vim.keymap.set('n', '<M-Down>', '<cmd>resize -1<CR>', { desc = 'Decrease window height' })
vim.keymap.set('n', '<M-Left>', '<cmd>vertical resize -1<CR>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<M-Right>', '<cmd>vertical resize +1<CR>', { desc = 'Increase window width' })

-- Easier pasting in insert mode
vim.keymap.set('i', '<C-p>', '<C-r>*', { desc = 'Paste from register +' })
