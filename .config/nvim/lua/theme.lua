--- @class Palette
--- @field name string
--- @field accent string
--- @field text string
--- @field base string
--- @field mantle string
--- @field surface string
--- @field subtext string
--- @field red string
--- @field yellow string
--- @field green string
--- @field teal string
--- @field sky string
--- @field sapphire string
--- @field blue string
--- @field mauve string
--- @field pink string

--- @param colorscheme string
--- @return Palette
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
            surface = p.surface0,
            subtext = p.subtext0,
            red = p.red,
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
        return {
            name = colorscheme,
            accent = p.cyan,
            text = p.fg,
            base = p.bg,
            mantle = p.bg_dark,
            surface = p.fg_dark,
            subtext = p.comment,
            red = p.magenta2,
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

-- Helper to reassign variables with sed
local function sed_reassign(var, color, file)
    local cmd
    if string.find(file, 'tmux') then
        cmd = string.format([[sed -i "s|^set -g @%s \".*\"|set -g @%s \"%s\"|" %s]], var, var, color, file)
    else
        cmd = string.format([[sed -i "s|^%s = '.*'|%s = '%s'|" %s]], var, var, color, file)
    end
    vim.fn.system(cmd)
end

local M = {}

-- Fzflua colorscheme picker callback
function M.sync_theme()
    -- Apply persistent changes to neovim, omp, and tmux if colorscheme changes
    if vim.g.colors_name == vim.g.colorscheme then return end
    local p = get_palette(vim.g.colors_name)

    local nvim = '~/.config/nvim/init.lua'
    local nvim_overrides = {
        ['vim\\.g\\.colorscheme'] = p.name,
    }
    for var, val in pairs(nvim_overrides) do
        sed_reassign(var, val, nvim)
    end

    local omp = '~/.config/ohmyposh/simple.omp.toml'
    local omp_overrides = {
        teal = p.teal,
        green = p.green,
        mauve = p.mauve,
        pink = p.pink,
        subtext = p.subtext,
    }
    for var, val in pairs(omp_overrides) do
        sed_reassign(var, val, omp)
    end

    local tmux = '~/.config/tmux/tmux.conf'
    local tmux_overrides = {
        thm_fg = p.text,
        thm_mantle = p.mantle,
        thm_surface = p.surface,
        thm_mauve = p.mauve,
        thm_teal = p.teal,
        thm_sky = p.sky,
        thm_sapphire = p.sapphire,
        thm_blue = p.blue,
    }
    for var, val in pairs(tmux_overrides) do
        sed_reassign(var, val, tmux)
    end

    vim.print(p)
end

-- Apply non-persistent changes immediately
function M.hl_autocmd()
    vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
            local p = get_palette(vim.g.colors_name)
            -- Apply neovim highglights
            local theme = {}
            theme.FloatTitle = { fg = p.mantle, bg = p.accent, bold = true }
            theme.FloatBorder = { fg = p.mantle, bg = p.mantle }
            theme.Pmenu = { link = 'NormalFloat' }
            theme.CursorLineNr = { fg = p.accent }
            theme.StatusLine = { fg = p.base, bg = p.base }
            theme.StatusLineNC = { fg = p.base, bg = p.base }
            theme.DashboardHeader = { fg = p.accent }
            theme.DapBreak = { fg = p.red }
            theme.DapStop = { fg = p.yellow }
            theme.NoiceCmdlinePopupTitleInput = { link = 'FloatTitle' }
            theme.TreesitterContext = { bg = p.mantle }
            theme.TreesitterContextBottom = { sp = p.accent, underline = true }
            for hl, col in pairs(theme) do
                vim.api.nvim_set_hl(0, hl, col)
            end
        end,
    })
end

return M
