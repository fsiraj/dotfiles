vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.highlight.on_yank({ timeout = 300 }) end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
    desc = 'Set custom overrides for catppuccin',
    group = vim.api.nvim_create_augroup('catppuccin-override', { clear = true }),
    pattern = 'catppuccin-mocha',
    callback = function()
        local colors = require('catppuccin.palettes').get_palette('mocha')
        vim.api.nvim_set_hl(0, 'FloatBorder', { fg = colors.mantle, bg = colors.mantle })
        vim.api.nvim_set_hl(0, 'FloatTitle', { fg = colors.mantle, bg = colors.mauve, bold = true })
    end,
})

