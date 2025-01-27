vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.highlight.on_yank({ timeout = 300 }) end,
})

vim.api.nvim_create_autocmd('FileType', {
    desc = 'Execute Python Code',
    pattern = 'python',
    group = vim.api.nvim_create_augroup('python', { clear = true }),
    callback = function()
        vim.keymap.set({ 'n', 'v' }, '<Leader>x', ':w !python3<CR>', { desc = ' [X] Execute: Python File/Selection' })
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    desc = 'Execute Python Code',
    pattern = 'lua',
    group = vim.api.nvim_create_augroup('lua', { clear = true }),
    callback = function()
        vim.keymap.set('n', '<Leader>x', '<Cmd>luafile %<CR>', { desc = ' [X] Execute: Lua File' })
        vim.keymap.set('v', '<Leader>x', ':lua<CR>', { desc = '[X] Execute: Lua Selection' })
    end,
})
