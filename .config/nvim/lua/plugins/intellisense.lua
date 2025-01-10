-- Intellisense includes the following plugins
--  - nvim-lspconfig
--  - nvim-cmp
--  - nvim-lint
--  - lazydev
--  - conform
return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
      'ray-x/lsp_signature.nvim',
    },

    config = function()
      vim.keymap.set('n', '<Leader>is', '<Cmd>LspInfo<CR>', { desc = 'L[S]P' })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          -- Adds signature help
          require('lsp_signature').setup({
            hint_enable = false,
            handler_opts = { border = 'rounded' },
            wrap = false,
            doc_lines = 0,
          })

          local telelescope = require('telescope.builtin')
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', telelescope.lsp_definitions, '[C]ode [D]efinition')
          map('gD', vim.lsp.buf.declaration, '[C]ode [D]eclaration')
          map('gr', telelescope.lsp_references, '[C]ode [R]eferences')
          map('gI', telelescope.lsp_implementations, '[C]ode [I]mplementation')
          map('gy', telelescope.lsp_type_definitions, 'T[y]pe Definition')
          map('<Leader>bs', telelescope.lsp_document_symbols, '[B]uffer [S]ymbols')
          map('<Leader>ws', telelescope.lsp_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<Leader>cr', vim.lsp.buf.rename, '[C]ode [R]ename')
          map('<Leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- Highliht references on hover
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({
                  group = 'lsp-highlight',
                  buffer = event2.buf,
                })
              end,
            })
          end

          -- If LSP supports inlay hints, enable them
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<Leader>th', function()
              local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
              vim.lsp.inlay_hint.enable(not is_enabled)
              vim.print('Inlay Hints: ' .. tostring(not is_enabled))
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Change diagnostic symbols in the sign column (gutter)
      if vim.g.have_nerd_font then
        local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
        local diagnostic_signs = {}
        for type, icon in pairs(signs) do
          diagnostic_signs[vim.diagnostic.severity[type]] = icon
        end
        vim.diagnostic.config({ signs = { text = diagnostic_signs } })
      end

      -- Add cmp_nvim_lsp capabilities to the default capabilities of Neovim
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      local servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                diagnosticMode = 'openFilesOnly',
                typeCheckingMode = 'standard',
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        marksman = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              diagnostics = { globals = { 'vim', 'require' }, disable = { 'missing-fields' } },
            },
          },
        },
        bashls = {
          filetypes = { 'bash', 'sh' },
        },
      }

      -- Use `:Mason` to check dependencies and install them
      require('mason').setup()
      vim.keymap.set('n', '<Leader>im', '<Cmd>Mason<CR>', { desc = '[M]ason' })

      -- Add other tools here that you want Mason to install
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'black',
        'isort',
        'markdownlint',
        'jsonlint',
        'shellcheck',
        'shfmt',
      })
      require('mason-tool-installer').setup({ ensure_installed = ensure_installed })
      require('mason-lspconfig').setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- Override capabilities with server-specific capabilities
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      })
    end,
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        build = (function() return 'make install_jsregexp' end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
          },
        },
      },
      -- Sources
      'rcarriga/cmp-dap',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      {
        'zbirenbaum/copilot-cmp',
        config = function() require('copilot_cmp').setup() end,
        dependencies = { 'zbirenbaum/copilot.lua' },
      },
      -- Show icons in completion menu
      'onsails/lspkind.nvim',
    },
    config = function()
      -- See `:help cmp`
      local luasnip = require('luasnip')
      luasnip.config.setup({})

      local cmp = require('cmp')
      vim.keymap.set('n', '<Leader>ic', '<Cmd>CmpStatus<CR>', { desc = '[C]ompletions' })

      local compare = cmp.config.compare
      local opts = {
        enabled = function()
          return vim.api.nvim_get_option_value('buftype', { buf = 0 }) ~= 'prompt' or require('cmp_dap').is_dap_buffer()
        end,
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          fields = { 'kind', 'abbr' },
          format = require('lspkind').cmp_format({
            mode = 'symbol',
            symbol_map = { Copilot = '' },
          }),
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        performance = { max_view_entries = 10 },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'copilot', max_item_count = 1, keyword_length = 2 },
          { name = 'lazydev', group_index = 0 },
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            compare.exact,
            require('copilot_cmp.comparators').prioritize,
            -- Defaults
            compare.offset,
            -- compare.scopes,
            compare.score,
            compare.recently_used,
            compare.locality,
            compare.kind,
            -- compare.sort_text,
            compare.length,
            compare.order,
          },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete({}),
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if luasnip.expandable() then
                luasnip.expand()
              else
                cmp.confirm({
                  select = true,
                })
              end
            else
              fallback()
            end
          end),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
      }
      cmp.setup(opts)
      cmp.setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
        sources = { { name = 'dap' } },
      })
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = 'BufEnter',
    keys = {
      {
        '<Leader>cf',
        function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
        mode = { 'n', 'v' },
        desc = '[C]ode [F]ormat Buffer/Selection',
      },
    },
    init = function() vim.g.disable_autoformat = true end,
    opts = {
      notify_on_error = false,
      format_on_save = function(_)
        if vim.g.disable_autoformat then return end
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        markdown = { 'markdownlint' },
        zsh = { 'shfmt', 'shellcheck' },
        sh = { 'shfmt', 'shellcheck' },
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
      vim.keymap.set('n', '<Leader>tf', ':ToggleFormatOnSave<CR>', { desc = '[T]oggle [F]ormat on save' })
    end,
  },

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require('lint')
      -- Disable all default linters, enable manually if needed
      lint.linters_by_ft = {}

      -- Autocommand to start linting
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run in modifiable buffers
          if vim.opt_local.modifiable:get() then lint.try_lint() end
        end,
      })
    end,
  },

  { -- Intellisense for neovim api and plugins
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
}
