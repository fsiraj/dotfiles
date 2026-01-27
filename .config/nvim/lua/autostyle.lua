local M = {}

--- All supported colorschemes
M.colorschemes = {
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
    'github_dark_default',
    'github_light_default',
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

--- Only these OS are supported

local on_ubuntu = vim.fn.executable('apt') == 1
local on_arch = vim.fn.executable('pacman') == 1
local on_mac = vim.fn.executable('brew') == 1

--- Generate a consistent neovim palette from colorscheme plugins

local function validate_palette(palette)
    local required_keys = {
        'name',
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
    if string.find(colorscheme, 'catppuccin') then
        local flavor = vim.fn.split(colorscheme, '-')[2]
        local p = require('catppuccin.palettes').get_palette(flavor)
        return {
            name = colorscheme,
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
    end
    if string.find(colorscheme, 'tokyonight') then
        local flavor = vim.fn.split(colorscheme, '-')[2]
        local p = require('tokyonight.colors.' .. flavor)
        if type(p) == 'function' then p = p({}) end
        return {
            name = colorscheme,
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
    end
    if string.find(colorscheme, 'rose') then
        local p = require('rose-pine.palette')
        return {
            name = colorscheme,
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
    end
    if colorscheme == 'nord' then
        local p = require('nord.named_colors')
        return {
            name = colorscheme,
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
    end
    if colorscheme == 'everforest' then
        local p = require('everforest.colours').generate_palette(
            { background = 'hard', colours_override = function(_) end },
            'dark'
        )
        return {
            name = colorscheme,
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
    end
    if string.find(colorscheme, 'github') then
        local p = require('github-theme.palette').load(colorscheme)
        return {
            name = colorscheme,
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
    end
    return {
        name = colorscheme,
        accent = vim.api.nvim_get_hl(0, { name = 'Keyword' }).fg,
        text = vim.api.nvim_get_hl(0, { name = 'Normal' }).fg,
        base = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg,
        mantle = vim.api.nvim_get_hl(0, { name = 'NormalFloat' }).bg,
        red = vim.api.nvim_get_hl(0, { name = 'ErrorMsg' }).fg,
        yellow = vim.api.nvim_get_hl(0, { name = 'WarningMsg' }).fg,
    }
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
        thm_mantle = p.mantle,
        thm_fg = p.text,
        thm_surface_0 = p.base,
        thm_surface_1 = p.subtext,
        thm_red = p.red,
        thm_orange = p.orange,
        thm_mauve = p.mauve,
        thm_blue = p.blue,
        thm_green = p.green,
    }
end

local function generate_omp_theme(p)
    return {
        teal = p.teal,
        green = p.green,
        mauve = p.mauve,
        pink = p.pink,
        subtext = p.subtext,
    }
end

local function generate_nvim_overrides(p)
    return {
        -- Neovim Built-in
        CursorLineNr = { fg = p.accent },
        FloatTitle = { fg = p.mantle, bg = p.accent, bold = true },
        FloatBorder = { fg = p.mantle, bg = p.mantle },
        NormalFloat = { bg = p.mantle },
        NormalNC = { link = 'Normal' },
        Pmenu = { link = 'NormalFloat' },
        StatusLine = { fg = p.base, bg = p.base },
        StatusLineNC = { fg = p.base, bg = p.base },
        StatusLineTerm = { fg = p.base, bg = p.base },
        StatusLineTermNC = { fg = p.base, bg = p.base },
        -- Plugins
        BlinkCmpDoc = { link = 'NormalFloat' },
        DapBreak = { fg = p.red },
        DapStop = { fg = p.yellow },
        FzfLuaNormal = { link = 'NormalFloat' },
        FzfLuaBorder = { link = 'FloatBorder' },
        NoiceCmdlinePopupTitleInput = { link = 'FloatTitle' },
        NoiceConfirm = { link = 'NormalFloat' },
        NoiceConfirmBorder = { link = 'FloatBorder' },
        NeotreeNormal = { link = 'NormalFloat' },
        NeoTreeNormalNC = { link = 'NeotreeNormal' },
        NeoTreeCursorLine = { link = 'NeotreeNormal' },
        SnacksDashboardHeader = { fg = p.green },
        SnacksDashboardHeaderSecondary = { fg = p.blue },
        SnacksDashboardFooter = { fg = p.subtext },
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
            b = { bg = p.mantle, fg = p.text },
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
        replace = {
            a = { bg = p.red, fg = p.mantle, gui = 'bold' },
        },
        command = {
            a = { bg = p.orange, fg = p.mantle, gui = 'bold' },
        },
        inactive = {
            a = { bg = p.mantle, fg = p.subtext, gui = 'bold' },
            b = { bg = p.base, fg = p.text },
            c = { bg = p.base, fg = p.subtext },
        },
    }
end

local function get_hyde_theme(colorscheme)
    if string.find(colorscheme, 'tokyonight') then return 'Tokyo Night' end
    if string.find(colorscheme, 'catppuccin') then
        return string.find(colorscheme, 'latte') and 'Catppucin Latte' or 'Catppuccin Mocha'
    end
    if string.find(colorscheme, 'rose') then return 'Rosé Pine' end
    if string.find(colorscheme, 'nord') then return 'Nordic Blue' end
    tee('HyDE theme not found for ' .. colorscheme)
    return nil
end

--- Functions that wrap sed to overwrite config files for all the apps

local function sed_expr(var, val, filepath)
    if string.find(filepath, 'tmux') then
        return string.format([[ -e "s|^set -g @%s \".*\"|set -g @%s \"%s\"|"]], var, var, val)
    elseif string.find(filepath, 'ghostty') then
        return string.format([[ -e "s|^%s = .*|%s = %s|"]], var, var, val)
    else -- nvim or oh-my-posh
        return string.format([[ -e "s|^%s = '.*'|%s = '%s'|"]], var, var, val)
    end
end

local function run_sed_cmd(path, overrides)
    local sed = on_mac and 'gsed' or 'sed'
    local exprs = {}
    for var, val in pairs(overrides) do
        table.insert(exprs, sed_expr(var, val, path))
    end
    local exprs_string = table.concat(exprs, ' \\\n      ')
    local cmd = string.format('%s -i%s \\\n%s', sed, exprs_string, path)
    vim.fn.system(cmd)
end

--- Functions to reload apps and plugins, enabling live updates of entire IDE

local function reload_ghostty()
    if on_arch then
        vim.system({ 'pkill', '-SIGUSR2', 'ghostty' })
    elseif on_ubuntu then
        for _, name in ipairs({ 'ghostty', 'x-terminal-emul' }) do
            vim.system({ 'pkill', '-SIGUSR2', name })
        end
    elseif on_mac then
        vim.system({ 'pkill', '-SIGUSR2', '-a', 'ghostty' })
    end
end

local function reload_tmux() vim.system({ 'tmux', 'source', vim.env.HOME .. '/.config/tmux/tmux.conf' }) end

local function reload_hyde() vim.system({ 'hydectl', 'theme', 'set', vim.g.__hyde_theme }) end

local function reload_oh_my_posh()
    vim.system({ 'oh-my-posh', 'enable', 'reload' })
    vim.defer_fn(function() vim.system({ 'oh-my-posh', 'disable', 'reload' }) end, 2500)
end

local function reload_nvim_servers()
    local servers = vim.fn.glob(vim.fn.fnamemodify(vim.fn.stdpath('run'), ':h') .. '/**/nvim.*', true, true)
    for _, addr in ipairs(servers) do
        if addr ~= vim.v.servername then
            -- stylua: ignore
            vim.system({
                'nvim', '--server', addr, '--remote-send',
                "<Cmd>lua require('autostyle').set_theme('" .. vim.g.colorscheme .. "')<CR>",
            })
        end
    end
end

local function reload_nvim_plugins()
    local vim_notify = vim.notify
    vim.notify = function(_) end ---@diagnostic disable-line

    -- Plugins that work with Lazy's reload feature
    local plugins_to_reload = { 'tiny-glimmer.nvim' }
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
        tee('Colorscheme not supported.')
        return
    end

    -- Palette
    local p = num_to_hex(get_palette(colorscheme))
    if not validate_palette(p) then return end
    tee('Syncing colors to ' .. colorscheme .. '...', 'info')

    -- Updates this session, but not persistent
    M.set_theme(colorscheme)
    reload_nvim_servers() -- reloads *other* neovim instances (if any)

    -- Nvim
    local nvim = '~/.config/nvim/init.lua'
    run_sed_cmd(nvim, { ['vim\\.g\\.colorscheme'] = p.name })

    -- Ghostty
    if vim.fn.executable('ghostty') == 1 then
        local ghostty = '~/.config/ghostty/config'
        local ghostty_overrides = generate_ghostty_theme(p)
        vim.g.__ghostty_theme = ghostty_overrides
        run_sed_cmd(ghostty, ghostty_overrides)
        reload_ghostty()
    end

    -- OhMyPosh
    if vim.fn.executable('oh-my-posh') then
        local omp = '~/.config/ohmyposh/config.omp.toml'
        local omp_overrides = generate_omp_theme(p)
        run_sed_cmd(omp, omp_overrides)
        reload_oh_my_posh()
    end

    -- Tmux
    if vim.fn.executable('tmux') then
        local tmux = '~/.config/tmux/tmux.conf'
        local tmux_overrides = generate_tmux_theme(p)
        run_sed_cmd(tmux, tmux_overrides)
        reload_tmux()
    end

    -- HyDE
    if vim.fn.executable('hydectl') == 1 then
        local hyde_theme = get_hyde_theme(p.name)
        if hyde_theme then
            vim.g.__hyde_theme = hyde_theme
            reload_hyde()
        end
    end
end

--- Sets up an autocmd to override neovim highlights based on the current colorscheme.
function M.setup_hl_autocmd()
    vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function()
            local p = get_palette(vim.g.colorscheme)
            vim.g.palette = p
            local hl_overrides = generate_nvim_overrides(p)
            for hl, col in pairs(hl_overrides) do
                vim.api.nvim_set_hl(0, hl, col)
            end
        end,
    })
end

--- Called by lualine from ./lualine/custom.lua on ColorScheme event
function M.get_lualine_theme()
    local p = vim.g.palette
    return generate_lualine_theme(p)
end

return M
