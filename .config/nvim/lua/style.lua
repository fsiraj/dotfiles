local COLORS = {
    'name',
    'accent',
    'text',
    'base',
    'mantle',
    'surface',
    'subtext',
    'red',
    'yellow',
    'green',
    'teal',
    'sky',
    'sapphire',
    'blue',
    'mauve',
    'pink',
}

--- Constructs and returns a palette object from the current colorscheme
--- @param colorscheme string name of the colorscheme
--- @return table
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

--- Check for missing colors in the palette and convert numeric values to hex strings.
--- @param p table palette object
--- @return table
local function sanitize_palette(p)
    for k, v in pairs(p) do
        if type(v) == 'number' then p[k] = string.format('#%06x', v) end
    end
    vim.print('colorscheme: ' .. p.name)
    vim.print(p)
    local missing = {}
    for _, c in ipairs(COLORS) do
        if not p[c] then table.insert(missing, c) end
    end
    if #missing > 0 then
        vim.print('missing colors:')
        vim.print(missing)
    end
    return p
end

--- Uses fzf to find the builtin ghostty theme corresponding to
--- the given colorscheme.
--- @param colorscheme string name of the colorscheme
--- @return string
local function ghostty_theme(colorscheme)
    local cmd =
        string.format('ghostty +list-themes --plain | fzf -f %q --exit-0 | head -n1', colorscheme:gsub('[^%w]', ''))
    local match = vim.fn.system(cmd):gsub('%s+$', ''):match('^(.*)%s[^%s]+$')
    vim.print('ghostty match for ' .. colorscheme .. ' is ' .. match)
    return match
end

--- Uses sed to reassign a variable in a file.
--- @param var string variable to reassign
--- @param val string value to assign to the variable
--- @param file string file to modify
--- @return nil
local function sed_reassign(var, val, file)
    local cmd
    if string.find(file, 'tmux') then
        cmd = string.format([[sed -i "s|^set -g @%s \".*\"|set -g @%s \"%s\"|" %s]], var, var, val, file)
    elseif string.find(file, 'ghostty') then
        cmd = string.format([[sed -i "s|^%s = .*|%s = %s|" %s]], var, var, val, file)
    else
        cmd = string.format([[sed -i "s|^%s = '.*'|%s = '%s'|" %s]], var, var, val, file)
    end
    vim.fn.system(cmd)
end

--- Applies overrides to a file by reassigning variables.
--- @param path string path to the file
--- @param overrides table table of variable-value pairs to override
--- @return nil
local function apply_overrides(path, overrides)
    for var, val in pairs(overrides) do
        sed_reassign(var, val, path)
    end
end

local M = {}

--- Syncs the theme across neovim, oh-my-posh, tmux, and ghostty.
--- Used as a callback for fzf-lua's colorscheme picker.
--- @return nil
function M.sync_theme()
    if vim.g.colors_name == vim.g.colorscheme then return end
    local p = sanitize_palette(get_palette(vim.g.colors_name))

    local nvim = '~/.config/nvim/init.lua'
    local nvim_overrides = {
        ['vim\\.g\\.colorscheme'] = p.name,
    }
    apply_overrides(nvim, nvim_overrides)

    local ghostty = '~/.config/ghostty/config'
    local ghostty_overrides = {
        theme = ghostty_theme(p.name),
    }
    apply_overrides(ghostty, ghostty_overrides)

    local omp = '~/.config/ohmyposh/simple.omp.toml'
    local omp_overrides = {
        teal = p.teal,
        green = p.green,
        mauve = p.mauve,
        pink = p.pink,
        subtext = p.subtext,
    }
    apply_overrides(omp, omp_overrides)

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
    apply_overrides(tmux, tmux_overrides)
end

--- Sets up an autocmd to apply neovim highlights based on the current colorscheme.
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
