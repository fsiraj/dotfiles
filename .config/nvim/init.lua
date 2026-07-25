-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                               Options                                │
-- └──────────────────────────────────────────────────────────────────────┘

-- Set these before plugins are loaded
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Tabs and spaces
vim.opt.expandtab = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Line numbering
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'
vim.opt.fillchars:append({ eob = ' ', fold = ' ' })
vim.opt.number = true
vim.opt.relativenumber = true

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Sync clipboard between OS and Neovim.
vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)

-- Save undo history
vim.opt.undofile = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Timing
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Folds
vim.opt.foldlevel = 99

-- UI
vim.opt.breakindent = true
vim.opt.showbreak = '↳ '
vim.opt.cmdheight = 1
vim.opt.confirm = true
vim.opt.inccommand = 'split'
vim.opt.laststatus = 0
vim.opt.linebreak = true
vim.opt.mouse = 'a'
vim.opt.mousescroll = { 'ver:1', 'hor:2' }
vim.opt.scrolloff = 6
vim.opt.showmode = false
vim.opt.showtabline = 0
vim.opt.signcolumn = 'yes'
vim.opt.wrap = false

-- Diagnostics
vim.diagnostic.config({
   severity_sort = true,
   float = { border = 'none', source = true },
   underline = true,
   signs = {
      text = {
         [vim.diagnostic.severity.ERROR] = '󰅚 ',
         [vim.diagnostic.severity.WARN] = '󰀪 ',
         [vim.diagnostic.severity.INFO] = '󰋽 ',
         [vim.diagnostic.severity.HINT] = '󰌶 ',
      },
   },
   virtual_text = false,
})

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                               Keymaps                                │
-- └──────────────────────────────────────────────────────────────────────┘

local keymap = vim.keymap.set

-- Neovim <-> Tmux Navigation
local function move(dv, dt)
   local prev = vim.api.nvim_get_current_win()
   vim.cmd('wincmd ' .. dv)
   if prev == vim.api.nvim_get_current_win() and vim.env.TMUX then
      vim.fn.system({ 'tmux', 'select-pane', '-' .. dt })
   end
end

for _, dirs in ipairs({ { 'h', 'L' }, { 'j', 'D' }, { 'k', 'U' }, { 'l', 'R' } }) do
   local dv, dt = unpack(dirs)
   local lhs = '<C-' .. dv .. '>'
   keymap('n', lhs, function() move(dv, dt) end, { desc = 'Navigate ' .. dv })
   keymap('t', lhs, function()
      vim.cmd('stopinsert')
      move(dv, dt)
   end, { desc = 'Navigate ' .. dt })
end

