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
