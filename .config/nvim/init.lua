-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                               Options                                │
-- └──────────────────────────────────────────────────────────────────────┘

-- Colorscheme
vim.g.colorscheme = 'default'

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
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 99

-- UI
vim.opt.breakindent = true
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
vim.opt.wrap = true

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
local vim_tmux_dirs = { { 'h', 'L' }, { 'j', 'D' }, { 'k', 'U' }, { 'l', 'R' } }

local function move(dv, dt)
   local prev = vim.api.nvim_get_current_win()
   vim.cmd('wincmd ' .. dv)
   if prev == vim.api.nvim_get_current_win() and vim.env.TMUX then
      vim.fn.system({ 'tmux', 'select-pane', '-' .. dt })
   end
end

for _, dirs in ipairs(vim_tmux_dirs) do
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
keymap('n', 'ga', '<Cmd>e #<CR>', { desc = 'Toggle Buffer Alternative (#)' })

-- Splits
keymap('n', '<C-Bslash>', '<Cmd>vsp<CR>', { desc = 'Vertical split' })
keymap('n', '<C-->', '<Cmd>sp<CR>', { desc = 'Horizontal split' })

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
end, { desc = 'LSP: Toggle Diagnostics' })
keymap('n', '<Leader>cq', function() open_diagnostic_float(true) end, { desc = 'Focus diagnostic float' })

-- Find Replace
keymap('n', '<Leader>fr', ':%s/<C-r><C-w>/', { desc = 'Find Replace Word' })
keymap('v', '<Leader>fr', '"zy:%s/<C-r>z/', { desc = 'Find Replace Selection' })

-- <CR> expands abbreviations without needing to type <Space> or <Tab>
keymap('c', '<CR>', function() return vim.fn.getcmdtype() == ':' and '<C-]><CR>' or '<CR>' end, { expr = true })

-- :wqa works even when terminal buffers are open
keymap('ca', 'wqa', 'wa | qa')

-- Lazy
keymap('n', '<Leader>il', '<Cmd>Lazy<CR>', { desc = 'Lazy' })

-- Misc
keymap('n', '<Esc>', '<Cmd>nohlsearch<CR>')

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
   pattern = { 'terminal', 'sidekick_terminal', 'Floaterm' },
   group = augroup('terminal-click', { clear = true }),
   callback = function(args)
      keymap('n', '<LeftRelease>', function()
         if vim.fn.mode() == 'n' then vim.cmd('startinsert') end
      end, { buffer = args.buf, desc = 'Enter terminal mode on click' })
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

--- All supported colorschemes
local colorschemes = {
   'default',
   'github_dark_default',
   'github_light_default',
   'rose-pine-main',
   'rose-pine-moon',
   'rose-pine-dawn',
   'tokyonight-night',
   'tokyonight-storm',
   'tokyonight-moon',
   'tokyonight-day',
   'catppuccin-mocha',
   'catppuccin-macchiato',
   'catppuccin-frappe',
   'catppuccin-latte',
}

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
-- │                             UI: Helpers                              │
-- └──────────────────────────────────────────────────────────────────────┘

local get_hl = vim.api.nvim_get_hl

local function get_hl_attr(name, attr)
   local value = get_hl(0, { name = name, link = false })[attr]
   if (attr == 'fg' or attr == 'bg' or attr == 'sp') and type(value) == 'number' then
      return string.format('#%06x', value)
   end
   return value
end

local function tee(message, level)
   vim.notify(message, level or 'error')
   io.write(message .. '\n')
end

local sed_formatters = {
   -- Example: key = 'value'
   nvim = function(k, v) return ('-e "s|^%s = .*|%s = \'%s\'|"'):format(k, k, v) end,
   -- Example: key = value
   ghostty = function(k, v) return ('-e "s|^%s = .*|%s = %s|"'):format(k, k, v) end,
   -- Example: set -g @key "value"
   tmux = function(k, v) return ('-e "s|^set -g @%s \\".*\\"|set -g @%s \\"%s\\"|"'):format(k, k, v) end,
}

local function sed_format_for(path)
   for name, fmt in pairs(sed_formatters) do
      if path:find(name) then return fmt end
   end
end

local function winhl(links)
   return table.concat(vim.iter(links):map(function(from, to) return from .. ':' .. to end):totable(), ',')
end

local function override_winhl(pattern, hl)
   autocmd({ 'FileType', 'BufWinEnter' }, {
      pattern = pattern,
      callback = function(args)
         hl = hl or winhl({ Normal = 'NormalFloat' })
         vim.schedule(function()
            local win = vim.fn.bufwinid(args.buf)
            if win and win ~= -1 then vim.wo[win].winhl = hl end
         end)
      end,
   })
end

local function emit_cursor_color()
   local osc = string.format('\27]12;%s\7', get_hl_attr('Cursor', 'bg'))
   if vim.env.TMUX then osc = '\27Ptmux;' .. osc:gsub('\27', '\27\27') .. '\27\\' end
   io.stdout:write(osc)
end

local function lighten(color, pct)
   -- Negative pct darkens
   return require('volt.color').change_hex_lightness(color, pct)
end

local function light_or_dark(colorscheme)
   return vim.tbl_contains({
      'catppuccin-latte',
      'tokyonight-day',
      'rose-pine-dawn',
      'github_light_default',
   }, colorscheme) and 'light' or 'dark'
