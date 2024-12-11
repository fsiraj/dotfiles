vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.highlight.on_yank({ timeout = 300 }) end,
})

vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  desc = 'Show diagnostics in floating window',
  group = vim.api.nvim_create_augroup('float_diagnostic', { clear = true }),
  callback = function() vim.diagnostic.open_float(nil, { focus = false }) end,
})
