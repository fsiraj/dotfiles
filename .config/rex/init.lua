-- Keybinds
local prefix = "ctrl+a>"
rex.bind(prefix .. "ctrl+a", "pane.send_key", { key = "ctrl+a" })

rex.bind(prefix .. "s", "session.switch")

rex.bind(prefix .. "r", "client.config.reload")
rex.bind(prefix .. "x", "client.close")
rex.bind(prefix .. "c", "client.tab.new")
rex.bind(prefix .. "n", "client.tab.next")
rex.bind(prefix .. "p", "client.tab.previous")

rex.bind(prefix .. "\\", "pane.split.right")
rex.bind(prefix .. "-", "pane.split.down")
rex.bind(prefix .. "z", "pane.zoom")
rex.bind(prefix .. "=", "pane.balance")

local term = "com.superlogical.terminal"

-- Name of the focused block's foreground program, e.g. 'nvim' or 'claude'
local function foreground(ctx)
   local ok, p = pcall(rex.block.call, term, "process", { block_id = ctx.block_id })
   local fg = ok and p and p.foreground
   return fg and (fg.argv0 or fg.name or ""):match("([^/]+)$") or nil
end

-- Vim-aware pane navigation
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
   rex.bind("ctrl+" .. key, function(ctx)
      if foreground(ctx) == "nvim" then return false end
      rex.session.focus_direction({ direction = direction })
      return true
   end)
end

-- Vim scroll keybinds for TUIs
local tuis = { claude = true, codex = true, opencode = true }
for key, button in pairs({ u = 64, d = 65 }) do -- 64/65 are wheel up/down
   rex.bind("ctrl+" .. key, function(ctx)
      if not tuis[foreground(ctx)] then
         return false
      end
      local wheel = ("\27[<%d;8;8M"):format(button)
      rex.block.call(term, "write", { block_id = ctx.block_id, data = wheel:rep(3) })
      return true
   end)
end