end

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                        UI: Palette Generation                        │
-- └──────────────────────────────────────────────────────────────────────┘

local function get_palette(colorscheme)
   local palette
   --stylua: ignore start
   if string.find(colorscheme, 'catppuccin') then
      local flavor = vim.fn.split(colorscheme, '-')[2]
      local p = require('catppuccin.palettes').get_palette(flavor)
      palette = {
         accent  = p.mauve,
         text    = p.text,
         base    = p.base,
         mantle  = p.mantle,
         subtext = p.subtext0,
         black   = p.surface1,
         white   = p.text,
         red     = p.red,
         orange  = p.peach,
         yellow  = p.yellow,
         green   = p.green,
         cyan    = p.teal,
         blue    = p.blue,
         magenta = p.mauve,
      }
   elseif string.find(colorscheme, 'tokyonight') then
      local flavor = vim.fn.split(colorscheme, '-')[2]
      local p = require('tokyonight.colors.' .. flavor)
      if type(p) == 'function' then p = p({}) end
      palette = {
         accent  = p.cyan,
         text    = p.fg,
         base    = p.bg,
         mantle  = p.bg_dark,
         subtext = p.comment,
         black   = p.terminal_black,
         white   = p.fg,
         red     = p.magenta2,
         orange  = p.orange,
         yellow  = p.yellow,
         green   = p.teal,
         cyan    = p.cyan,
         blue    = p.blue,
         magenta = p.magenta,
      }
   elseif string.find(colorscheme, 'rose') then
      local p = require('rose-pine.palette')
      palette = {
         accent  = p.rose,
         text    = p.text,
         base    = p.base,
         mantle  = p.surface,
         subtext = p.subtle,
         black   = p.overlay,
         white   = p.text,
         red     = p.love,
         orange  = p.gold,
         yellow  = p.gold,
         green   = p.leaf,
         cyan    = p.foam,
         blue    = p.pine,
         magenta = p.iris,
      }
   elseif string.find(colorscheme, 'github') then
      local p = require('github-theme.palette').load(colorscheme)
      palette = {
         accent  = p.accent.fg,
         text    = p.fg.default,
         base    = p.canvas.default,
         mantle  = p.canvas.overlay,
         subtext = p.fg.subtle,
         black   = p.gray.base or p.black.base,
         white   = p.fg.default,
         red     = p.red.base,
         orange  = p.orange,
         yellow  = p.yellow.base,
         green   = p.green.base,
         cyan    = p.cyan.base,
         blue    = p.blue.base,
         magenta = p.magenta.base,
      }
   elseif colorscheme == 'default' then
      local p = vim.api.nvim_get_color_map()
      palette = {
         accent  = p.NvimLightCyan,
         text    = p.NvimLightGrey2,
         base    = p.NvimDarkGrey2,
         mantle  = p.NvimDarkGrey1,
         subtext = p.NvimLightGrey4,
         black   = p.NvimDarkGrey3,
         white   = p.NvimLightGrey2,
         red     = p.NvimLightRed,
         orange  = p.Orange,
         yellow  = p.NvimLightYellow,
         green   = p.NvimLightGreen,
         cyan    = p.NvimLightCyan,
         blue    = p.NvimLightBlue,
         magenta = p.NvimLightMagenta,
      }
   else
      error('Unsupported colorscheme: ' .. tostring(colorscheme))
   end
   --stylua: ignore end
   for k, v in pairs(palette) do
      if type(v) == 'number' then palette[k] = string.format('#%06x', v) end
   end
   return palette
end

local function generate_ansi_palette(p)
   local pct = 5
   local black = vim.o.background == 'dark' and p.mantle or p.text
   local white = vim.o.background == 'dark' and p.text or p.mantle
   return {
      black,
      p.red,
      p.green,
      p.yellow,
      p.blue,
      p.magenta,
      p.cyan,
      white,
      lighten(black, pct * 4),
      lighten(p.red, pct),
      lighten(p.green, pct),
      lighten(p.yellow, pct),
      lighten(p.blue, pct),
      lighten(p.magenta, pct),
      lighten(p.cyan, pct),
      lighten(white, pct),
   }
end

local function generate_ghostty_theme(p)
   local cursor_bg = get_hl_attr('Cursor', 'bg')
   local cursor_fg = get_hl_attr('Cursor', 'fg')
   local theme = {
      ['background'] = p.base,
      ['foreground'] = p.text,
      ['cursor-color'] = cursor_bg,
      ['cursor-text'] = cursor_fg,
      ['selection-background'] = p.subtext,
      ['selection-foreground'] = p.text,
   }
   for i, c in ipairs(generate_ansi_palette(p)) do
      theme['palette = ' .. (i - 1)] = c
   end
   return theme
end

local function generate_tmux_theme(p)
   --stylua: ignore
   return {
      thm_accent   = p.accent,
      thm_base     = p.base,
      thm_fg       = p.text,
      thm_green    = p.green,
      thm_inactive = p.subtext,
      thm_mantle   = p.mantle,
      thm_magenta  = p.magenta,
      thm_orange   = p.orange,
   }
end

