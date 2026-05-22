local M = {}

--- Dashboard Header
M.neovim_logo = [[
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

--- To make UIs multiples of consistent width
M.unit_width = 40

--- All supported colorschemes
M.colorschemes = {
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
   'nord',
   'everforest',
}

M.colorscheme_plugins = {
   --Catppuccin
   {
      'catppuccin/nvim',
      lazy = false,
      name = 'catppuccin',
      opts = {
         flavor = 'mocha',
         default_integrations = true,
         integrations = {
            -- Most common plugins enabled by default
            noice = true,
            which_key = true,
            mason = true,
            blink_cmp = true,
            neotest = true,
         },
      },
   },
   --Tokyonight
   {
      'folke/tokyonight.nvim',
      lazy = false,
      opts = { style = 'night', plugins = { auto = true } },
   },
   --RosePine
   {
      'rose-pine/neovim',
      lazy = false,
      name = 'rose-pine',
      opts = { variant = 'main' },
   },
   --Nord
   {
      'shaunsingh/nord.nvim',
      lazy = false,
      name = 'nord',
   },
   --Everforest
   {
      'neanias/everforest-nvim',
      lazy = false,
      main = 'everforest',
      opts = {
         background = 'hard',
         on_highlights = function(hl, palette) hl.Normal = { bg = palette.bg_dim } end,
      },
   },
   --Github
   {
      'projekt0n/github-nvim-theme',
      lazy = false,
      name = 'github-theme',
   },
}

--- Uncategorized helpers

local function tee(message, level)
   vim.notify(message, level or 'error')
   io.write(message .. '\n')
end

local function num_to_hex(palette)
   for k, v in pairs(palette) do
      if type(v) == 'number' then palette[k] = string.format('#%06x', v) end
   end
   return palette
end

--- Generate a consistent neovim palette from colorscheme plugins

local function palette_is_valid(palette)
   local required_keys = {
      'accent',
      'text',
      'base',
      'mantle',
      'subtext',
      'black',
      'white',
      'red',
      'orange',
      'yellow',
      'green',
      'teal',
      'blue',
      'mauve',
      'pink',
   }
   for _, key in ipairs(required_keys) do
      if palette[key] == nil then
         tee('Palette is missing ' .. key)
         return false
      end
   end
   return true
end

local function get_palette(colorscheme)
   local palette
   if string.find(colorscheme, 'catppuccin') then
      local flavor = vim.fn.split(colorscheme, '-')[2]
      local p = require('catppuccin.palettes').get_palette(flavor)
      palette = {
         accent = p.mauve,
         text = p.text,
         base = p.base,
         mantle = p.mantle,
         subtext = p.subtext0,
         black = p.surface1,
         white = p.text,
         red = p.red,
         orange = p.peach,
         yellow = p.yellow,
         green = p.green,
         teal = p.teal,
         blue = p.blue,
         mauve = p.mauve,
         pink = p.pink,
      }
   elseif string.find(colorscheme, 'tokyonight') then
      local flavor = vim.fn.split(colorscheme, '-')[2]
      local p = require('tokyonight.colors.' .. flavor)
      if type(p) == 'function' then p = p({}) end
      palette = {
         accent = p.cyan,
         text = p.fg,
         base = p.bg,
         mantle = p.bg_dark,
         subtext = p.comment,
         black = p.terminal_black,
         white = p.fg,
         red = p.magenta2,
         orange = p.orange,
         yellow = p.yellow,
         green = p.teal,
         teal = p.cyan,
         blue = p.blue,
         mauve = p.magenta,
         pink = '#ea76cb',
      }
   elseif string.find(colorscheme, 'rose') then
      local p = require('rose-pine.palette')
      palette = {
         accent = p.rose,
         text = p.text,
         base = p.base,
         mantle = p.surface,
         subtext = p.subtle,
         black = p.overlay,
         white = p.text,
         red = p.love,
         orange = p.gold,
         yellow = p.gold,
         green = p.leaf,
         teal = p.foam,
         blue = p.pine,
         mauve = p.iris,
         pink = p.rose,
      }
   elseif colorscheme == 'nord' then
      local p = require('nord.named_colors')
      palette = {
         accent = p.glacier,
         text = p.darkest_white,
         base = p.black,
         mantle = p.dark_gray,
         subtext = p.light_gray_bright,
         black = p.dark_gray,
         white = p.darkest_white,
         red = p.red,
         orange = p.orange,
         yellow = p.yellow,
         green = p.green,
         teal = p.teal,
         blue = p.blue,
         mauve = p.purple,
         pink = '#ebbcba',
      }
   elseif colorscheme == 'everforest' then
      local p = require('everforest.colours').generate_palette(
         ---@diagnostic disable-next-line: missing-fields
         { background = 'hard', colours_override = function(_) end },
         'dark'
      )
      palette = {
         accent = p.green,
         text = p.fg,
         base = p.bg_dim,
         mantle = p.bg2,
         subtext = p.grey1,
         black = p.grey0,
         white = p.fg,
         red = p.red,
         orange = p.orange,
         yellow = p.yellow,
         green = p.green,
         teal = p.aqua,
         blue = p.blue,
         mauve = p.purple,
         pink = '#ebbcba',
      }
   elseif string.find(colorscheme, 'github') then
      local p = require('github-theme.palette').load(colorscheme)
      return {
         accent = p.accent.fg,
         text = p.fg.default,
         base = p.canvas.default,
         mantle = p.canvas.overlay,
         subtext = p.fg.subtle,
         black = p.gray.base or p.black.base,
         white = p.fg.default,
         red = p.red.base,
         orange = p.orange,
         yellow = p.yellow.base,
         green = p.green.base,
         teal = p.cyan.base,
         blue = p.blue.base,
         mauve = p.magenta.base,
         pink = p.pink.base,
      }
   else
      palette = {
         accent = vim.api.nvim_get_hl(0, { name = 'Keyword' }).fg,
         text = vim.api.nvim_get_hl(0, { name = 'Normal' }).fg,
         base = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg,
         mantle = vim.api.nvim_get_hl(0, { name = 'NormalFloat' }).bg,
         red = vim.api.nvim_get_hl(0, { name = 'ErrorMsg' }).fg,
         yellow = vim.api.nvim_get_hl(0, { name = 'WarningMsg' }).fg,
      }
   end
   return num_to_hex(palette)
end

--- Generate themes for other apps from Neovim's palette

local function generate_ghostty_theme(p)
   return {
      ['palette = 0'] = p.black,
      ['palette = 1'] = p.red,
      ['palette = 2'] = p.green,
      ['palette = 3'] = p.yellow,
      ['palette = 4'] = p.blue,
      ['palette = 5'] = p.mauve,
      ['palette = 6'] = p.teal,
      ['palette = 7'] = p.text,
      ['palette = 8'] = p.subtext,
      ['palette = 9'] = p.red,
      ['palette = 10'] = p.green,
      ['palette = 11'] = p.yellow,
      ['palette = 12'] = p.blue,
      ['palette = 13'] = p.mauve,
      ['palette = 14'] = p.teal,
      ['palette = 15'] = p.text,
      ['background'] = p.base,
      ['foreground'] = p.text,
      ['cursor-color'] = p.text,
      ['cursor-text'] = p.base,
      ['selection-background'] = p.subtext,
      ['selection-foreground'] = p.text,
   }
end

local function generate_tmux_theme(p)
   return {
      thm_accent = p.accent,
      thm_base = p.base,
      thm_fg = p.text,
      thm_green = p.green,
      thm_inactive = p.subtext,
      thm_mantle = p.mantle,
      thm_mauve = p.mauve,
      thm_orange = p.orange,
   }
end

local function generate_omp_theme(p)
   return {
      green = p.green,
      mauve = p.mauve,
      pink = p.pink,
      red = p.red,
      subtext = p.subtext,
      teal = p.teal,
   }
end

local function generate_nvim_overrides(p)
   return {
      -- Neovim Built-in
      CursorLineNr = { fg = p.accent },
      FloatBorder = { fg = p.mantle, bg = p.mantle },
      FloatTitle = { fg = p.mantle, bg = p.accent, bold = true },
      NormalFloat = { bg = p.mantle },
      NormalNC = { link = 'Normal' },
      Pmenu = { link = 'NormalFloat' },
      Special = { fg = p.teal },
      StatusLine = { fg = p.base, bg = p.base },
      StatusLineNC = { fg = p.base, bg = p.base },
      StatusLineTerm = { link = 'StatusLine' },
      StatusLineTermNC = { link = 'StatusLineNC' },
      -- Plugins
      BlinkCmpDoc = { link = 'NormalFloat' },
      DapBreak = { fg = p.red },
      DapStop = { fg = p.yellow },
      FzfLuaBorder = { link = 'FloatBorder' },
      FzfLuaNormal = { link = 'NormalFloat' },
      MiniIndentscopeSymbol = { fg = p.accent },
      NeoTreeCursorLine = { link = 'NeotreeNormal' },
      NeoTreeNormalNC = { link = 'NeotreeNormal' },
      NeotreeNormal = { link = 'NormalFloat' },
      NoiceCmdlinePopupTitleInput = { link = 'FloatTitle' },
      NoiceConfirm = { link = 'NormalFloat' },
      NoiceConfirmBorder = { link = 'FloatBorder' },
      NvimDapViewTabSelected = { bg = p.green, fg = p.base },
      NvimDapViewTabFill = { link = 'NormalFloat' },
      SidekickChat = { link = 'Normal' },
      SidekickDiffAdd = { link = 'DiffAdd' },
      SidekickDiffContext = { bg = p.base },
      SidekickSign = { fg = p.teal },
      SnacksDashboardFooter = { fg = p.subtext },
      SnacksDashboardHeader = { fg = p.green },
      SnacksDashboardHeaderSecondary = { fg = p.blue },
      SnacksDashboardSpecial = { fg = p.accent },
      TreesitterContext = { bg = p.base },
      TreesitterContextBottom = { sp = p.accent, underline = true },
      WhichKeyBorder = { link = 'FloatBorder' },
   }
end

local function generate_lualine_theme(p)
   return {
      normal = {
         a = { bg = p.accent, fg = p.mantle, gui = 'bold' },
         b = { bg = p.mantle, fg = p.subtext },
         c = { bg = p.base, fg = p.text },
         y = { bg = p.mantle, fg = p.text },
      },
      -- Missing sections default to normal mode settings
      insert = {
         a = { bg = p.teal, fg = p.mantle, gui = 'bold' },
      },
      visual = {
         a = { bg = p.mauve, fg = p.mantle, gui = 'bold' },
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

--- Functions that wrap sed to overwrite config files for all the apps

local function sed_expr(var, val, filepath)
   -- Example: set -g @key "value" (tmux)
   if string.find(filepath, 'tmux') then
      return string.format([[ -e "s|^set -g @%s \".*\"|set -g @%s \"%s\"|"]], var, var, val)
   -- Example: ␣␣␣␣"key": "value" (opencode tui.jsonc)
   elseif string.find(filepath, 'jsonc') then
      return string.format([[ -e "s|^    \"%s\": \".*\"|    \"%s\": \"%s\"|"]], var, var, val)
   -- Examples: key = value (ghostty), key = 'value' (nvim/oh-my-posh)
   else
      local quote = string.find(filepath, 'ghostty') and '' or "'"
      return string.format([[ -e "s|^%s = .*|%s = %s%s%s|"]], var, var, quote, val, quote)
   end
end

local function run_sed_cmd(path, overrides)
   local sed = vim.fn.executable('gsed') == 1 and 'gsed' or 'sed' -- Mac or Linux
   local exprs = {}
   for var, val in pairs(overrides) do
      table.insert(exprs, sed_expr(var, val, path))
   end
   local exprs_string = table.concat(exprs, ' \\\n      ')
   local cmd = string.format('%s -i --follow-symlinks%s \\\n%s', sed, exprs_string, path)
   vim.fn.system(cmd)
end

--- Functions to reload apps and plugins, enabling live updates of entire IDE

local function reload_ghostty()
   -- Mac
   if vim.uv.os_uname().sysname == 'Darwin' then
      vim.system({ 'pkill', '-SIGUSR2', '-a', 'ghostty' })
      return
   end
   -- Linux
   vim.system({ 'pkill', '-SIGUSR2', 'ghostty' })
end

local function reload_tmux() vim.system({ 'tmux', 'source', vim.env.HOME .. '/.config/tmux/tmux.conf' }) end

local function reload_oh_my_posh()
   vim.system({ 'oh-my-posh', 'enable', 'reload' })
   vim.defer_fn(function() vim.system({ 'oh-my-posh', 'disable', 'reload' }) end, 2500)
end

local function reload_nvim_servers()
   local servers = vim.fn.glob(vim.fn.fnamemodify(vim.fn.stdpath('run'), ':h') .. '/**/nvim.*', true, true)
   for _, addr in ipairs(servers) do
      if addr ~= vim.v.servername then
            --stylua: ignore
            vim.system({
                'nvim', '--server', addr, '--remote-send',
                "<Cmd>lua require('ui').set_theme('" .. vim.g.colorscheme .. "')<CR>",
            })
      end
   end
end

local function reload_nvim_plugins()
   local vim_notify = vim.notify
   vim.notify = function(...) end ---@diagnostic disable-line

   -- Plugins that work with Lazy's reload feature
   local plugins_to_reload = { 'fzf-lua', 'tiny-glimmer.nvim', 'lualine.nvim' }
   for _, plugin in ipairs(plugins_to_reload) do
      vim.cmd('Lazy reload ' .. plugin)
   end

   -- Floaterm
   package.loaded['volt.highlights'] = nil
   require('volt.highlights')

   vim.notify = vim_notify
end

--- Putting together all the magic

--- Sets the theme for this neovim instance
function M.set_theme(colorscheme)
   vim.g.colorscheme = colorscheme
   vim.cmd('colorscheme ' .. colorscheme)
   reload_nvim_plugins()
end

--- Syncs the theme across neovim, oh-my-posh, tmux, and ghostty.
function M.sync_theme(colorscheme)
   -- Colorscheme is required
   if colorscheme == nil or colorscheme == '' then
      tee('Colorscheme not provided.')
      return
   end

   if not vim.tbl_contains(M.colorschemes, colorscheme) then
      tee('Colorscheme ' .. colorscheme .. ' not supported.')
      return
   end

   -- Palette
   local p = get_palette(colorscheme)
   if not palette_is_valid(p) then return end
   tee('Syncing colors to ' .. colorscheme .. '...', 'info')

   -- Updates this session, but not persistent
   M.set_theme(colorscheme)
   reload_nvim_servers() -- reloads *other* neovim instances (if any)

   -- Nvim
   local nvim = '~/.config/nvim/init.lua'
   run_sed_cmd(nvim, { ['vim\\.g\\.colorscheme'] = vim.g.colorscheme })

   -- Ghostty
   if vim.fn.executable('ghostty') == 1 then
      local ghostty = '~/.config/ghostty/config'
      local ghostty_overrides = generate_ghostty_theme(p)
      vim.g.__ghostty_theme = ghostty_overrides
      run_sed_cmd(ghostty, ghostty_overrides)
      reload_ghostty()
   end

   -- OhMyPosh
   if vim.fn.executable('oh-my-posh') == 1 then
      local omp = '~/.config/ohmyposh/config.omp.toml'
      local omp_overrides = generate_omp_theme(p)
      run_sed_cmd(omp, omp_overrides)
      reload_oh_my_posh()
   end

   -- Tmux
   if vim.fn.executable('tmux') == 1 then
      local tmux = '~/.config/tmux/tmux.conf'
      local tmux_overrides = generate_tmux_theme(p)
      run_sed_cmd(tmux, tmux_overrides)
      reload_tmux()
   end
end

--- Sets up an autocmd to override neovim highlights based on the current colorscheme.
function M.setup_hl_autocmd()
   vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function()
         local p = get_palette(vim.g.colorscheme)
         vim.g.palette = vim.deepcopy(p)
         local hl_overrides = generate_nvim_overrides(p)
         for hl, col in pairs(hl_overrides) do
            vim.api.nvim_set_hl(0, hl, col)
         end
      end,
   })
end

--- Plugin tweaks

function M.get_lualine_theme() return generate_lualine_theme(vim.g.palette) end

function M.colorize_snacks_dashboard()
   vim.api.nvim_create_autocmd('User', {
      pattern = 'SnacksDashboardOpened',
      callback = function()
         vim.cmd('match SnacksDashboardHeaderSecondary /#/')
         vim.cmd('2match WarningMsg /⚡/')
         vim.keymap.set('n', 'r', '<Leader>Sr', { buffer = true, remap = true, desc = 'Session Restore' })
         vim.b.miniindentscope_disable = true
      end,
   })
   vim.api.nvim_create_autocmd('User', {
      pattern = 'SnacksDashboardClosed',
      callback = function()
         vim.cmd('match none')
         vim.cmd('2match none')
      end,
   })
end

function M.tiny_glimmer_animation(color)
   return {
      enabled = true,
      default_animation = {
         name = 'fade',
         settings = { from_color = color or vim.g.palette.green },
      },
   }
end

function M.set_buffer_normal_autocmds()
   local function override_winhl(pattern, hl)
      vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
         pattern = pattern,
         callback = function(args)
            vim.schedule(function()
               local win = vim.fn.bufwinid(args.buf)
               if win and win ~= -1 then vim.wo[win].winhl = hl or 'Normal:NormalFloat' end
            end)
         end,
      })
   end

   -- NormalFloat
   override_winhl({ 'codediff-explorer', 'codediff-help', 'neotest-summary' })

   -- Sidekick
   override_winhl(
      'sidekick_terminal',
      'Normal:SidekickChat,NormalNC:SidekickChat,EndOfBuffer:SidekickChat,SignColumn:SidekickChat'
   )

   -- Floaterm
   vim.api.nvim_create_autocmd('TermOpen', {
      desc = 'Set Floaterm Normal',
      callback = function(args)
         local bo = vim.bo[args.buf]
         if bo.filetype == 'Floaterm' then
            local state = require('floaterm.state')
            if state.volt_set then vim.wo[state.win].winhl = 'Normal:exdarkbg,floatBorder:exdarkborder' end
         end
      end,
   })
