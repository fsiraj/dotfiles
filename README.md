<div align="center">

# ✨ Minimal, Fast, Beautiful

</div>

> A carefully crafted development environment that just works (most of the time)

<details open>
<summary><strong>🌹 Rosé Pine</strong> - All natural pine, faux fur and a bit of soho vibes</summary>

<img alt="Screenshot 2025-10-04 at 10 38 39 PM" src="https://github.com/user-attachments/assets/254e50cb-8325-49d7-9887-071cee2ed21d" />

</details>

<details>
<summary><strong>🌙 Tokyo Night</strong> - Dark theme inspired by Tokyo's neon lights</summary>

<img alt="Screenshot 2025-10-04 at 10 37 59 PM" src="https://github.com/user-attachments/assets/ea1eaa4e-a700-4b2f-baf8-63c291b8f734" />

</details>

<details>
<summary><strong>☕ Catppuccin Mocha</strong> - Soothing pastel theme</summary>

<img alt="Screenshot 2025-10-04 at 10 37 23 PM" src="https://github.com/user-attachments/assets/539f284c-b4fd-44ef-8a81-f84985e2a430" />

</details>

<details>
<summary><strong>🐙 GitHub</strong> - Clean theme inspired by GitHub's interface</summary>

<img alt="Screenshot 2025-10-04 at 10 39 22 PM" src="https://github.com/user-attachments/assets/f17437a6-174a-43eb-b1c2-05ec314826c1" />

</details>

<details>
<summary><strong>❄️ Nord</strong> - Arctic, north-bluish color palette</summary>

<img alt="Screenshot 2025-10-04 at 10 39 49 PM" src="https://github.com/user-attachments/assets/43213fe7-ce2d-4173-9c31-25a86198cf7c" />

</details>

<details>
<summary><strong>🌲 Everforest</strong> - Forest-inspired green theme</summary>

<img alt="Screenshot 2025-10-04 at 10 40 22 PM" src="https://github.com/user-attachments/assets/6b0f4db9-1432-45c2-89c3-2fcc876cc729" />

</details>

## 🚀 Quick Start

> [!IMPORTANT]
> Run the command below only if you've read and fully understood the script.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/fsiraj/dotfiles/main/install.sh)
```

> **Supported Systems:** macOS • Ubuntu • Arch Linux

## 🛠️ What's Included

> Full IDE experience using popular well-maintained tools, packages, and plugins

#### 💻 **Terminal & Shell**

> - **Terminal:** [Ghostty](https://ghostty.org/) - Lightning fast GPU-accelerated terminal
> - **Shell:** [ZSH](https://www.zsh.org/) - Fast UNIX shell with modern enhancements
>   - **Plugin Manager:** [zinit](https://github.com/zdharma-continuum/zinit) - Turbo-charged plugin loading
> - **Prompt:** [Oh My Posh](https://ohmyposh.dev/) - Beautiful, customizable prompt

#### ⚡ **Development**

> - **Editor:** [Neovim](https://neovim.io/) - The hyperextensible Vim-based text editor
>   - **Plugin Manager:** [Lazy](https://github.com/folke/lazy.nvim) - Modern plugin manager
> - **Multiplexing:** [tmux](https://github.com/tmux/tmux) - Terminal workspace management
> - **Plugin Manager:** [tpm](https://github.com/tmux-plugins/tpm) - Tmux plugin manager

#### 🔧 **Languages**

> - **Python:** [uv](https://docs.astral.sh/uv/) - Ultra-fast Python package installer and resolver
> - **Rust:** [rustup](https://rustup.rs/) - The Rust toolchain installer
> - **JavaScript:** [nodejs](https://nodejs.org/en) - An unfortunate dependency

#### 🎨 **Theming**

> - **Font:** [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/JetBrainsMono) - Perfect for coding
> - **Default Theme:** [Rosé Pine](https://rosepinetheme.com/) - All natural pine, faux fur and a bit of soho vibes

## 🌈 Theme System

> Works perfectly for the 6 themes (and most of their variants) showcased above

**Synchronized theming across all applications!**

> Switch themes instantly using the shell command `theme` or Neovim colorscheme picker <kbd>\<space\>sc</kbd> and watch as the entire development environment adapts seamlessly.

**Want to add more themes?**

> Add it to `autostyle.lua` using any existing theme as a template. At a minimum, add an entry to `M.colorschemes` and `get_palette`. If using ghostty, add an entry to `.config/ghostty/themes` with the same name as the corresponding Neovim theme. If using Arch with HyDE, ensure the theme is available and add an entry to `get_hyde_theme`.

---

<div align="center">

**Happy coding!** 🎉

</div>