local function generate_nvim_overrides(p)
   --stylua: ignore
   return {
      -- Neovim Built-in
      CursorLine                  = { bg = 'NONE' },
      CursorLineNr                = { fg = p.accent },
      FloatBorder                 = { fg = p.mantle, bg = p.mantle },
      FloatTitle                  = { fg = p.mantle, bg = p.accent, bold = true },
      Folded                      = { bg = p.base },
      Normal                      = { fg = p.text, bg = p.base },
      NormalFloat                 = { bg = p.mantle },
      NormalNC                    = { link = 'Normal' },
      Pmenu                       = { link = 'NormalFloat' },
      Special                     = { fg = p.cyan },
      StatusLine                  = { fg = p.base, bg = p.base },
      StatusLineNC                = { fg = p.base, bg = p.base },
      StatusLineTerm              = { link = 'StatusLine' },
      StatusLineTermNC            = { link = 'StatusLineNC' },
      WinSeparator                = { fg = p.mantle, bg = p.base },
      -- Plugins
      BlinkCmpDoc                 = { link = 'NormalFloat' },
      DapBreak                    = { fg = p.red },
      DapStop                     = { fg = p.yellow },
      FloatermActive              = { fg = p.accent },
      FzfLuaBorder                = { link = 'FloatBorder' },
      FzfLuaNormal                = { link = 'NormalFloat' },
      JupynvimBorder              = { link = 'Comment' },
      LazyButton                  = { bg = p.base },
      LazySpecial                 = { fg = p.accent },
      MiniIndentscopeSymbol       = { fg = p.accent },
      NeotestAdapterName          = { fg = p.accent, bold = true },
      NeotestDir                  = { fg = p.cyan },
      NeotestExpandMarker         = { fg = p.subtext },
      NeotestFailed               = { fg = p.red },
      NeotestFile                 = { fg = p.blue },
      NeotestFocused              = { fg = p.blue, bold = true, underline = true },
      NeotestIndent               = { fg = p.subtext },
      NeotestMarked               = { fg = p.orange, bold = true },
      NeotestNamespace            = { fg = p.magenta },
      NeotestPassed               = { fg = p.green },
      NeotestRunning              = { fg = p.yellow },
      NeotestSkipped              = { fg = p.subtext },
      NeotestTarget               = { fg = p.red },
      NeotestTest                 = { fg = p.subtext },
      NeotestUnknown              = { fg = p.subtext },
      NeotestWatching             = { fg = p.yellow },
      NeotestWinSelect            = { fg = p.cyan, bold = true },
      NeoTreeCursorLine           = { link = 'NeotreeNormal' },
      NeoTreeDirectoryIcon        = { fg = p.accent },
      NeoTreeGitConflict          = { link = '@diff.delta' },
      NeoTreeGitUntracked         = { link = '@diff.delta' },
      NeoTreeIndentMarker         = { link = 'NeoTreeDirectoryIcon' },
      NeoTreeNormalNC             = { link = 'NeotreeNormal' },
      NeotreeNormal               = { link = 'NormalFloat' },
      NoiceCmdlinePopupTitleInput = { link = 'FloatTitle' },
      NoiceConfirm                = { link = 'NormalFloat' },
      NoiceConfirmBorder          = { link = 'FloatBorder' },
      NvimDapViewTabFill          = { link = 'NormalFloat' },
      NvimDapViewTabSelected      = { bg = p.green, fg = p.base },
      OutlineCurrent              = { fg = p.accent, bold = true },
      SidekickChat                = { link = 'NormalFloat' },
      SidekickDiffAdd             = { link = 'DiffAdd' },
      SidekickDiffContext         = { bg = p.base },
      SidekickSign                = { fg = p.cyan },
      SnacksDashboardFooter       = { fg = p.subtext },
      SnacksDashboardHeader       = { fg = p.green },
      SnacksDashboardHeaderAlt    = { fg = p.blue },
      SnacksDashboardSpecial      = { fg = p.accent },
      TreesitterContext           = { bg = p.base },
      TreesitterContextSeparator  = { fg = p.accent, bg = p.base },
      WhichKeyBorder              = { link = 'FloatBorder' },
   }
end

local function generate_lualine_theme(p)
   return {
      normal = {
         a = { bg = p.accent, fg = p.mantle, gui = 'bold' },
         b = { bg = p.mantle, fg = p.text },
         c = { bg = p.base, fg = p.text },
         y = { bg = p.mantle, fg = p.text },
      },
      -- Missing sections default to normal mode settings
      insert = {
         a = { bg = p.cyan, fg = p.mantle, gui = 'bold' },
      },
      visual = {
         a = { bg = p.magenta, fg = p.mantle, gui = 'bold' },
      },
      command = {
         a = { bg = p.orange, fg = p.mantle, gui = 'bold' },
      },
      terminal = {
         a = { bg = p.orange, fg = p.mantle, gui = 'bold' },
      },
      replace = {
         a = { bg = p.red, fg = p.mantle, gui = 'bold' },
      },
      inactive = {
         a = { bg = p.mantle, fg = p.subtext },
         b = { bg = p.base, fg = p.subtext },
         c = { bg = p.base, fg = p.subtext },
      },
   }
end

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                           UI: Theme Sync                             │
-- └──────────────────────────────────────────────────────────────────────┘

local function run_sed_cmd(path, overrides)
   local fmt = sed_format_for(path)
   local sep = ' \\\n    '
   local exprs = table.concat(vim.iter(overrides):map(fmt):totable(), sep)
   local cmd = 'sed -i --follow-symlinks' .. sep .. '%s' .. sep .. '%s'
   cmd = string.format(cmd, exprs, path)
   vim.fn.system(cmd)
end

