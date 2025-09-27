--- We're either on arch, ubuntu, or macos
local on_ubuntu = vim.fn.executable('apt') == 1
local on_arch = vim.fn.executable('pacman') == 1
local on_mac = vim.fn.executable('brew') == 1

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

local function num_to_hex(p)
    for k, v in pairs(p) do
        if type(v) == 'number' then p[k] = string.format('#%06x', v) end
    end
    return p
end

local function get_ghostty_theme(colorscheme)
    local map = {
        ['rose-pine-main'] = 'Rose Pine',
        ['rose-pine-moon'] = 'Rose Pine Moon',
        ['rose-pine-dawn'] = 'Rose Pine Dawn',
        ['tokyonight-night'] = 'TokyoNight Night',
        ['tokyonight-storm'] = 'TokyoNight Storm',
        ['tokyonight-moon'] = 'TokyoNight Moon',
        ['tokyonight-day'] = 'TokyoNight Day',
        ['catppuccin-mocha'] = 'Catppuccin Mocha',
        ['catppuccin-macchiato'] = 'Catppuccin Macchiato',
        ['catppuccin-frappe'] = 'Catppuccin Frappe',
        ['catppuccin-latte'] = 'Catppuccin Latte',
        ['nord'] = 'Nord',
        ['everforest'] = 'Everforest Dark   Hard',
        ['github_dark_default'] = 'Github Dark Default',
    }
    return map[colorscheme]
end

local function get_hyde_theme(colorscheme)
    if string.find(colorscheme, 'tokyonight') then return 'Tokyo Night' end
    if string.find(colorscheme, 'catppuccin') then
        return string.find(colorscheme, 'latte') and 'Catppucin Latte'
            or 'Catppuccin Mocha'
    end
    if string.find(colorscheme, 'rose') then return 'Rosé Pine' end
    if string.find(colorscheme, 'nord') then return 'Nordic Blue' end
    return nil
end

local function sed_expr(var, val, file)
    if string.find(file, 'tmux') then
        return string.format(
            [[ -e "s|^set -g @%s \".*\"|set -g @%s \"%s\"|"]],
            var,
            var,
            val
        )
    elseif string.find(file, 'ghostty') then
        return string.format([[ -e "s|^%s = .*|%s = %s|"]], var, var, val)
    else
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

local function reload_(app, ...)
    if app == 'ghostty' then
        if on_arch then
            vim.system({ 'pkill', '-SIGUSR2', 'ghostty' })
        elseif on_ubuntu then
            vim.system({ 'pkill', '-SIGUSR2', 'ghostty' })
            vim.system({ 'pkill', '-SIGUSR2', 'x-terminal-emul' })
        elseif on_mac then
            vim.system({ 'pkill', '-SIGUSR2', '-a', 'ghostty' })
        end
    elseif app == 'tmux' then
        vim.system({
            'tmux',
            'source',
            vim.env.HOME .. '/.config/tmux/tmux.conf',
        })
    elseif app == 'hyde' then
        vim.system({
            'hydectl',
            'theme',
            'set',
            ...,
        })
    elseif app == 'oh-my-posh' then
        vim.system({ 'oh-my-posh', 'enable', 'reload' })
        vim.system({ 'oh-my-posh', 'disable', 'reload' })
    end
end

local M = {}

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
}

--- Syncs the theme across neovim, oh-my-posh, tmux, and ghostty.
--- Used as a callback for fzf-lua's colorscheme picker.
function M.sync_theme(colorscheme)
    -- Colorscheme is required
    if colorscheme == nil then
        vim.notify('Colorscheme not provided')
        return
    end

    -- Updates this session, but not persistent
    vim.g.colorscheme = colorscheme
    vim.cmd('colorscheme ' .. colorscheme)
    vim.notify('Syncing colors to ' .. colorscheme .. '...')

    -- Palette
    local p = num_to_hex(get_palette(colorscheme))

    -- Nvim
    local nvim = '~/.config/nvim/init.lua'
    run_sed_cmd(nvim, { ['vim\\.g\\.colorscheme'] = p.name })

    -- Ghostty
    if vim.fn.executable('ghostty') == 1 then
        local ghostty = '~/.config/ghostty/config'
        local ghostty_theme = get_ghostty_theme(p.name)
        if ghostty_theme then
            run_sed_cmd(ghostty, { theme = ghostty_theme })
            reload_('ghostty')
        end
    end

    -- Oh My Posh
    local omp = '~/.config/ohmyposh/config.omp.toml'
    local omp_overrides = {
        teal = p.teal,
        green = p.green,
        mauve = p.mauve,
        pink = p.pink,
        subtext = p.subtext,
    }
    run_sed_cmd(omp, omp_overrides)
    reload_('oh-my-posh')

    -- Tmux
    local tmux = '~/.config/tmux/tmux.conf'
    local tmux_overrides = {
        thm_accent = p.accent,
        thm_mantle = p.mantle,
        thm_fg = p.text,
        thm_surface_0 = p.base,
        thm_surface_1 = p.subtext,
        thm_blue = p.blue,
        thm_green = p.green,
        thm_red = p.red,
    }
    run_sed_cmd(tmux, tmux_overrides)
    reload_('tmux')

    -- HyDE
    if vim.fn.executable('hydectl') == 1 then
        local hyde_theme = get_hyde_theme(p.name)
        if hyde_theme then reload_('hyde', hyde_theme) end
    end
