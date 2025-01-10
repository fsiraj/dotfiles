-- Fuzzy Finder (files, lsp, etc)
return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function() return vim.fn.executable('make') == 1 end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    require('telescope').setup({
      --  To see bindings in picker: i = <C-h>, n = ?
      defaults = {
        winblend = 5,
        wrap_results = false,
        file_ignore_patterns = { '%.git/' },
        mappings = {
          i = {
            ['<C-y>'] = 'select_default',
            ['<C-Bslash>'] = 'select_vertical',
            ['<C-_>'] = 'select_horizontal',
            ['<C-h>'] = 'which_key',
            ['<C-x>'] = 'delete_buffer',
            ['<C-v>'] = false,
          },
        },
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
        },
      },

      pickers = {
        find_files = { hidden = true },
        help_tags = { mappings = { i = { ['<CR>'] = 'select_vertical' } } },
        colorscheme = { enable_preview = true },
        lsp_references = { path_display = { 'tail' } },
      },

      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    })

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<Leader>sh', builtin.help_tags, { desc = 'Telescope: [S]earch [H]elp' })
    vim.keymap.set('n', '<Leader>sk', builtin.keymaps, { desc = 'Telescope: [S]earch [K]eymaps' })
    vim.keymap.set('n', '<Leader>sf', builtin.find_files, { desc = 'Telescope: [S]earch [F]iles' })
    vim.keymap.set('n', '<Leader>sb', builtin.builtin, { desc = 'Telescope: [S]earch [B]uiltin' })
    vim.keymap.set('n', '<Leader>sw', builtin.grep_string, { desc = 'Telescope: [S]earch current [W]ord' })
    vim.keymap.set('n', '<Leader>sg', builtin.live_grep, { desc = 'Telescope: [S]earch by [G]rep' })
    vim.keymap.set('n', '<Leader>sd', builtin.diagnostics, { desc = 'Telescope: [S]earch [D]iagnostics' })
    vim.keymap.set('n', '<Leader>sr', builtin.resume, { desc = 'Telescope: [S]earch [R]esume' })
    vim.keymap.set('n', '<Leader>so', builtin.oldfiles, { desc = 'Telescope: [S]earch [O]ld Files' })
    vim.keymap.set('n', '<Leader>st', builtin.colorscheme, { desc = 'Telescope: [S]earch [T]hemes' })
    vim.keymap.set('n', '<Leader><Leader>', builtin.buffers, { desc = 'Telescope: [ ] Find Existing Buffers' })
    vim.keymap.set(
      'n', '<Leader>/', builtin.current_buffer_fuzzy_find,
      { desc = 'Telescope: [/] Fuzzy Search Current Buffer' }
    )
    vim.keymap.set(
      'n', '<Leader>s/',
      function() builtin.live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files', }) end,
      { desc = 'Telescope: [S]earch [/] Open Files' }
    )
    vim.keymap.set(
      'n', '<Leader>sn', function() builtin.find_files({ cwd = vim.fn.stdpath('config') }) end,
      { desc = 'Telescope: [S]earch [N]eovim files' }
    )
  end,
}