local function reload_ghostty() vim.system({ 'killall', '-SIGUSR2', 'ghostty' }) end

local function reload_tmux() vim.system({ 'tmux', 'source', vim.fn.expand('~/.config/tmux/tmux.conf') }) end

local function reload_nvim_servers()
   local servers = vim.fn.glob(vim.fn.fnamemodify(vim.fn.stdpath('run'), ':h') .. '/**/nvim.*', true, true)
   for _, addr in ipairs(servers) do
      if addr ~= vim.v.servername then
         --stylua: ignore
         vim.system({
            'nvim', '--server', addr, '--remote-send',
            '<Cmd>NvimSetTheme ' .. vim.g.colorscheme .. '<CR>',
         })
      end
   end
end

local function reload_nvim_plugins()
   local vim_notify = vim.notify
   vim.notify = function(...) end

   -- Plugins that work with Lazy's reload feature
   local plugins_to_reload = { 'fzf-lua', 'tiny-glimmer.nvim' }
   vim.iter(plugins_to_reload):each(function(p) vim.cmd('Lazy reload ' .. p) end)

   -- Lualine
   local config = require('lualine').get_config()
   config.options.theme = generate_lualine_theme(vim.g.palette)
   require('lualine').setup(config)

   vim.notify = vim_notify
end

local function set_theme(colorscheme)
   vim.g.colorscheme = colorscheme
   vim.opt.background = light_or_dark(colorscheme)
   vim.cmd.colorscheme(vim.g.colorscheme)
   reload_nvim_plugins()
   vim.schedule(emit_cursor_color)
end

local function sync_theme(colorscheme)
   -- Colorscheme is required
   if colorscheme == nil or colorscheme == '' then
      tee('Colorscheme not provided.')
      return
   end

   if not vim.tbl_contains(colorschemes, colorscheme) then
      tee('Colorscheme ' .. colorscheme .. ' not supported.')
      return
   end

   -- Updates this session, but not persistent
   tee('✨ Syncing colors to ' .. colorscheme .. '✨', 'info')
   set_theme(colorscheme)
   reload_nvim_servers() -- reloads *other* neovim instances (if any)

   -- Palette
   local p = get_palette(colorscheme)

   -- Nvim
   local nvim = '~/.config/nvim/init.lua'
   run_sed_cmd(nvim, { ['vim\\.g\\.colorscheme'] = vim.g.colorscheme })

   -- Ghostty
   if vim.fn.executable('ghostty') == 1 then
      local ghostty = '~/.config/ghostty/config.ghostty'
      local ghostty_overrides = generate_ghostty_theme(p)
      vim.g.__ghostty_theme = ghostty_overrides
      run_sed_cmd(ghostty, ghostty_overrides)
      reload_ghostty()
   end

   -- Tmux
   if vim.fn.executable('tmux') == 1 then
      local tmux = '~/.config/tmux/tmux.conf'
      local tmux_overrides = generate_tmux_theme(p)
      run_sed_cmd(tmux, tmux_overrides)
      reload_tmux()
   end
end

vim.api.nvim_create_user_command(
   'NvimSetTheme',
   function(opts) set_theme(opts.args) end,
   { nargs = 1, desc = 'Set the Neovim colorscheme and reload styled plugins' }
)

vim.api.nvim_create_user_command(
   'NvimSyncTheme',
   function(opts) sync_theme(opts.args) end,
   { nargs = 1, desc = 'Sync theme across Neovim, tmux, and ghostty' }
)

vim.api.nvim_create_user_command(
   'NvimColorschemes',
   function() vim.iter(colorschemes):each(print) end,
   { desc = 'Print supported colorschemes, one per line' }
)

local function apply_nvim_overrides(p)
   local hl_overrides = generate_nvim_overrides(p)
   for hl, col in pairs(hl_overrides) do
      vim.api.nvim_set_hl(0, hl, col)
   end
   for i, c in ipairs(generate_ansi_palette(p)) do
      vim.g['terminal_color_' .. (i - 1)] = c
   end
end

autocmd('ColorScheme', {
   callback = function()
      local p = get_palette(vim.g.colorscheme)
      vim.g.palette = vim.deepcopy(p)
      apply_nvim_overrides(p)
   end,
})

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                            Plugin Helpers                            │
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
   -- 'rust-analyzer' (handled by rustaceanvim)
}

local non_lsps = {
   'stylua',
   'debugpy',
   'markdownlint',
   'prettier',
   'shellcheck',
   'shfmt',
   'codelldb',
}

