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
            sky = p.sky,
            sapphire = p.sapphire,
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
            sky = p.blue1,
            sapphire = p.blue2,
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
            sky = p.pine,
            sapphire = p.pine,
            blue = p.pine,
            mauve = p.iris,
            pink = p.rose,
        }
    end
    if string.find(colorscheme, 'nord') then
        local p = require('nord.named_colors')
        return {
            name = colorscheme,
            accent = p.glacier,
            text = p.darkest_white,
            base = p.black,
            mantle = p.dark_gray,
            subtext = p.light_gray_bright,
            red = p.red,
            orange = p.gold,
            yellow = p.yellow,
            green = p.green,
            teal = p.teal,
            sky = p.off_blue,
            sapphire = p.glacier,
            blue = p.blue,
            mauve = p.purple,
            pink = '#ebbcba',
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
    local query = string.lower(colorscheme:gsub('[^%w]', ''))
    local cmd = string.format('ghostty +list-themes --plain | fzf -f %q --exit-0 | head -n1', query)
    local out = vim.fn.system(cmd)
    local match = out:gsub('%s+$', ''):match('^(.*)%s[^%s]+$')
    return match
end

local function get_hyde_theme(colorscheme)
    if string.find(colorscheme, 'tokyonight') then return 'Tokyo Night' end
    if string.find(colorscheme, 'catppuccin') then return string.find(colorscheme, 'latte') and 'Catppucin Latte' or 'Catppuccin Mocha' end
    if string.find(colorscheme, 'rose') then return 'Rosé Pine' end
    if string.find(colorscheme, 'nord') then return 'Nordic Blue' end
    return nil
end

local function sed_expr(var, val, file)
    if string.find(file, 'tmux') then
        return string.format([[ -e "s|^set -g @%s \".*\"|set -g @%s \"%s\"|"]], var, var, val)
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
    end
end

local M = {}

--- Syncs the theme across neovim, oh-my-posh, tmux, and ghostty.
--- Used as a callback for fzf-lua's colorscheme picker.
function M.sync_theme()
    -- Palette
    local p = num_to_hex(get_palette(vim.g.colors_name))

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

    -- Tmux
    local tmux = '~/.config/tmux/tmux.conf'
    local tmux_overrides = {
        thm_accent = p.accent,
        thm_mantle = p.mantle,
        thm_fg = p.text,
        thm_surface_0 = p.base,
        thm_surface_1 = p.subtext,
        thm_sapphire = p.sapphire,
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
            local p = get_palette(vim.g.colors_name)
            vim.g.palette = p

            -- Neovim highlight overrides
            local hl_overrides = {
                NormalFloat = { bg = p.mantle },
                FloatTitle = { fg = p.mantle, bg = p.accent, bold = true },
                FloatBorder = { fg = p.mantle, bg = p.mantle },
                Pmenu = { link = 'NormalFloat' },
                CursorLineNr = { fg = p.accent },
                StatusLine = { fg = p.base, bg = p.base },
                StatusLineNC = { fg = p.base, bg = p.base },
                SnacksDashboardHeader = { fg = p.green },
                SnacksDashboardFooter = { fg = p.subtext },
                SnacksDashboardSpecial = { fg = p.accent },
                DapBreak = { fg = p.red },
                DapStop = { fg = p.yellow },
                NoiceCmdlinePopupTitleInput = { link = 'FloatTitle' },
                NoiceConfirm = { link = 'NormalFloat' },
                NoiceConfirmBorder = { link = 'FloatBorder' },
                TreesitterContext = { bg = p.mantle },
                TreesitterContextBottom = { sp = p.accent, underline = true },
                WhichKeyBorder = { link = 'FloatBorder' },
                NeotreeNormal = { link = 'NormalFloat' },
                NeoTreeNormalNC = { link = 'NeotreeNormal' },
            }

            -- Apply neovim highlights
            for hl, col in pairs(hl_overrides) do
                vim.api.nvim_set_hl(0, hl, col)
            end
        end,
    })
end

return M
