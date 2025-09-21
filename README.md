# ✨ Minimal, Fast, Beautiful

> A carefully crafted development environment that just works (most of the time)

<details open>
<summary><strong>🌹 Rosé Pine</strong> - All natural pine, faux fur and a bit of soho vibes</summary>

![Rose Pine Theme](assets/rosepine-main.png)

</details>

<details>
<summary><strong>🌙 Tokyo Night</strong> - Dark theme inspired by Tokyo's neon lights</summary>

![Tokyo Night Theme](assets/tokyonight-night.png)

</details>

<details>
<summary><strong>☕ Catppuccin Mocha</strong> - Soothing pastel theme</summary>

![Catppuccin Mocha Theme](assets/catppuccin-mocha.png)

</details>

<details>
<summary><strong>❄️ Nord</strong> - Arctic, north-bluish color palette</summary>

![Nord Theme](assets/nord.png)

</details>

## 🚀 Quick Start

**Supported Systems:** macOS • Ubuntu • Arch Linux

```bash
curl -fsSL https://raw.githubusercontent.com/fsiraj/dotfiles/main/install.sh | sh
```

## 🛠️ What's Included

#### 💻 **Terminal & Shell**

- **Terminal:** [Ghostty](https://ghostty.org/) - Lightning fast GPU-accelerated terminal
- **Shell:** [ZSH](https://www.zsh.org/) with modern enhancements
- **Prompt:** [Oh My Posh](https://ohmyposh.dev/) - Beautiful, customizable prompt
- **Plugin Manager:** [zinit](https://github.com/zdharma-continuum/zinit) - Turbo-charged plugin loading

#### ⚡ **Development**

- **Editor:** [Neovim](https://neovim.io/) - The hyperextensible Vim-based text editor
  - **Plugin Manager:** [Lazy](https://github.com/folke/lazy.nvim) - Modern plugin manager
- **Multiplexing:** [tmux](https://github.com/tmux/tmux) - Terminal workspace management
  - **Plugin Manager:** [tpm](https://github.com/tmux-plugins/tpm) - Tmux plugin manager

#### 🎨 **Theming**

- **Font:** [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/JetBrainsMono) - Perfect for coding
- **Default Theme:** [Rosé Pine](https://rosepinetheme.com/) - All natural pine, faux fur and a bit of soho vibes

## 🌈 Theme System

**Synchronized theming across all applications!**

Switch themes instantly using fzf-lua's colorscheme picker in Neovim, and watch as the entire development environment adapts seamlessly.

**Want to add more themes?**

- Define the palette in `get_palette()` with identical keys to existing palettes
- Add a mapping to `get_hyde_theme()` if using Arch Linux
- Add a mapping to `get_ghostty_theme()` if using Ghostty terminal

---

<div align="center">

**Happy coding!** 🎉

</div>