end

--- Sets up an autocmd to override neovim highlights based on the current colorscheme.
function M.hl_autocmd()
    vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
            -- Palette
            local p = get_palette(vim.g.colorscheme)
            vim.g.palette = p

            -- Neovim highlight overrides
            local hl_overrides = {
                -- Neovim Built-in
                NormalNC = { link = 'Normal' },
                NormalFloat = { bg = p.mantle },
                FloatTitle = { fg = p.mantle, bg = p.accent, bold = true },
                FloatBorder = { fg = p.mantle, bg = p.mantle },
                Pmenu = { link = 'NormalFloat' },
                CursorLineNr = { fg = p.accent },
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
                SnacksDashboardHeader = { fg = p.green },
                SnacksDashboardHeaderSecondary = { fg = p.blue },
                SnacksDashboardFooter = { fg = p.subtext },
                SnacksDashboardSpecial = { fg = p.accent },
                TreesitterContext = { bg = p.base },
                TreesitterContextBottom = { sp = p.accent, underline = true },
                WhichKeyBorder = { link = 'FloatBorder' },
            }

            -- Apply neovim highlights
            for hl, col in pairs(hl_overrides) do
                vim.api.nvim_set_hl(0, hl, col)
            end
        end,
    })
end

--- Called by lualine from ./lualine/custom.lua on ColorScheme event
function M.get_lualine_theme()
    local p = vim.g.palette
    return {
        normal = {
            a = { bg = p.accent, fg = p.mantle, gui = 'bold' },
            b = { bg = p.mantle, fg = p.text },
            c = { bg = p.base, fg = p.text },
            x = { bg = p.blue, fg = p.mantle, gui = 'bold' },
            y = { bg = p.mantle, fg = p.text },
        },
        insert = {
            a = { bg = p.teal, fg = p.mantle, gui = 'bold' },
            b = { bg = p.mantle, fg = p.text },
            c = { bg = p.base, fg = p.text },
            x = { bg = p.blue, fg = p.mantle, gui = 'bold' },
            y = { bg = p.mantle, fg = p.text },
        },
        visual = {
            a = { bg = p.mauve, fg = p.mantle, gui = 'bold' },
            b = { bg = p.mantle, fg = p.text },
            c = { bg = p.base, fg = p.text },
            x = { bg = p.blue, fg = p.mantle, gui = 'bold' },
            y = { bg = p.mantle, fg = p.text },
        },
        replace = {
            a = { bg = p.red, fg = p.mantle, gui = 'bold' },
            b = { bg = p.mantle, fg = p.text },
            c = { bg = p.base, fg = p.text },
            x = { bg = p.blue, fg = p.mantle, gui = 'bold' },
            y = { bg = p.mantle, fg = p.text },
        },
        command = {
            a = { bg = p.orange, fg = p.mantle, gui = 'bold' },
            b = { bg = p.mantle, fg = p.text },
            c = { bg = p.base, fg = p.text },
            x = { bg = p.blue, fg = p.mantle, gui = 'bold' },
            y = { bg = p.mantle, fg = p.text },
        },
        inactive = {
            a = { bg = p.mantle, fg = p.subtext, gui = 'bold' },
            b = { bg = p.base, fg = p.text },
            c = { bg = p.base, fg = p.subtext },
            x = { bg = p.blue, fg = p.mantle, gui = 'bold' },
            y = { bg = p.mantle, fg = p.text },
        },
    }
end

return M
