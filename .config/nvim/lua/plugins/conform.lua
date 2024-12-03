return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Don't do anything if disabled globally
      if vim.g.disable_autoformat then
        return
      end
      -- Disable for languages that don't have a well standardized coding style.
      local disable_filetypes = { c = true, cpp = true }
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      return {
        timeout_ms = 500,
        lsp_format = lsp_format_opt,
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'isort', 'black' },
      markdown = { 'markdownlint' },
    },
  },
  config = function(_, opts)
    require('conform').setup(opts)

    -- Toggle format on save
    vim.api.nvim_create_user_command('ToggleFormatOnSave', function()
      vim.g.disable_autoformat = not vim.g.disable_autoformat
      vim.print('Format On Save: ' .. tostring(not vim.g.disable_autoformat))
    end, {
      desc = 'Toggle autoformat-on-save with conform',
    })
    vim.keymap.set('n', '<leader>tf', ':ToggleFormatOnSave<CR>', { desc = '[T]oggle [F]ormat on save' })
  end,
}