-- Buffer Navigation
keymap({ 'n', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
keymap({ 'n', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
keymap('n', 'ga', '<Cmd>e #<CR>', { desc = 'Goto Alternate Buffer' })

-- Splits
keymap('n', '<C-w>\\', '<Cmd>vsplit<CR>', { desc = 'Vertical split' })
keymap('n', '<C-w>-', '<Cmd>split<CR>', { desc = 'Horizontal split' })
keymap('n', '<C-w>z', '<Cmd>tab split<CR>', { desc = 'Tab split' })

-- Terminal Normal Mode
keymap('t', '<C-]>', '<C-\\><C-n>', { desc = 'Terminal Normal Mode' })
keymap('n', '<C-]>', '<Nop>')

-- Diagnostics
local function open_diagnostic_float(focus)
   if vim.diagnostic.is_enabled() then
      vim.diagnostic.open_float({
         scope = 'cursor',
         focusable = true,
         focus = focus,
      })
   end
end

keymap('n', '<Leader>Td', function()
   vim.diagnostic.enable(not vim.diagnostic.is_enabled())
   vim.notify('Diagnostics: ' .. tostring(vim.diagnostic.is_enabled()))
end, { desc = 'Toggle Diagnostics' })
keymap('n', '<Leader>cq', function() open_diagnostic_float(true) end, { desc = 'Focus diagnostic float' })

-- Misc
keymap('ca', 'wqa', 'wa | qa')
keymap('c', '<CR>', function() return vim.fn.getcmdtype() == ':' and '<C-]><CR>' or '<CR>' end, { expr = true })
keymap('n', '<Esc>', '<Cmd>nohlsearch<CR>')
keymap('n', '<Leader>fr', ':%s/<C-r><C-w>/', { desc = 'Find Replace Word' })
keymap('v', '<Leader>fr', '"zy:%s/<C-r>z/', { desc = 'Find Replace Selection' })

-- Lazy (plugins) + Mason (language tools)
keymap('n', '<Leader>il', '<Cmd>Lazy<CR>', { desc = 'Lazy' })
keymap('n', '<Leader>im', '<Cmd>Mason<CR>', { desc = 'Mason' })

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                             Autocommands                             │
-- └──────────────────────────────────────────────────────────────────────┘

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd('TermOpen', {
   desc = 'Set buffer local options for terminals',
   group = augroup('terminal', { clear = true }),
   callback = function(args)
      local bo = vim.bo[args.buf]
      if bo.filetype == '' then bo.filetype = 'terminal' end
      vim.wo.number = false
      vim.wo.relativenumber = false
      vim.wo.cursorline = false
      keymap('n', '<CR>', 'i', { buffer = args.buf })
   end,
})

autocmd('FileType', {
   desc = 'Click into terminal buffers enters terminal mode (unless drag-selecting)',
   pattern = { 'terminal', 'Floaterm' },
   group = augroup('terminal-click', { clear = true }),
   callback = function(args)
      keymap('n', '<LeftRelease>', function()
         if vim.fn.mode() == 'n' then vim.cmd('startinsert') end
      end, { buffer = args.buf, desc = 'Enter terminal mode on click' })
   end,
})

autocmd('FileType', {
   desc = 'Close ephemeral windows with q',
   pattern = { 'neotest-output', 'neotest-summary', 'dap-float' },
   group = augroup('ephemeral-close', { clear = true }),
   callback = function(args)
      keymap('n', 'q', '<C-w>q', { buffer = args.buf, silent = true, nowait = true, desc = 'Close Window' })
   end,
})

autocmd('VimResized', {
   desc = 'Equalize splits when nvim is resized',
   group = augroup('vim-resize', { clear = true }),
   command = 'wincmd =',
})

autocmd('CursorHold', {
   desc = 'Display floating diagnostic window',
   group = augroup('diagnostics', { clear = true }),
   callback = function() open_diagnostic_float(false) end,
})

autocmd('ColorScheme', {
   callback = function()
      local vim_notify = vim.notify
      vim.notify = function(...) end

      local plugins_to_reload = { ['tiny-glimmer.nvim'] = 'tiny-glimmer' }
      for lazy_name, module in pairs(plugins_to_reload) do
         if package.loaded[module] then vim.cmd('Lazy reload ' .. lazy_name) end
      end

      vim.notify = vim_notify
   end,
   desc = 'Refresh plugin colors',
})

autocmd('FileChangedShell', {
   --Prevent W12 prompt everytime a change is made to the buffer outside Neovim
   callback = function(args)
      vim.v.fcs_choice = 'reload'
      vim.notify(
         ('Reloaded %s because it changed on disk'):format(vim.fn.fnamemodify(args.file, ':~:.')),
         vim.log.levels.WARN
      )
   end,
})

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                            UI: Constants                             │
-- └──────────────────────────────────────────────────────────────────────┘

--- To make UIs multiples of consistent width
local unit_width = 40

--- Dashboard Header
local neovim_logo = [[
        @@@           @@        
      @@@@@@          @@@@      
    @@@@@@@@@@        @@@@@@    
  ##@@@@@@@@@@@       @@@@@@@@  
  ###@@@@@@@@@@@      @@@@@@@@  
  ####@@@@@@@@@@@     @@@@@@@@  
  ######@@@@@@@@@@@   @@@@@@@@  
  #######@@@@@@@@@@@  @@@@@@@@  
  ########  @@@@@@@@@ @@@@@@@@  
  ########   @@@@@@@@@@@@@@@@@  
  ########    @@@@@@@@@@@@@@@@  
  ########      @@@@@@@@@@@@@@  
  ########       @@@@@@@@@@@@@  
   #######        @@@@@@@@@@@   
     #####         @@@@@@@@     
       ###          @@@@@       
        ##            @@        
]]

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                                Theme                                 │
-- └──────────────────────────────────────────────────────────────────────┘

local get_hl = vim.api.nvim_get_hl

local function get_hl_attr(name, attr)
   local value = get_hl(0, { name = name, link = false })[attr]
   if (attr == 'fg' or attr == 'bg' or attr == 'sp') and type(value) == 'number' then
      return string.format('#%06x', value)
   end
   return value
end

local function winhl(links)
   return table.concat(vim.iter(links):map(function(from, to) return from .. ':' .. to end):totable(), ',')
end

local function get_palette(base)
   base = base or require('tinted-osc-colors').get_palette()
   --stylua: ignore
   return {
      accent = (base.extras and base.extras.accent) or base.base0E    , orange  = base.base09,
      text   = base.base05, base   = base.base00, crust  = base.base01, subtext = base.base03,
      black  = base.base02, white  = base.base05, red    = base.base08, yellow  = base.base0A,
      green  = base.base0B, cyan   = base.base0C, blue   = base.base0D, magenta = base.base0E,
   }
end

local function generate_nvim_overrides(p)
   --stylua: ignore
   return {
      -- Neovim Built-in
      --[[ Float       ]] FloatTitle = { fg = p.crust, bg = p.accent, bold = true },
      --[[ StatusLine  ]] StatusLine = { fg = p.base, bg = p.base }, StatusLineNC = { fg = p.base, bg = p.base }, StatusLineTerm = { link = 'StatusLine' }, StatusLineTermNC = { link = 'StatusLineNC' },
      --[[ Other       ]] CursorLineNr = { fg = p.accent }, Folded = { bg = p.base }, Keyword = { fg = p.accent },
      -- Plugins
      --[[ Dap         ]] DapBreak = { fg = p.red }, DapStop = { fg = p.yellow },
      --[[ Flash       ]] FlashLabel = { fg = p.crust, bg = p.accent }, FlashPrompt = { link = 'Normal' },
      --[[ Foldtext    ]] FoldtextLines = { fg = p.yellow, bold = true },
      --[[ Jupynvim    ]] JupynvimBorder = { link = 'Comment' },
      --[[ Lazy        ]] LazyButton = { bg = p.base }, LazySpecial = { fg = p.accent },
      --[[ Lualine     ]] LualineNormalA = { bg = p.accent, fg = p.crust, bold = true },
      --[[ Mini        ]] MiniIndentscopeSymbol  = { fg = p.accent },
      --[[ Neotest     ]] NeotestAdapterName = { fg = p.accent, bold = true },
      --[[ NeoTree     ]] NeoTreeCursorLine = { fg = p.accent, bg = p.base, bold = true },
      --[[ Sidekick    ]] SidekickDiffAdd = { link = 'DiffAdd' }, SidekickDiffContext = { bg = p.base }, SidekickSign = { fg = p.cyan },
      --[[ Snacks      ]] SnacksDashboardHeaderAlt = { fg = p.blue }, SnacksDashboardSpecial = { fg = p.accent },
      --[[ Treesitter  ]] TreesitterContext = { bg = p.base }, TreesitterContextSeparator = { fg = p.accent, bg = p.base },
   }
end

vim.api.nvim_create_user_command(
   'NvimPalette',
   function() vim.print(get_palette()) end,
   { desc = 'Inspect the current semantic palette' }
)

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                                 LSP                                  │
-- └──────────────────────────────────────────────────────────────────────┘

local lsps = {
   'lua_ls',
   'ty',
   'ruff',
   'clangd',
   'bashls',
   'marksman',
   'taplo',
   'jsonls',
   'yamlls',
   'ansiblels',
   -- 'rust-analyzer' (handled by rustaceanvim)
}

local tools = {
   --stylua: ignore start
   { 'stylua',       filetypes = { 'lua' } },
   { 'debugpy',      filetypes = { 'python' } },
   { 'markdownlint', filetypes = { 'markdown' } },
   { 'prettier',     filetypes = { 'markdown' } },
   { 'shellcheck',   filetypes = { 'sh', 'bash', 'zsh' } },
   { 'shfmt',        filetypes = { 'sh', 'bash', 'zsh' } },
   { 'codelldb',     filetypes = { 'c', 'cpp' } },
   --stylua: ignore end
}

vim.filetype.add({
   pattern = {
      ['.*%.ya?ml'] = function(path)
         if vim.fs.root(path, { 'ansible.cfg', '.ansible-lint' }) then return 'yaml.ansible' end
      end,
   },
})

local formatters_by_ft = {
   --stylua: ignore start
   lua      = { 'stylua' },
   python   = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
   markdown = { 'prettier' },
   zsh      = { 'shfmt', 'shellcheck' },
   sh       = { 'shfmt', 'shellcheck' },
   --stylua: ignore end
}

local linters_by_ft = {
   markdown = { 'markdownlint' },
}

local function lsp_highlight_symbols(event)
   local client = vim.lsp.get_client_by_id(event.data.client_id)
   if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = augroup('lsp-highlight', { clear = false })
      autocmd({ 'CursorHold', 'CursorHoldI' }, {
         buffer = event.buf,
         group = highlight_augroup,
         callback = vim.lsp.buf.document_highlight,
      })
      autocmd({ 'CursorMoved', 'CursorMovedI' }, {
         buffer = event.buf,
         group = highlight_augroup,
         callback = vim.lsp.buf.clear_references,
      })
      autocmd('LspDetach', {
         group = augroup('lsp-detach', { clear = true }),
         callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({
               group = 'lsp-highlight',
               buffer = event2.buf,
            })
         end,
      })
   end
end

local function lsp_inlay_hints(event)
   local client = vim.lsp.get_client_by_id(event.data.client_id)
   if client and client:supports_method('textDocument/inlayHint', event.buf) then
      keymap('n', '<Leader>Ti', function()
         local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
         vim.lsp.inlay_hint.enable(not is_enabled)
         vim.notify('Inlay Hints: ' .. tostring(not is_enabled))
      end, { buffer = event.buf, desc = 'Toggle Inlay Hints' })
   end
end

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                     Plugins: Bootstrap lazy.nvim                     │
-- └──────────────────────────────────────────────────────────────────────┘

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
   local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
   --stylua: ignore
   local out = vim.fn.system({
      'git', 'clone', '--filter=blob:none', '--branch=stable',
      lazyrepo, lazypath,
   })
   if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end
vim.opt.rtp:prepend(lazypath)

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                            Plugins: Core                             │
-- └──────────────────────────────────────────────────────────────────────┘

local core_plugins = {
   --Fzflua
   {
      'ibhagwan/fzf-lua',
      event = 'VeryLazy',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
         local fzf = require('fzf-lua')
         local actions = require('fzf-lua.actions')

         local ui_select = function(fzf_opts, items)
            return {
               prompt = ' ',
               winopts = {
                  title = ' ' .. vim.trim((fzf_opts.prompt or 'Select'):gsub('%s*:%s*$', '')) .. ' ',
                  title_pos = 'center',
                  width = unit_width * 2,
                  height = math.ceil(math.min(vim.o.lines * 0.8, #items + 4)),
               },
            }
         end
         local width = math.min(unit_width * 4, math.floor(0.8 * vim.o.columns))

         fzf.setup({
            defaults = {
               formatter = 'path.filename_first',
            },
            winopts = {
               width = width,
               height = 0.8,
               row = 0.5,
               backdrop = false,
            },
            hls = { title = 'FloatTitle' },
            keymap = {
               builtin = {
                  true,
                  ['<C-u>'] = 'preview-up',
                  ['<C-d>'] = 'preview-down',
                  ['<C-h>'] = 'toggle-help',
               },
            },
            files = {
               hidden = true,
               follow = true,
               fd_opts = [[--color=never --type f --type l --exclude .git --exclude .jj --exclude .venv]],
            },
            helptags = {
               actions = { ['enter'] = actions.help_vert },
            },
            grep = {
               hidden = true,
               rg_glob = true,
               rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -g "!.git" -g "!.jj" -e]],
            },
            buffers = {
               previewer = false,
               winopts = {
                  height = 16,
                  width = unit_width * 2,
               },
            },
            ui_select = ui_select,
         })

         -- Custom pickers
         local plugins = function()
            local roots = { vim.fn.stdpath('data') .. '/lazy' }
            local dev = vim.fn.expand('~/nvim-plugins')
            if vim.uv.fs_stat(dev) then table.insert(roots, dev) end
            fzf.files({ search_paths = roots })
         end
         local files_in_dir = function()
            vim.ui.input({ prompt = 'Directory: ', completion = 'dir' }, function(dir)
               if dir and dir ~= '' then fzf.files({ cwd = vim.fn.expand(dir) }) end
            end)
         end
         local dotfiles = function() return fzf.files({ cwd = '~/dotfiles' }) end
         local themes = function()
            local script = vim.fn.expand('~/.config/tinted-theming/tinted.sh')
            fzf.fzf_exec(script .. ' list', {
               prompt = 'Themes> ',
               winopts = { width = unit_width },
               actions = {
                  ['default'] = function(selected)
                     if selected[1] then vim.system({ script, 'apply', selected[1] }) end
                  end,
               },
            })
         end
         local nerdfont = function()
            local cache = vim.fn.stdpath('cache') .. '/nerdfont-glyphs.json'
            local url = 'https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/glyphnames.json'
            vim.system({ 'find', cache, '-mtime', '+30', '-delete' }):wait()
            vim.system({ 'sh', '-c', ('[ -s %s ] || curl -fsSL %s -o %s'):format(cache, url, cache) }):wait()
            local cmd = [[jq -r 'to_entries[]|select(.key|startswith("METADATA")|not)|"\(.value.char)    \(.key)"' ]]
            local put = function(s) vim.api.nvim_put({ s[1]:match('^(%S+)') }, 'c', true, true) end
            local fmt = function(x) return (x:gsub('^(%S+)(%s+)(.*)$', '\27[93m%1\27[0m%2\27[2m%3\27[0m')) end
            fzf.fzf_exec(cmd .. cache, {
               prompt = 'Icon❯ ',
               actions = { default = put },
               winopts = { width = unit_width * 1.5 },
               fn_transform = fmt,
            })
         end

         --stylua: ignore start
         keymap('n', '<Leader>/'       , fzf.lgrep_curbuf           , { desc = 'FzfLua: Current Buffer' })
         keymap('n', '<Leader><Leader>', fzf.buffers                , { desc = 'FzfLua: Open Buffers' })
         keymap('n', '<Leader>sb'      , fzf.builtin                , { desc = 'FzfLua: Builtin' })
         keymap('n', '<Leader>sc'      , themes                     , { desc = 'Tinty: Apply Theme' })
         keymap('n', '<Leader>sd'      , dotfiles                   , { desc = 'FzfLua: Dotfiles' })
         keymap('n', '<Leader>sf'      , fzf.files                  , { desc = 'FzfLua: Files' })
         keymap('n', '<Leader>sF'      , files_in_dir               , { desc = 'FzfLua: Files' })
         keymap('n', '<Leader>sg'      , fzf.live_grep              , { desc = 'FzfLua: Grep' })
         keymap('n', '<Leader>sh'      , fzf.helptags               , { desc = 'FzfLua: Help' })
         keymap('n', '<Leader>sH'      , fzf.highlights             , { desc = 'FzfLua: Highlights' })
         keymap('n', '<Leader>si'      , nerdfont                   , { desc = 'FzfLua: Nerdfont Symbols' })
         keymap('n', '<Leader>sk'      , fzf.keymaps                , { desc = 'FzfLua: Keymaps' })
         keymap('n', '<Leader>so'      , fzf.oldfiles               , { desc = 'FzfLua: Oldfiles' })
         keymap('n', '<Leader>sp'      , plugins                    , { desc = 'FzfLua: Plugins' })
         keymap('n', '<Leader>sr'      , fzf.resume                 , { desc = 'FzfLua: Resume' })
         keymap('n', '<Leader>sw'      , fzf.grep_cword             , { desc = 'FzfLua: Current Word' })
         keymap('v', '<Leader>ss'      , fzf.grep_visual            , { desc = 'FzfLua: Selection' })
         keymap('n', '<Leader>sq'      , '<Cmd>Namu diagnostics<CR>', { desc = 'Namu: Search Diagnostics' })
         keymap('n', '<Leader>ss'      , '<Cmd>Namu symbols<CR>'    , { desc = 'Namu: Search Symbols Buffer' })
         keymap('n', '<Leader>sS'      , '<Cmd>Namu workspace<CR>'  , { desc = 'Namu: Search Symbols Workspace' })
         keymap('n', '<Leader>st'      , '<Cmd>TodoFzfLua<CR>'      , { desc = 'FzfLua: Search Todos' })
         --stylua: ignore end
      end,
   },
   --Namu
   {
      'bassamsdata/namu.nvim',
      cmd = 'Namu',
      opts = {
         namu_symbols = {
            options = {
               display = { mode = 'icon', format = 'tree_guides' },
               window = { relative = 'win' },
            },
         },
      },
   },

   --Mini
   {
      'echasnovski/mini.nvim',
      dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
      config = function()
         -- Add/delete/replace surroundings (brackets, quotes, etc.)
         require('mini.surround').setup()

         -- Delete buffers and preserve window layout
         require('mini.bufremove').setup()
         keymap('ca', 'bd', 'lua MiniBufremove.delete()')
         keymap('ca', 'bw', 'lua MiniBufremove.wipeout()')

         -- Align text
         require('mini.align').setup({
            mappings = { start = '', start_with_preview = 'gA' },
         })

         -- Better Around/Inside textobjects
         local ai = require('mini.ai')
         ai.setup({
            n_lines = 500,
            custom_textobjects = {
               o = ai.gen_spec.treesitter({
                  a = { '@block.outer', '@conditional.outer', '@loop.outer' },
                  i = { '@block.inner', '@conditional.inner', '@loop.inner' },
               }),
               f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
               c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
               u = ai.gen_spec.function_call(),
               U = ai.gen_spec.function_call({ name_pattern = '[%w_]' }),
            },
         })

         -- Git tools, used for inline diffs
         local diff = require('mini.diff')
         diff.setup({
            mappings = { apply = '<Leader>gS', reset = '<Leader>gR' },
            view = { style = 'sign', priority = 5, signs = { add = '▎', change = '▎', delete = '' } },
            options = { linematch = 0, wrap_goto = true },
         })
         keymap('n', '<Leader>gd', diff.toggle_overlay, { desc = 'Toggle Git Overlay' })
         keymap('n', '<Leader>gs', '<Leader>gSgh', { remap = true, desc = 'Stage hunk' })
         keymap('n', '<Leader>gr', '<Leader>gRgh', { remap = true, desc = 'Reset hunk' })
         keymap('x', '<Leader>gs', '<Leader>gS', { remap = true, desc = 'Stage hunk' })
         keymap('x', '<Leader>gr', '<Leader>gR', { remap = true, desc = 'Reset hunk' })

         -- Scope Lines
         local indent = require('mini.indentscope')
         indent.setup({ symbol = '│', draw = { animation = require('mini.indentscope').gen_animation.none() } })

         autocmd('FileType', {
            desc = 'Disable indentscope for non-code buffers',
            callback = function()
               if vim.bo.buftype ~= '' or vim.bo.filetype == '' then vim.b.miniindentscope_disable = true end
            end,
         })

         -- Session management
         local sessions = require('mini.sessions')

         for _, opt in ipairs({ 'terminal', 'blank', 'help', 'tabpages' }) do
            vim.opt.sessionoptions:remove(opt)
         end

         sessions.setup({
            autowrite = true,
            force = { delete = true },
         })

         -- stylua: ignore
         local function session_name()
            return vim.fn.fnamemodify(vim.uv.cwd() or '', ':t')
         end

         local function with_session(action)
            local name = session_name()
            if sessions.detected[name] then
               action(name)
            else
               vim.notify('No session found for "' .. name .. '"', vim.log.levels.WARN)
            end
         end

         local function restart()
            require('noice').disable()
            sessions.write(session_name(), { verbose = false })
            vim.cmd('restart lua require("mini.sessions").read()')
         end

         keymap('n', '<Leader>Sw', function() sessions.write(session_name()) end, { desc = 'Session Write' })
         keymap('n', '<Leader>Sr', function() with_session(sessions.read) end, { desc = 'Session Restore' })
         keymap('n', '<Leader>Sd', function() with_session(sessions.delete) end, { desc = 'Session Delete' })
         keymap('n', '<Leader>R', restart, { desc = 'Session Restart', nowait = true })

         vim.api.nvim_create_user_command('RestoreSession', function() with_session(sessions.read) end, {})
      end,
   },

   --Treesitter
   {
      'nvim-treesitter/nvim-treesitter',
      cond = vim.fn.executable('tree-sitter') == 1,
      build = ':TSUpdate',
      config = function()
         local treesitter = require('nvim-treesitter')
         local function to_set(list)
            return vim.iter(list):fold({}, function(set, item)
               set[item] = true
               return set
            end)
         end
         local preinstall = { 'lua', 'python', 'markdown', 'regex', 'bash' }
         local supported = to_set(vim.list_extend(treesitter.get_available(1), treesitter.get_available(2)))
         local installed = to_set(vim.list_extend(treesitter.get_installed(), preinstall))
         local excluded = { tmux = true }

         local function attach(buf, lang)
            if not vim.api.nvim_buf_is_valid(buf) or not vim.treesitter.language.add(lang) then return end
            vim.treesitter.start(buf, lang)
            if vim.treesitter.query.get(lang, 'indents') then
               vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo.foldmethod = 'expr'
         end

         autocmd('FileType', {
            callback = function(args)
               local lang = vim.treesitter.language.get_lang(args.match)
               if not lang or excluded[lang] or not supported[lang] then return end
               if installed[lang] then return attach(args.buf, lang) end
               installed[lang] = true
               treesitter.install(lang):await(function() attach(args.buf, lang) end)
            end,
         })
         treesitter.install(preinstall)
      end,
   },
   {
      'nvim-treesitter/nvim-treesitter-context',
      event = 'VeryLazy',
      opts = { enable = true, separator = '─', max_lines = 12, min_window_height = 24 },
   },
   {
      'nvim-treesitter/nvim-treesitter-textobjects',
      event = 'VeryLazy',
      branch = 'main',
      config = true,
   },

   --Floaterm
   {
      'fsiraj/floaterm',
      dev = false,
      keys = { '<C-t>', '<Leader>jj', '<Leader>r' },
      dependencies = 'nvzone/volt',
      config = function()
         local floaterm = require('floaterm')
         local pct = 0.85
         floaterm.setup({
            delay = 300,
            env = { NO_FF = '1' },
            mappings = { toggle = '<C-t>', send = '<Leader>r' },
            sidebar_w = unit_width / 2,
            size = { h = pct, w = unit_width * 5, max_w = pct },
         })

         keymap(
            'n',
            '<Leader>jj',
            function() floaterm.send('jj st', { name = 'jj', persist = true }) end,
            { desc = 'Jujutsu' }
         )
      end,
   },

   --Sidekick
   {
      'folke/sidekick.nvim',
      keys = '<Leader>a',
      config = function()
         local sidekick = require('sidekick')
         sidekick.setup({
            cli = {
               picker = 'fzf-lua',
               mux = { enabled = true, backend = 'tmux', create = 'split', split = { size = 0.33 } },
            },
         })

         local cli = require('sidekick.cli')
         local nes = require('sidekick.nes')

         --stylua: ignore start
         keymap('n', '<leader>aa', function() cli.toggle({ filter = { cwd = true } }) end, { desc = 'Toggle CLI' })
         keymap('n', '<leader>as', function() cli.select({ filter = { installed = true } }) end, { desc = 'Select CLI' })
         keymap('n', '<Leader>ad', function() cli.close() end, { desc = 'Detach a CLI Session' })
         keymap('n', '<Leader>af', function() cli.send({ msg = '{file}' }) end, { desc = 'Send File' })
         keymap('x', '<Leader>av', function() cli.send({ msg = '{selection}' }) end, { desc = 'Send Visual Selection' })
         keymap('n', '<Leader>au', function() require('floaterm').send('npx --yes tokscale', { name = 'tokscale' }) end, { desc = 'See token usage' })
         keymap({ 'n', 'x' }, '<Leader>ap', function() cli.prompt() end, { desc = 'Select Prompt' })
         keymap({ 'n', 'x' }, '<Leader>at', function() cli.send({ msg = '{this}' }) end, { desc = 'Send This' })
         keymap('n', '<Tab>', function()
            if nes.have() then nes.jump(); nes.apply() else return '<Tab>' end
         end, { desc = 'Goto/Apply Next Edit Suggestion', expr = true })
         --stylua: ignore end
      end,
   },

   --Flash
   {
      'folke/flash.nvim',
      event = 'VeryLazy',
      ---@type Flash.Config
      opts = {
         modes = {
            search = { enabled = false },
            char = { highlight = { backdrop = false } },
         },
         label = { uppercase = false },
      },
      keys = {
         { 'gs', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
         { 'gS', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
         { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote Flash' },
         { 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter Search' },
      },
   },

   --Autopairs
   {
      'windwp/nvim-autopairs',
      event = 'InsertEnter',
      config = true,
   },

   --GuessIndent
   {
      'nmac427/guess-indent.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      config = true,
   },

   --Neogit
   {
      'NeogitOrg/neogit',
      keys = {
         {
            '<C-g>',
            function()
               local neogit = require('neogit')
               neogit[neogit.status.is_open() and 'close' or 'open']()
            end,
            desc = 'Neogit (toggle)',
         },
      },
      dependencies = {
         'nvim-lua/plenary.nvim',
         'esmuellert/codediff.nvim',
         'ibhagwan/fzf-lua',
      },
      opts = { graph_style = 'kitty', mappings = { status = { ['<c-t>'] = false } } },
   },

   --CodeDiff
   {
      'esmuellert/codediff.nvim',
      keys = {
         { '<Leader>gD', '<Cmd>CodeDiff<CR>', desc = 'CodeDiff' },
      },
      cmd = 'CodeDiff',
      dependencies = { 'MunifTanjim/nui.nvim' },
      config = function()
         require('codediff').setup({
            diff = {
               conflict_ours_position = 'right',
               cycle_hunks_across_files = true,
            },
            explorer = {
               auto_open_on_cursor = true,
            },
            keymaps = {
               view = {
                  stage_hunk = '<Leader>gs',
                  unstage_hunk = '<Leader>gu',
                  discard_hunk = '<Leader>gr',
                  next_hunk = ']h',
                  prev_hunk = '[h',
               },
            },
         })
      end,
   },

   --Neotree
   {
      'nvim-neo-tree/neo-tree.nvim',
      keys = {
         { '<leader>ft', '<Cmd>Neotree toggle filesystem left<CR>', desc = 'File Tree' },
         { '<leader>fo', '<Cmd>Neotree toggle document_symbols right<CR>', desc = 'File Outline' },
      },
      cmd = 'Neotree',
      branch = 'v3.x',
      dependencies = {
         'nvim-lua/plenary.nvim',
         'MunifTanjim/nui.nvim',
         'nvim-tree/nvim-web-devicons',
      },
      opts = {
         sources = {
            'filesystem',
            'document_symbols',
            'buffers',
         },
         default_component_configs = {
            indent = { indent_marker = '┊' },
         },
         window = {
            width = unit_width,
            mappings = {
               ['<tab>'] = 'toggle_node',
               ['<esc>'] = 'clear_filter',
            },
         },
         filesystem = {
            filtered_items = {
               children_inherit_highlights = false,
               hide_dotfiles = false,
               hide_by_name = { '.git', '.jj', '.venv' },
            },
            window = {
               mappings = {
                  ['Y'] = {
                     function(state) vim.fn.setreg('+', state.tree:get_node().path) end,
                     desc = 'copy path to clipboard',
                  },
               },
            },
         },
         document_symbols = {
            follow_cursor = true,
            window = {
               mappings = {
                  ['/'] = 'filter_as_you_type',
               },
            },
         },
         enable_git_status = true,
         enable_diagnostics = false,
         event_handlers = {
            {
               event = 'neo_tree_window_after_open',
               handler = function(_)
                  vim.cmd('wincmd =')
                  vim.schedule(function() require('neo-tree.sources.manager').refresh('filesystem') end)
               end,
            },
         },
         use_popups_for_input = false,
      },
   },

   --Snacks
   {
      'folke/snacks.nvim',
      config = function()
         local snacks = require('snacks')
         snacks.setup({
            image = { enabled = true },
            bigfile = { enabled = true },
            git = { enabled = true },
            gitbrowse = { enabled = true },
            dashboard = {
               enabled = true,
               sections = {
                  { section = 'header' },
                  { section = 'startup' },
               },
               preset = { header = neovim_logo },
            },
         })

         keymap('n', '<Leader>gb', snacks.git.blame_line, { desc = 'Blame' })
         keymap({ 'n', 'v' }, '<Leader>gB', snacks.gitbrowse.open, { desc = 'Browser' })

         autocmd('User', {
            pattern = 'SnacksDashboardOpened',
            callback = function()
               vim.fn.matchadd('SnacksDashboardHeaderAlt', '#')
               vim.fn.matchadd('WarningMsg', '⚡')
            end,
         })
         autocmd('User', {
            pattern = 'SnacksDashboardClosed',
            callback = function()
               vim.fn.clearmatches()
               if vim.o.columns >= 200 then vim.schedule(function() vim.cmd('Neotree show') end) end
            end,
         })
      end,
   },

   --Copilot
   {
      'zbirenbaum/copilot.lua',
      cmd = 'Copilot',
      keys = { { '<Leader>Tc', desc = 'Toggle Copilot' } },
      init = function() vim.g.copilot_enabled = false end,
      config = function()
         require('copilot').setup({
            suggestion = {
               enabled = true,
               auto_trigger = true,
               keymap = {
                  accept = '<S-Tab>',
                  accept_word = '<C-l>',
               },
            },
            panel = { enabled = false },
            server = { type = 'binary' },
         })
         keymap('n', '<Leader>Tc', function()
            vim.g.copilot_enabled = not vim.g.copilot_enabled
            vim.cmd('Copilot ' .. (vim.g.copilot_enabled and 'enable' or 'disable'))
            vim.notify('Copilot: ' .. (vim.g.copilot_enabled and 'Enabled' or 'Disabled'))
         end, { desc = 'Toggle Copilot' })
      end,
   },

   --WhichKey
   {
      'folke/which-key.nvim',
      event = 'VeryLazy',
      opts = {
         preset = 'helix',
         delay = 500,
         win = { title_pos = 'center' },
         triggers = {
            { '<auto>', mode = 'nixsoc' },
            { 'a', mode = { 'n', 'v' } },
         },
         icons = { mappings = false },
         spec = {
            { '<Leader>a', group = 'Agent' },
            { '<Leader>c', group = 'Code', mode = { 'n', 'x' } },
            { '<Leader>d', group = 'Debug' },
            { '<Leader>f', group = 'File' },
            { '<Leader>g', group = 'Git', mode = { 'n', 'v' } },
            { '<Leader>i', group = 'Info' },
            { '<Leader>j', group = 'Jujutsu' },
            { '<Leader>n', group = 'Notebook' },
            { '<Leader>s', group = 'Search' },
            { '<Leader>t', group = 'Neotest' },
            { '<Leader>S', group = 'Sessions' },
            { '<Leader>T', group = 'Toggle' },
         },
      },
   },
}

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                      Plugins: Language Support                       │
-- └──────────────────────────────────────────────────────────────────────┘

local language_plugins = {
   --Lspconfig
   {
      'neovim/nvim-lspconfig',
      config = function()
         keymap('n', '<Leader>is', '<Cmd>che vim.lsp<CR>', { desc = 'LSP' })

         autocmd('LspAttach', {
            group = augroup('lsp-attach', { clear = true }),
            callback = function(event)
               local fzf = require('fzf-lua')
               keymap('n', '<Leader>cd', fzf.lsp_definitions, { buffer = event.buf, desc = 'Code Definition' })
               keymap('n', '<Leader>cD', vim.lsp.buf.declaration, { buffer = event.buf, desc = 'Code Declaration' })
               keymap('n', '<Leader>cr', fzf.lsp_references, { buffer = event.buf, desc = 'Code References' })
               keymap('n', '<Leader>cv', vim.lsp.buf.rename, { buffer = event.buf, desc = 'Code Variable Rename' })
               keymap({ 'n', 'x' }, '<Leader>ca', fzf.lsp_code_actions, { buffer = event.buf, desc = 'Code Action' })
               -- <Leader>cf = Code Format (Conform)

               lsp_highlight_symbols(event)
               lsp_inlay_hints(event)
            end,
         })

         -- Custom per-server configs
         vim.lsp.config('clangd', { cmd = { 'clangd', '--fallback-style=llvm' } })
         vim.lsp.config('bashls', { filetypes = { 'bash', 'sh' } })
      end,
   },

   --Mason
   {
      'owallb/mason-auto-install.nvim',
      event = 'VeryLazy',
      dependencies = {
         { 'williamboman/mason.nvim', opts = { ui = { backdrop = 100 } } },
         { 'williamboman/mason-lspconfig.nvim', opts = { automatic_enable = lsps } },
         'neovim/nvim-lspconfig',
      },
      config = function()
         local to_package = require('mason-lspconfig.mappings').get_mason_map().lspconfig_to_package
         local packages = vim.list_extend(vim.tbl_map(function(s) return to_package[s] or s end, lsps), tools)
         require('mason-auto-install').setup({ packages = packages })
      end,
   },

   --Blink
   {
      'saghen/blink.cmp',
      event = 'VeryLazy',
      dependencies = {
         { 'saghen/blink.compat', version = '*' },
         'rafamadriz/friendly-snippets',
      },
      version = '1.*',
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
         cmdline = {
            enabled = true,
            keymap = {
               preset = 'cmdline',
               ['<CR>'] = { 'accept', 'fallback' },
               ['<Left>'] = false,
               ['<Right>'] = false,
            },
            sources = { 'lazydev', 'buffer', 'cmdline' },
            completion = {
               list = {
                  selection = {
                     preselect = false,
                     auto_insert = true,
                  },
               },
               menu = { auto_show = true },
               ghost_text = { enabled = false },
            },
         },
         enabled = function()
            if vim.tbl_contains({ 'gitcommit' }, vim.bo.filetype) then return false end
            return true
         end,
         completion = {
            menu = {
               auto_show = function(ctx) return ctx.mode ~= 'cmdline' end,
               draw = { components = { label = { width = { max = unit_width } } } },
            },
            documentation = {
               auto_show = true,
               auto_show_delay_ms = 50,
            },
         },
         keymap = {
            preset = 'enter',
            ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
            ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
            ['<Esc>'] = { function(cmp) cmp.hide() end, 'fallback' },
         },
         appearance = {
            use_nvim_cmp_as_default = true,
            nerd_font_variant = 'mono',
         },
         sources = {
            default = function()
               local sources = { 'lazydev', 'lsp', 'path', 'snippets' }
               local cmp_dap = package.loaded.cmp_dap
               if cmp_dap ~= nil and cmp_dap.is_dap_buffer() then
                  table.insert(sources, 'dap')
               else
                  table.insert(sources, 'buffer')
               end
               return sources
            end,
            providers = {
               dap = { name = 'dap', module = 'blink.compat.source' },
               lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
            },
         },
      },
   },

   --Conform
   {
      'stevearc/conform.nvim',
      keys = '<Leader>cf',
      init = function() vim.g.format_on_save = false end,
      config = function()
         require('conform').setup({
            notify_on_error = false,
            format_on_save = function(_)
               if not vim.g.format_on_save then return end
               return { timeout_ms = 500, lsp_format = 'fallback' }
            end,
            formatters_by_ft = formatters_by_ft,
         })
         local disabled_filetypes = { 'toml' }

         keymap({ 'n', 'v' }, '<Leader>cf', function()
            if vim.tbl_contains(disabled_filetypes, vim.bo.filetype) then return end
            require('conform').format({ async = true, lsp_format = 'fallback' })
         end, { desc = 'Code Format Buffer/Selection' })

         keymap('n', '<Leader>Tf', function()
            vim.g.format_on_save = not vim.g.format_on_save
            vim.notify('Format On Save: ' .. tostring(vim.g.format_on_save))
         end, { desc = 'Toggle Format On Save' })
         keymap('n', '<Leader>ic', '<Cmd>ConformInfo<CR>', { desc = 'Conform' })
      end,
   },

   --Lint
   {
      'mfussenegger/nvim-lint',
      event = 'VeryLazy',
      config = function()
         local lint = require('lint')
         lint.linters_by_ft = linters_by_ft
         lint.linters.markdownlint.args = { '--disable', 'MD013', '--' }

         autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
            group = augroup('lint', { clear = true }),
            callback = function()
               if vim.bo.modifiable then lint.try_lint() end
            end,
         })
      end,
   },

   --Neotest
   {
      'nvim-neotest/neotest',
      keys = '<Leader>t',
      dependencies = {
         'nvim-neotest/nvim-nio',
         'nvim-treesitter/nvim-treesitter',
         'nvim-neotest/neotest-python',
      },
      config = function()
         local neotest = require('neotest')
         neotest.setup({
            adapters = {
               require('neotest-python')({}),
            },
            summary = { open = unit_width .. 'vsplit' },
            output = { open_on_run = false },
         })

         -- Keymaps
         keymap('n', '<Leader>tr', function() neotest.run.run() end, { desc = 'Neotest Run' })
         keymap('n', '<Leader>tl', function() neotest.run.run_last() end, { desc = 'Neotest Run Last' })
         keymap('n', '<Leader>tf', function() neotest.run.run(vim.fn.expand('%')) end, { desc = 'Neotest Run File' })
         keymap('n', '<Leader>ta', function() neotest.run.run({ suite = true }) end, { desc = 'Neotest Run All' })
         keymap('n', '<Leader>tw', function() neotest.watch.toggle() end, { desc = 'Neotest Watch' })
         keymap('n', '<Leader>to', function() neotest.output.open({ enter = true }) end, { desc = 'Neotest Output' })
         keymap('n', '<Leader>ts', function() neotest.summary.toggle() end, { desc = 'Neotest Summary' })
         keymap('n', ']n', function() neotest.jump.next({ status = 'failed' }) end, { desc = 'Neotest Next' })
         keymap('n', '[n', function() neotest.jump.prev({ status = 'failed' }) end, { desc = 'Neotest Previous' })

         autocmd('FileType', {
            pattern = { 'neotest-output', 'neotest-summary' },
            callback = function() vim.wo.wrap = false end,
         })
      end,
   },

   --VenvSelector
   {
      'linux-cultist/venv-selector.nvim',
      dependencies = { 'ibhagwan/fzf-lua' },
      ft = 'python',
      keys = { { '<Leader>v', '<Cmd>VenvSelect<CR>', desc = 'Select Python Venv' } },
      opts = {
         options = {
            on_venv_activate_callback = function()
               local venv = require('venv-selector').venv()
               if venv and venv ~= '' then
                  vim.notify(' activated: ' .. vim.fn.fnamemodify(venv, ':t'), vim.log.levels.INFO)
               end
            end,
            on_fd_result_callback = function(filename)
               return filename:gsub(os.getenv('HOME'), '~'):gsub('/bin/python', '')
            end,
         },
      },
   },

   --Jupynvim
   {
      'sheng-tse/jupynvim',
      event = { 'BufReadCmd *.ipynb', 'BufNewFile *.ipynb' },
      build = function(plugin)
         local install = loadfile(plugin.dir .. '/lua/jupynvim/install.lua')()
         install.run(plugin)
      end,
      config = function()
         require('jupynvim').setup({
            image_rows = unit_width * 0.5,
            image_cols = unit_width * 1.5,
         })
      end,
   },

   --Rustaceanvim
   {
      'mrcjkb/rustaceanvim',
      version = '^8',
      ft = 'rust',
   },

   --Lazydev
   {
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
         library = {
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
         },
      },
   },

   --RenderMarkdown
   {
      'MeanderingProgrammer/render-markdown.nvim',
      ft = { 'markdown' },
      keys = { { '<Leader>Tm', '<Cmd>RenderMarkdown toggle<CR>', desc = 'Toggle Markdown Rendering' } },
      dependencies = {
         'nvim-treesitter/nvim-treesitter',
         'nvim-tree/nvim-web-devicons',
      },
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {
         sign = { enabled = false },
         heading = {
            width = 'block',
            right_pad = 1,
         },
         code = {
            width = 'block',
            min_width = unit_width * 2,
            right_pad = 1,
            priority = 120,
         },
         file_types = { 'markdown' },
      },
   },

   --LivePreview
   {
      'brianhuster/live-preview.nvim',
      cmd = 'LivePreview',
   },

   --Dap
   {
      'mfussenegger/nvim-dap',
      keys = '<Leader>d',
      dependencies = {
         'rcarriga/cmp-dap',
         {
            'igorlfs/nvim-dap-view',
            opts = {
               winbar = { default_section = 'repl' },
               windows = { terminal = { position = 'right' } },
            },
         },
         'Weissle/persistent-breakpoints.nvim',
         'williamboman/mason.nvim',
         'jay-babu/mason-nvim-dap.nvim',
         'mfussenegger/nvim-dap-python',
      },
      config = function()
         local dap = require('dap')
         local dv = require('dap-view')
         local widgets = require('dap.ui.widgets')
         local pb = require('persistent-breakpoints.api')

         require('persistent-breakpoints').setup({
            load_breakpoints_event = { 'BufReadPost' },
         })

         keymap('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
         keymap('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
         keymap('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
         keymap('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
         keymap('n', '<F4>', dap.run_to_cursor, { desc = 'Debug: Run to cursor' })

         keymap('n', '<Leader>db', pb.toggle_breakpoint, { desc = 'Toggle Breakpoint' })
         keymap('n', '<Leader>dB', pb.set_conditional_breakpoint, { desc = 'Set Conditional Breakpoint' })
         keymap('n', '<Leader>dl', pb.set_log_point, { desc = 'Set Log Point' })
         keymap('n', '<Leader>dd', pb.clear_all_breakpoints, { desc = 'Delete Breakpoints' })

         keymap('n', '<Leader>dc', dap.continue, { desc = 'Continue Session.' })
         keymap('n', '<Leader>dt', dap.terminate, { desc = 'Terminate Session.' })
         keymap('n', '<Leader>dr', dap.restart, { desc = 'Restart Session.' })
         keymap('n', '<Leader>dv', dv.toggle, { desc = 'View Toggle ' })

         keymap('n', '<Leader>ds', function() widgets.centered_float(widgets.scopes) end, { desc = 'Debug Scope' })
         keymap(
            'n',
            '<Leader>dk',
            function() widgets.hover(nil, { border = 'none' }) end,
            { desc = 'Debug Symbol (Keywordprog)' }
         )

         require('mason-nvim-dap').setup({
            automatic_installation = true,
            ensure_installed = {
               'python',
            },
            handlers = {},
         })

         -- Dap View setup
         dap.defaults.fallback.switchbuf = 'usevisible,useopen,uselast'

         local breakpoint_icons = {
            Breakpoint = '',
            BreakpointCondition = '',
            BreakpointRejected = '',
            LogPoint = '',
            Stopped = '→',
         }
         for type, icon in pairs(breakpoint_icons) do
            local tp = 'Dap' .. type
            local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
            vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
         end

         dap.listeners.before.attach['dap-view-config'] = dv.open
         dap.listeners.before.launch['dap-view-config'] = dv.open
         dap.listeners.before.event_terminated['dap-view-config'] = dv.close
         dap.listeners.before.event_exited['dap-view-config'] = dv.close

         -- Python specific config
         require('dap-python').setup(
            vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'packages', 'debugpy', 'venv', 'bin', 'python')
         )
      end,
   },
}

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                             Plugins: UI                              │
-- └──────────────────────────────────────────────────────────────────────┘

local ui_plugins = {
   --TintedOscColors
   {
      'fsiraj/tinted-osc-colors.nvim',
      dev = false,
      priority = 1000,
      lazy = false,
      opts = {
         highlights = {
            overrides = function(base)
               local palette = get_palette(base)
               return generate_nvim_overrides(palette)
            end,
         },
         extra_colors = { accent = 22 },
      },
   },

   --Lualine
   {
      'nvim-lualine/lualine.nvim',
      event = 'VeryLazy',
      dependencies = {
         'nvim-tree/nvim-web-devicons',
         'folke/noice.nvim',
      },
      config = function()
         -- Custom components
         local copilot_icon = ' '
         local mode = {
            function() return string.upper(vim.api.nvim_get_mode().mode) end,
         }
         local branch = { 'branch', icon = '' }
         local tabs = {
            'tabs',
            cond = function() return vim.fn.tabpagenr('$') > 1 end,
            show_modified_status = false,
         }
         local lsp_status = {
            'lsp_status',
            icon = '󱚠 ',
            ignore_lsp = { 'copilot' },
            symbols = { done = '' },
         }
         local dap_status = {
            function() return require('dap').status() end,
            icon = { ' ', color = { fg = get_hl_attr('DapBreak', 'fg') } },
            cond = function()
               if not package.loaded.dap then return false end
               return require('dap').session() ~= nil
            end,
         }
         local python_venv = {
            function()
               return vim.fn.fnamemodify(require('venv-selector').venv(), ':t') ---@diagnostic disable-line: param-type-mismatch
            end,
            icon = '',
            cond = function()
               if not package.loaded['venv-selector'] or vim.bo.filetype ~= 'python' then return false end
               local venv = require('venv-selector').venv()
               return venv ~= nil and venv ~= ''
            end,
         }
         local noice = require('noice')
         ---@diagnostic disable: undefined-field
         local showmode = {
            noice.api.status.mode.get,
            cond = noice.api.status.mode.has,
            color = 'lualine_a_replace',
         }
         local showcmd = {
            noice.api.status.command.get,
            cond = noice.api.status.command.has,
         }
         ---@diagnostic enable: undefined-field
         local text = function(t)
            return function() return t end
         end
         local empty = text(' ')
         local copilot_status = {
            text(copilot_icon),
            color = function()
               local status = require('sidekick.status').get()
               if status then
                  return status.kind == 'Error' and 'DiagnosticError' or status.busy and 'DiagnosticWarn' or 'Special'
               end
            end,
            cond = function()
               local ok, status = pcall(require, 'sidekick.status')
               return ok and status.get() ~= nil
            end,
         }
         -- Custom extensions
         local minimal = {
            winbar = { lualine_b = { 'filetype' }, lualine_c = { empty } },
            inactive_winbar = { lualine_a = { 'filetype' }, lualine_c = { empty } },
            filetypes = {
               'checkhealth',
               'codediff-explorer',
               'dap-view-term',
               'gitcommit',
               'neo-tree',
               'neotest-summary',
               'noice',
               'qf',
            },
         }
         local terminal = {
            winbar = {
               lualine_a = { text('Terminal') },
               lualine_y = { showcmd },
            },
            filetypes = { 'terminal' },
         }
         -- Lualine config
         require('lualine').setup({
            options = {
               icons = true,
               theme = 'tinted-osc-colors',
               section_separators = { left = '', right = '' },
               component_separators = { left = '•', right = '•' },
               disabled_filetypes = {
                  winbar = {
                     'dap-repl',
                     'dap-view',
                     'snacks_dashboard',
                     'toggleterm',
                  },
               },
            },
            extensions = { minimal, terminal },
            sections = {},
            inactive_sections = {},
            winbar = {
               lualine_a = { mode, 'filename' },
               lualine_b = { branch, 'diff', 'diagnostics' },
               lualine_c = { tabs, python_venv, dap_status },
               lualine_x = { showmode, copilot_status },
               lualine_y = { showcmd, 'filetype' },
               lualine_z = { lsp_status },
            },
            inactive_winbar = {
               lualine_a = { 'filename' },
               lualine_c = { empty },
            },
         })
      end,
   },

   --Noice
   {
      'folke/noice.nvim',
      event = 'VeryLazy',
      dependencies = { 'MunifTanjim/nui.nvim' },
      config = function()
         local winhighlight = winhl({ NormalFloat = 'NormalFloat', FloatBorder = 'FloatBorder' })
         local views = {
            mini = {
               timeout = 2000,
               align = 'message_left',
               size = { width = unit_width, max_height = math.floor(vim.o.lines / 2) },
               reverse = false,
               position = { row = 0, col = '100%' },
               zindex = 200,
               win_options = { winhighlight = winhighlight, winblend = 0, wrap = true, linebreak = true },
            },
            cmdline_popup = {
               size = { min_width = unit_width, max_width = unit_width * 2 },
               border = { style = 'none', padding = { 1, 2 } },
               filter_options = {},
               win_options = { winhighlight = winhighlight, wrap = true },
            },
            cmdline_input = {
               border = { style = 'solid', padding = { 0, 2 } },
            },
            confirm = {
               position = { row = '50%' },
            },
            recents = {
               view = 'popup',
               size = { width = unit_width * 2, height = '80%' },
               border = { text = { top = ' Notifications ' } },
               win_options = { winhighlight = winhighlight, wrap = true, linebreak = true },
            },
         }
         local routes = {
            {
               filter = { event = 'msg_show', kind = { 'shell_out', 'shell_err' } },
               opts = { level = 'info', skip = false, replace = false },
               view = 'notify',
            },
         }
         local commands = {
            recents = {
               opts = { enter = true, format = { '{level} ', '{title} ', '{cmdline}', '\n', '{message}', '\n' } },
               view = 'recents',
               filter_opts = { reverse = true },
               filter = {
                  cond = function(m) return m.kind ~= 'search_cmd' end,
                  any = { { event = 'notify' }, { event = 'msg_show' }, { error = true }, { warning = true } },
               },
            },
         }

         require('noice').setup({
            cmdline = { enabled = true, format = {} },
            messages = { enabled = true },
            notify = { enabled = true },
            popupmenu = { enabled = false },
            lsp = {
               progress = { enabled = false },
               hover = { enabled = true },
               signature = { enabled = true },
               override = {
                  ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                  ['vim.lsp.util.stylize_markdown'] = true,
               },
            },
            views = views,
            routes = routes,
            commands = commands,
         })

         require('noice.ui.state').skip = function() return false end

         local function scroll(direction)
            local delta = direction == 'down' and 4 or -4
            local fallback = direction == 'down' and '10<C-d>' or '10<C-u>'
            if not require('noice.lsp').scroll(delta) then return fallback end
         end

         keymap('n', '<Leader>in', '<Cmd>Noice dismiss<CR><Cmd>Noice recents<CR>', { desc = 'Notifications' })
         keymap({ 'n', 'i', 's' }, '<C-d>', function() return scroll('down') end, { silent = true, expr = true })
         keymap({ 'n', 'i', 's' }, '<C-u>', function() return scroll('up') end, { silent = true, expr = true })
      end,
   },

   --TinyGlimmer
   {
      'rachartier/tiny-glimmer.nvim',
      event = 'VeryLazy',
      priority = 10,
      config = function()
         local function animation(color)
            return {
               enabled = true,
               default_animation = {
                  name = 'fade',
                  settings = { from_color = color or get_hl_attr('@diff.plus', 'fg') },
               },
            }
         end

         require('tiny-glimmer').setup({
            overwrite = {
               yank = animation(get_hl_attr('CursorLineNr', 'fg')),
               paste = animation(),
               undo = animation(),
               redo = animation(),
            },
            animations = { fade = { min_duration = 1000, max_duration = 1000 } },
            hijack_ft_disabled = { 'snacks_dashboard', 'neo-tree' },
         })
      end,
   },

   --Foldtext
   {
      'OXY2DEV/foldtext.nvim',
      config = function()
         require('foldtext').setup({
            styles = {
               ts_expr = {
                  condition = function(_, window)
                     return vim.wo[window].foldmethod == 'expr'
                        and vim.wo[window].foldexpr == 'v:lua.vim.treesitter.foldexpr()'
                  end,
                  parts = {
                     { kind = 'bufline', delimiter = ' ... ', hl = '@comment' },
                     {
                        kind = 'section',
                        output = function()
                           local size = (vim.v.foldend - vim.v.foldstart) + 1
                           return {
                              { string.format(' |-> %d lines', size), 'FoldtextLines' },
                           }
                        end,
                     },
                  },
               },
            },
         })
         vim.opt.fillchars:append({ eob = ' ' })
      end,
   },

   --TinyDeviconsAutoColors
   {
      'rachartier/tiny-devicons-auto-colors.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      event = 'VeryLazy',
      config = function()
         local devicons = require('nvim-web-devicons')
         local autocolors = require('tiny-devicons-auto-colors')
         local originals = vim.deepcopy(devicons.get_icons())
         autocolors.setup({ autoreload = false, cache = { enabled = false } })
         autocmd('ColorScheme', {
            callback = function()
               devicons.set_icon(vim.deepcopy(originals))
               autocolors.apply()
            end,
         })
      end,
   },

   --TodoComments
   {
      'folke/todo-comments.nvim',
      event = 'VeryLazy',
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = { signs = false },
   },

   --HighlightColors
   {
      'brenoprata10/nvim-highlight-colors',
      event = 'VeryLazy',
      opts = {
         render = 'virtual',
         virtual_symbol = '',
         enable_named_colors = false,
         exclude_filetypes = { 'lazy' },
      },
   },

   --Wrapped
   {
      'aikhe/wrapped.nvim',
      dependencies = { 'nvzone/volt' },
      keys = { { '<leader>iw', '<Cmd>NvimWrapped<CR>', desc = 'NvimWrapped' } },
      cmd = 'NvimWrapped',
   },
}

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                            Plugins: Setup                            │
-- └──────────────────────────────────────────────────────────────────────┘

local specs = vim.iter({
   core_plugins,
   language_plugins,
   ui_plugins,
})
   :flatten()
   :totable()

require('lazy').setup(specs, {
   defaults = { version = nil },
   headless = { task = false },
   rocks = { enabled = false },
   ui = { backdrop = 100 },
   dev = {
      path = '~/nvim-plugins/',
      fallback = true,
   },
})