end

M.ui_plugins = {
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
         local branch = { 'branch', icon = '', color = { fg = vim.g.palette.text } }
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
            icon = { ' ', color = { fg = vim.g.palette.red } },
            cond = function()
               if not package.loaded.dap then return false end
               return require('dap').session() ~= nil
            end,
         }
         local noice = require('noice')
         local showmode = {
            noice.api.status.mode.get, ---@diagnostic disable-line
            cond = noice.api.status.mode.has, ---@diagnostic disable-line
         }
         local showcmd = {
            noice.api.status.command.get, ---@diagnostic disable-line
            cond = noice.api.status.command.has, ---@diagnostic disable-line
         }
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

         -- Custom extensions

         -- Minimal
         local minimal = {
            winbar = { lualine_b = { 'filetype' } },
            inactive_winbar = { lualine_a = { 'filetype' } },
            filetypes = {
               'Outline',
               'checkhealth',
               'codediff-explorer',
               'dap-view-term',
               'neo-tree',
               'neotest-summary',
               'noice',
               'qf',
            },
         }

         -- Terminal (No filetype)
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

         -- Sidekick
         local sidekick_cli_name = function()
            local win = vim.api.nvim_get_current_win()
            local buf = vim.api.nvim_win_get_buf(win)
            local cli = vim.b[buf].sidekick_cli or vim.w[win].sidekick_cli
            return cli.name:gsub('^%l', string.upper)
         end

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
               theme = M.get_lualine_theme(),
               section_separators = { left = '', right = '' },
               component_separators = { left = '|', right = '|' },
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
               lualine_b = { branch, 'diff', 'diagnostics' },
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
            views = {
               mini = {
                  timeout = 5000,
                  size = { max_width = M.unit_width * 2 },
                  reverse = false,
                  position = { row = 1, col = '100%' },
                  win_options = {
                     winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
                     winblend = 0,
                  },
               },
               cmdline_popup = {
                  size = {
                     min_width = M.unit_width,
                     max_width = M.unit_width * 2,
                  },
                  border = { style = 'none', padding = { 1, 2 } },
                  filter_options = {},
                  win_options = {
                     winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
                     wrap = true,
                  },
               },
               cmdline_input = {
                  border = { style = 'solid', padding = { 0, 2 } },
               },
               confirm = {
                  position = { row = '50%' },
               },
            },
            routes = {
               {
                  filter = {
                     event = 'msg_show',
                     kind = { 'shell_out', 'shell_err' },
                  },
                  view = 'notify',
                  opts = {
                     level = 'info',
                     skip = false,
                     replace = false,
                  },
               },
            },
         })

         vim.keymap.set({ 'n', 'i', 's' }, '<C-d>', function()
            if not require('noice.lsp').scroll(4) then return '10<C-d>' end
         end, { silent = true, expr = true })
         vim.keymap.set({ 'n', 'i', 's' }, '<C-u>', function()
            if not require('noice.lsp').scroll(-4) then return '10<C-u>' end
         end, { silent = true, expr = true })

         vim.keymap.set('n', '<Leader>ii', function()
            vim.cmd('NoiceAll')
            vim.schedule(function()
               for _, win in ipairs(vim.api.nvim_list_wins()) do
                  local buf = vim.api.nvim_win_get_buf(win)
                  if vim.bo[buf].filetype == 'noice' then
                     vim.api.nvim_set_current_win(win)
                     vim.api.nvim_win_call(win, function() vim.cmd('normal! Gzb') end)
                     break
                  end
               end
            end)
         end, { desc = 'Messages' })
      end,
   },

   --TinyGlimmer
   {
      'rachartier/tiny-glimmer.nvim',
      event = 'VeryLazy',
      priority = 10,
      config = function()
         require('tiny-glimmer').setup({
            overwrite = {
               yank = M.tiny_glimmer_animation(vim.g.palette.accent),
               paste = M.tiny_glimmer_animation(),
               undo = M.tiny_glimmer_animation(),
               redo = M.tiny_glimmer_animation(),
            },
            animations = {
               fade = { min_duration = 1000, max_duration = 1000 },
            },
         })
      end,
   },

   --TinyDeviconsAutoColors
   {
      'rachartier/tiny-devicons-auto-colors.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      event = 'VeryLazy',
      config = function() require('tiny-devicons-auto-colors').setup({ autoreload = false }) end,
   },

   --Foldtext
   {
      'OXY2DEV/foldtext.nvim',
      lazy = false,
      opts = {
         styles = {
            ts_expr = {
               condition = function(_, window)
                  return vim.wo[window].foldmethod == 'expr'
                     and vim.wo[window].foldexpr == 'v:lua.vim.treesitter.foldexpr()'
               end,
               parts = {
                  { kind = 'bufline', delimiter = ' ... ', hl = '@comment' },
                  {
                     kind = 'fold_size',
                     padding_left = ' ',
                     padding_right = ' lines',
                     icon = ' <-| ',
                     hl = 'MiniIndentscopeSymbol',
                  },
               },
            },
         },
      },
   },
}

return M
