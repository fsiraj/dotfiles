# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles. Everything under `.config/` mirrors `~/.config/` and is deployed with GNU stow (`stow -d ~/dotfiles -t ~/.config .config`). Configured tools: ghostty (terminal), zsh + oh-my-posh (shell/prompt), tmux, neovim, fastfetch, kanata, claude code. Supported OSes: macOS, Ubuntu, Arch.

## Bootstrap and update

- Fresh machine: `bash <(curl -fsSL https://fsiraj.github.io/dotfiles/install.sh)` — the script lives in the repo root.
- Existing machine re-run: `update` (zsh alias → `bash ~/dotfiles/install.sh`).
- `install.sh` is modular: `main()` at the bottom calls `detect_os`, `install_packages`, `setup_language_tools`, `setup_dotfiles`, `setup_shell`, `setup_tmux_plugins`, `setup_neovim_plugins`. Steps are idempotent and individually commentable.

## Architecture you can't see by `ls`

**Neovim is a single 2300-line `init.lua`.** Banner comments (`┌──── Options ────┐`) divide it into sections (Options, Keymaps, Autocommands, Plugins, Theming). Don't reach for `lua/` directories — this was deliberately collapsed. Companion file `minit.lua` is a 90-line minimal config used as the git commit editor and via the `n` alias for quick edits.

**The theme system is the most interesting piece.** `init.lua` owns the canonical palette and exposes `:NvimSyncTheme <name>` (also driven from zsh via the `theme` function). When invoked, it:

1. Sets the nvim colorscheme and reloads styled plugins.
2. Pushes the change to *other* running nvim instances via `nvim --server ... --remote-send`.
3. `sed`-rewrites theme tokens in `.config/ghostty/config.ghostty`, `.config/ohmyposh/omp.toml`, and `.config/tmux/tmux.conf`.
4. Reloads ghostty and tmux to pick up the new colors.

So **all theme-related editing happens in `init.lua`** — the other config files have generated theme blocks that get overwritten on sync. If you edit ghostty/omp/tmux theme sections by hand, the next `theme` call will clobber your changes.

Supported colorschemes are listed in `colorschemes` (near `sync_theme` in `init.lua`). Adding a theme means extending that list, adding a palette case to `get_palette`, and verifying the `generate_*_theme` helpers cover it.

## Commit message convention

**Subject** (≤ ~60 chars, imperative mood, no trailing period):

```
<scope>[, <scope>...]: <change>
```

- Scope vocab: `nvim`, `tmux`, `ghostty`, `zsh`, `install`, `claude`, `theme`, `readme`, `kanata`.
- Up to 3 scopes, comma-separated. More than 3 scopes or a sweeping change → drop the prefix, use a thematic subject (e.g. `cross-tool UI polish`).
- Verbs: `add`, `fix`, `move`, `simplify`, `refactor`, `remove`, `update`, `consolidate`.

**Body** (blank line after subject, wrap ~72 chars):

- Bullet list, one bullet per logical change, imperative mood, no trailing periods.
- Skip the body when the subject is self-explanatory.

When asked to write a commit message, read `git diff --cached` (or the unstaged diff if nothing is staged) and propose a message in this format.