local all_tools = vim.iter({ lsps, non_lsps }):flatten():totable()

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
      end, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
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
   --Mini
   {
      'echasnovski/mini.nvim',
      dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
      config = function()
         -- Enhanced jump motions
         require('mini.jump').setup()

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
            mappings = {
               apply = '<Leader>gS',
               reset = '<Leader>gR',
            },
            view = {
               style = 'sign',
               priority = 5,
               signs = {
                  add = '▎',
                  change = '▎',
                  delete = '',
               },
            },
            options = { linematch = 0, wrap_goto = true },
         })
         keymap('n', '<Leader>gd', diff.toggle_overlay, { desc = 'Toggle Git Overlay' })
         keymap('n', '<Leader>gs', '<Leader>gSgh', { remap = true, desc = 'Stage hunk' })
         keymap('n', '<Leader>gr', '<Leader>gRgh', { remap = true, desc = 'Reset hunk' })

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

         vim.opt.sessionoptions:append('globals')
         vim.opt.sessionoptions:remove('terminal')
         vim.opt.sessionoptions:remove('blank')

         local function postread()
            if vim.g.SidekickTool ~= nil and vim.g.SidekickTool ~= '' then
               require('sidekick.cli').show({ name = vim.g.SidekickTool, focus = false, filter = { cwd = true } })
            end
            if vim.g.NeotreeOpen == 1 then vim.schedule(function() vim.cmd('Neotree show') end) end
         end

         local function prewrite()
            local term = require('sidekick.cli.terminal').sessions()[1]
            vim.g.SidekickTool = term and term.tool.name or ''
            vim.g.NeotreeOpen = vim.iter(vim.api.nvim_list_wins())
               :any(function(w) return vim.bo[vim.api.nvim_win_get_buf(w)].ft == 'neo-tree' end) and 1 or 0
            require('neogit').close()
            vim.cmd('helpclose')
         end

         sessions.setup({
            autowrite = true,
            force = { delete = true },
            hooks = {
               pre = { write = prewrite },
               post = { read = postread },
            },
         })

         local function session_name() return vim.fn.fnamemodify(vim.uv.cwd() or '', ':t') end

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
               vim.schedule(function() vim.cmd('Neotree show') end)
            end,
         })
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
            { '<Leader>i', group = 'Info' },
            { '<Leader>c', group = 'Code', mode = { 'n', 'x' } },
            { '<Leader>d', group = 'Debug' },
            { '<Leader>s', group = 'Search' },
            { '<Leader>S', group = 'Sessions' },
            { '<Leader>f', group = 'File' },
            { '<Leader>t', group = 'Neotest' },
            { '<Leader>T', group = 'Toggle' },
            { '<Leader>n', group = 'Notebook' },
            { '<Leader>g', group = 'Git', mode = { 'n', 'v' } },
            { '<Leader>r', group = 'Run' },
         },
      },
   },

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
               fd_opts = '--color=never --hidden --type f --type l --exclude .git --exclude .venv',
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
            },
            helptags = {
               actions = { ['enter'] = actions.help_vert },
            },
            grep = { hidden = true },
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
         ---@diagnostic disable: inject-field
         fzf.magic_colorschemes = function()
            return fzf.colorschemes({
               colors = colorschemes,
               live_preview = false,
               winopts = { width = unit_width, height = unit_width / 2, row = 0.5, col = 0.5 },
               actions = { ['enter'] = function(selected, _) sync_theme(selected[1]) end },
            })
         end
         fzf.nerdfont = function()
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
         fzf.plugins = function()
            local roots = { vim.fn.stdpath('data') .. '/lazy' }
            local dev = vim.fn.expand('~/nvim-plugins')
            if vim.uv.fs_stat(dev) then table.insert(roots, dev) end
            fzf.files({ search_paths = roots })
         end
         fzf.dotfiles = function() return fzf.files({ cwd = '~/dotfiles' }) end
         ---@diagnostic enable: inject-field

         keymap('n', '<Leader><Leader>', fzf.buffers, { desc = 'FzfLua: Open Buffers' })
         keymap('n', '<Leader>sb', fzf.builtin, { desc = 'FzfLua: Builtin' })
         keymap('n', '<Leader>sr', fzf.resume, { desc = 'FzfLua: Resume' })
         keymap('n', '<Leader>sf', fzf.files, { desc = 'FzfLua: Files' })
         keymap('n', '<Leader>so', fzf.oldfiles, { desc = 'FzfLua: Oldfiles' })
         keymap('n', '<Leader>sw', fzf.grep_cword, { desc = 'FzfLua: Current Word' })
         keymap('n', '<Leader>sg', fzf.live_grep, { desc = 'FzfLua: Grep' })
         keymap('n', '<Leader>sh', fzf.helptags, { desc = 'FzfLua: Help' })
         keymap('n', '<Leader>sH', fzf.highlights, { desc = 'FzfLua: Highlights' })
         keymap('n', '<Leader>sk', fzf.keymaps, { desc = 'FzfLua: Keymaps' })
         keymap('v', '<Leader>ss', fzf.grep_visual, { desc = 'FzfLua: Selection' })
         keymap('n', '<Leader>sd', fzf.dotfiles, { desc = 'FzfLua: Dotfiles' })
         keymap('n', '<Leader>sp', fzf.plugins, { desc = 'FzfLua: Plugins' })
         keymap('n', '<Leader>sc', fzf.magic_colorschemes, { desc = 'FzfLua: Magic Colorschemes' })
         keymap('n', '<Leader>si', fzf.nerdfont, { desc = 'FzfLua: Nerd Font Icons' })
         keymap('n', '<Leader>st', '<Cmd>TodoFzfLua<CR>', { desc = 'FzfLua: Search Todos' })
         keymap('n', '<Leader>ss', '<Cmd>Namu symbols<CR>', { desc = 'FzfLua: Search Symbols Buffer' })
         keymap('n', '<Leader>sS', '<Cmd>Namu workspace<CR>', { desc = 'FzfLua: Search Symbols Workspace' })
         keymap('n', '<Leader>sq', '<Cmd>Namu diagnostics<CR>', { desc = 'FzfLua: Search Diagnostics' })
         keymap('n', '<Leader>/', fzf.lgrep_curbuf, { desc = 'FzfLua: Current Buffer' })

         -- Patch fzf-lua to be circular-safe. This prevents a stack overflow
         -- when using ui_select with complex objects (like Sidekick's).
         local utils = require('fzf-lua.utils')
         utils.tbl_deep_clone = function(t, seen)
            if type(t) ~= 'table' then return t end
            seen = seen or {}
            if seen[t] then return seen[t] end
            local clone = {}
            seen[t] = clone
            for k, v in pairs(t) do
               clone[k] = utils.tbl_deep_clone(v, seen)
            end
            return clone
         end
      end,
   },

   --Namu
   {
      'bassamsdata/namu.nvim',
      cmd = { 'Namu' },
      opts = {
         namu_symbols = {
            options = {
               display = { mode = 'icon', format = 'tree_guides' },
               window = { relative = 'win' },
            },
         },
      },
   },

   --Treesitter
   {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      config = function()
         local treesitter = require('nvim-treesitter')
         local supported = vim.list_extend(treesitter.get_available(1), treesitter.get_available(2))
         local excluded = { 'tmux' }
         autocmd('FileType', {
            callback = function(args)
               local lang = vim.bo[args.buf].filetype
               if vim.tbl_contains(supported, lang) and not vim.tbl_contains(excluded, lang) then
                  local installed = treesitter.get_installed()
                  if not vim.tbl_contains(installed, lang) then
                     treesitter.install(lang)
                     return
                  end
                  vim.treesitter.start(args.buf, lang)
                  vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                  vim.wo.foldmethod = 'expr'
                  vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
               end
            end,
         })
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
}

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                     Plugins: Editing & Workflow                      │
-- └──────────────────────────────────────────────────────────────────────┘

local utility_plugins = {
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
               conflict_ours_position = 'left',
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
         override_winhl({ 'codediff-explorer', 'codediff-help' })
      end,
   },

   --Copilot
   {
      'zbirenbaum/copilot.lua',
      cmd = 'Copilot',
      keys = '<Leader>Tc',
      build = ':Copilot auth',
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
            vim.notify('Copilot: ' .. tostring(vim.g.copilot_enabled))
         end, { desc = 'Toggle Copilot' })
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
               mux = { enabled = true, backend = 'tmux' },
               tools = { claude = { native_scroll = true } },
               win = {
                  split = { width = 0 },
                  wo = { winfixwidth = false },
               },
            },
         })

         local session = require('sidekick.cli.session')
         local sid = session.sid
         session.sid = function(opts) return '_' .. sid(opts) end

         local terminal = require('sidekick.cli.terminal')
         terminal.keys = function() end
         terminal.fix_cursorline = function() end

         local cli = require('sidekick.cli')
         local nes = require('sidekick.nes')

         --stylua: ignore start
         keymap('n', '<leader>aa', function() cli.toggle({ filter = { cwd = true } }) end, { desc = 'Toggle CLI' })
         keymap('n', '<leader>as', function() cli.select({ filter = { installed = true } }) end, { desc = 'Select CLI' })
         keymap('n', '<Leader>ad', function() cli.close() end, { desc = 'Detach a CLI Session' })
         keymap('n', '<Leader>af', function() cli.send({ msg = '{file}' }) end, { desc = 'Send File' })
         keymap('x', '<Leader>av', function() cli.send({ msg = '{selection}' }) end, { desc = 'Send Visual Selection' })
         keymap('n', '<Leader>au', function() require('floaterm').send('npx --yes tokscale', 'tokscale') end, { desc = 'See token usage' })
         keymap({ 'n', 'x' }, '<Leader>ap', function() cli.prompt() end, { desc = 'Select Prompt' })
         keymap({ 'n', 'x' }, '<Leader>at', function() cli.send({ msg = '{this}' }) end, { desc = 'Send This' })
         keymap('n', '<Tab>', function()
            if nes.have() then nes.jump(); nes.apply() else return '<Tab>' end
         end, { desc = 'Goto/Apply Next Edit Suggestion', expr = true })
         --stylua: ignore end

         local function tui_tool(buf)
            local tool = vim.b[buf].sidekick_cli or vim.w[vim.api.nvim_get_current_win()].sidekick_cli
            return tool and vim.tbl_contains({ 'claude', 'opencode' }, tool.name)
         end

         local function scroll_wheel(dir)
            local r, c = unpack(vim.api.nvim_win_get_position(0))
            local h, w = vim.fn.winheight(0), vim.fn.winwidth(0)
            r, c = r + math.floor(h / 2), c + math.floor(w / 2)
            for _ = 1, 3 do
               vim.api.nvim_input_mouse('wheel', dir, '', 0, r, c)
            end
         end

         -- Much better ergonomics in TUIs
         autocmd('FileType', {
            pattern = { 'sidekick_terminal' },
            group = augroup('sidekick-scroll', { clear = true }),
            callback = function(args)
               local buf = args.buf
               vim.schedule(function()
                  if not tui_tool(buf) then return end
                  keymap('t', '<C-u>', function() scroll_wheel('up') end, { buffer = buf })
                  keymap('t', '<C-d>', function() scroll_wheel('down') end, { buffer = buf })
                  keymap('n', '<ScrollWheelUp>', function() vim.cmd('startinsert') end, { buffer = buf })
                  keymap('n', '<ScrollWheelDown>', function() vim.cmd('startinsert') end, { buffer = buf })
               end)
            end,
         })

         override_winhl(
            'sidekick_terminal',
            winhl({
               Normal = 'SidekickChat',
               NormalNC = 'SidekickChat',
               EndOfBuffer = 'SidekickChat',
               SignColumn = 'SidekickChat',
            })
         )
      end,
   },

   --Floaterm
   {
      'fsiraj/floaterm',
      dev = true,
      keys = { '<C-t>', '<Leader>r' },
      dependencies = 'nvzone/volt',
      config = function()
         local floaterm = require('floaterm')
         local pct = 0.85
         floaterm.setup({
            size = { h = pct, w = unit_width * 5, max_w = pct },
            mappings = { toggle = '<C-t>', send = '<Leader>rc' },
            sidebar_w = unit_width / 2,
            contrast = 5
         })

         keymap('n', '<Leader>rb', function() floaterm.send('btop') end, { desc = 'Run Btop' })
      end,
   },

   --Outline
   {
      'hedyhli/outline.nvim',
      keys = {
         { '<leader>fo', '<cmd>Outline<CR>', desc = 'File Outline' },
      },
      opts = {
         outline_window = {
            split_command = unit_width .. 'vsplit',
            winhl = winhl({ Normal = 'NormalFloat' }),
         },
         outline_items = { show_symbol_details = false },
         preview_window = { winhl = winhl({ NormalFloat = 'NormalFloat' }) },
         keymaps = { close = { 'q' } },
      },
   },

   --Neotree
   {
      'nvim-neo-tree/neo-tree.nvim',
      keys = {
         { '<leader>ft', '<Cmd>Neotree toggle<CR>', desc = 'File Tree' },
      },
      cmd = 'Neotree',
      branch = 'v3.x',
      dependencies = {
         'nvim-lua/plenary.nvim',
         'MunifTanjim/nui.nvim',
         'nvim-tree/nvim-web-devicons',
      },
      opts = {
         default_component_configs = {
            indent = { indent_marker = '┊' },
         },
         filesystem = {
            filtered_items = {
               children_inherit_highlights = false,
               always_show = { '.config' },
            },
         },
         enable_git_status = true,
         enable_diagnostics = false,
         window = { width = unit_width },
         event_handlers = {
            {
               event = 'neo_tree_window_after_open',
               handler = function(_) vim.cmd('wincmd =') end,
            },
         },
      },
   },

   --Wrapped
   {
      'aikhe/wrapped.nvim',
      dependencies = { 'nvzone/volt' },
      keys = { { '<leader>iw', '<Cmd>NvimWrapped<CR>', desc = 'NvimWrapped' } },
      cmd = { 'NvimWrapped' },
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
               keymap('n', '<Leader>cd', fzf.lsp_definitions, { buffer = event.buf, desc = 'LSP: Code Definition' })
               keymap(
                  'n',
                  '<Leader>cD',
                  vim.lsp.buf.declaration,
                  { buffer = event.buf, desc = 'LSP: Code Declaration' }
               )
               keymap('n', '<Leader>cr', fzf.lsp_references, { buffer = event.buf, desc = 'LSP: Code References' })
               keymap('n', '<Leader>cv', vim.lsp.buf.rename, { buffer = event.buf, desc = 'LSP: Code Variable Rename' })
               keymap(
                  { 'n', 'x' },
                  '<Leader>ca',
                  fzf.lsp_code_actions,
                  { buffer = event.buf, desc = 'LSP: Code Action' }
               )
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
      'williamboman/mason.nvim',
      lazy = true,
      keys = { { '<Leader>im', '<Cmd>Mason<CR>', desc = 'Mason' } },
      config = true,
   },
   {
      'williamboman/mason-lspconfig.nvim',
      lazy = true,
      dependencies = {
         'williamboman/mason.nvim',
         'saghen/blink.cmp',
      },
      opts = { automatic_enable = lsps },
   },
   {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      event = 'VeryLazy',
      cmd = 'MasonToolsUpdateSync',
      dependencies = {
         'williamboman/mason.nvim',
         'williamboman/mason-lspconfig.nvim',
      },
      config = function()
         local mti = require('mason-tool-installer')
         mti.setup({ ensure_installed = all_tools })
         mti.check_install()
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
            local disabled_filetypes = { 'gitcommit' }
            if vim.tbl_contains(disabled_filetypes, vim.bo.filetype) then return false end
            if vim.bo.buftype ~= 'prompt' then return true end
            local cmp_dap = package.loaded.cmp_dap
            return cmp_dap ~= nil and cmp_dap.is_dap_buffer()
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
      event = 'VeryLazy',
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
               if vim.opt_local.modifiable:get() then lint.try_lint() end
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
         'nvim-lua/plenary.nvim',
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
            callback = function(args)
               keymap('n', 'q', '<Cmd>:q<CR>', { buffer = args.buf, desc = 'Close Window' })
               vim.wo.wrap = false
            end,
         })
         override_winhl('neotest-summary')
      end,
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

   --MarkdownPreview
   {
      'iamcco/markdown-preview.nvim',
      cmd = {
         'MarkdownPreviewToggle',
         'MarkdownPreview',
         'MarkdownPreviewStop',
      },
      ft = { 'markdown' },
      build = function(plugin) vim.cmd('!cd ' .. plugin.dir .. ' && cd app && npx --yes yarn install') end,
      init = function()
         if vim.fn.executable('npx') then vim.g.mkdp_filetypes = { 'markdown' } end
      end,
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

         autocmd('FileType', {
            pattern = { 'dap-float' },
            callback = function(event) keymap('n', 'q', '<C-w>q', { silent = true, buffer = event.buf }) end,
         })

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
            Stopped = '',
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
-- │                        Plugins: Colorschemes                         │
-- └──────────────────────────────────────────────────────────────────────┘

local colorscheme_plugins = {
   --Catppuccin
   {
      'catppuccin/nvim',
      name = 'catppuccin',
      opts = {
         flavour = 'mocha',
         default_integrations = true,
         auto_integrations = true,
      },
   },

   --Tokyonight
   {
      'folke/tokyonight.nvim',
      opts = { style = 'night', plugins = { auto = true } },
   },

   --RosePine
   {
      'rose-pine/neovim',
      name = 'rose-pine',
      opts = { variant = 'main' },
   },

   --Github
   {
      'projekt0n/github-nvim-theme',
      name = 'github-theme',
   },
}

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                             Plugins: UI                              │
-- └──────────────────────────────────────────────────────────────────────┘

local ui_plugins = {
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
         local diff = {
            'diff',
            diff_color = {
               added = function() return { fg = get_hl_attr('@diff.plus', 'fg') } end,
               modified = function() return { fg = get_hl_attr('@diff.delta', 'fg') } end,
               removed = function() return { fg = get_hl_attr('@diff.minus', 'fg') } end,
            },
         }
         local branch = { 'branch', icon = '' }
         local tabs = {
            'tabs',
            cond = function() return #vim.fn.gettabinfo() > 1 end,
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
            icon = { ' ', color = { fg = vim.g.palette.red } },
            cond = function()
               if not package.loaded.dap then return false end
               return require('dap').session() ~= nil
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
         local copilot_status = {
            function() return copilot_icon end,
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
         local sidekick_cli_name = function()
            local win = vim.api.nvim_get_current_win()
            local buf = vim.api.nvim_win_get_buf(win)
            local cli = vim.b[buf].sidekick_cli or vim.w[win].sidekick_cli
            return cli.name:gsub('^%l', string.upper)
         end

         -- Custom extensions
         local minimal = {
            winbar = { lualine_b = { 'filetype' } },
            inactive_winbar = { lualine_a = { 'filetype' } },
            filetypes = {
               'Outline',
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
            inactive_winbar = {
               lualine_a = { text('Terminal') },
               lualine_c = { text(' ') },
            },
            filetypes = { 'terminal' },
         }
         local sidekick = {
            winbar = {
               lualine_a = { sidekick_cli_name },
               lualine_z = { text(copilot_icon) },
            },
            filetypes = { 'sidekick_terminal' },
         }
         sidekick.inactive_winbar = vim.deepcopy(sidekick.winbar)

         -- Lualine config
         require('lualine').setup({
            options = {
               icons = true,
               theme = generate_lualine_theme(vim.g.palette),
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
            extensions = { minimal, terminal, sidekick },
            sections = {},
            inactive_sections = {},
            winbar = {
               lualine_a = { mode, 'filename' },
               lualine_b = { branch, diff, 'diagnostics' },
               lualine_c = { tabs, dap_status },
               lualine_x = { showmode, copilot_status },
               lualine_y = { showcmd, 'filetype' },
               lualine_z = { lsp_status },
            },
            inactive_winbar = {
               lualine_a = { 'filename' },
               lualine_c = { text(' ') },
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
               position = { row = 2, col = '100%' },
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
               filter_opts = { count = 100, reverse = true },
               filter = {
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
                  settings = { from_color = color or vim.g.palette.green },
               },
            }
         end

         require('tiny-glimmer').setup({
            overwrite = {
               yank = animation(vim.g.palette.accent),
               paste = animation(),
               undo = animation(),
               redo = animation(),
            },
            animations = { fade = { min_duration = 1000, max_duration = 1000 } },
            hijack_ft_disabled = { 'snacks_dashboard', 'neo-tree' },
         })
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

   --Foldtext
   {
      'OXY2DEV/foldtext.nvim',
      event = 'VeryLazy',
      config = function()
         require('foldtext').setup({
            styles = {
               ts_expr = {
                  condition = function(_, window)
                     return vim.wo[window].foldmethod == 'expr'
                        and vim.wo[window].foldexpr == 'v:lua.vim.treesitter.foldexpr()'
                  end,
                  parts = {
                     {
                        kind = 'section',
                        output = function()
                           local size = (vim.v.foldend - vim.v.foldstart) + 1
                           return {
                              { string.format('%3d lines |-> ', size), 'MiniIndentscopeSymbol' },
                           }
                        end,
                     },
                     { kind = 'bufline', delimiter = ' ... ', hl = '@comment' },
                  },
               },
            },
         })
         vim.opt.fillchars:append({ eob = ' ' })
      end,
   },
}

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │                            Plugins: Setup                            │
-- └──────────────────────────────────────────────────────────────────────┘

local specs = vim.iter({
   core_plugins,
   utility_plugins,
   language_plugins,
   colorscheme_plugins,
   ui_plugins,
})
   :flatten()
   :totable()

require('lazy').setup(specs, {
   defaults = { version = nil },
   headless = { task = false },
   dev = {
      path = '~/nvim-plugins/',
      fallback = true,
   },
})
vim.cmd.colorscheme(vim.g.colorscheme)
