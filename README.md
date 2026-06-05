<div align="center">

# ✨ Minimal, Fast, Beautiful

</div>

> A carefully crafted development environment that just works (most of the time)

<details open>
<summary><strong>🐙 GitHub</strong> - Clean theme inspired by GitHub's interface</summary>

<img alt="Screenshot 2025-10-04 at 10 39 22 PM" src="https://github.com/user-attachments/assets/f17437a6-174a-43eb-b1c2-05ec314826c1" />

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
<summary><strong>🌹 Rosé Pine</strong> - All natural pine, faux fur and a bit of soho vibes</summary>

<img alt="Screenshot 2025-10-04 at 10 38 39 PM" src="https://github.com/user-attachments/assets/254e50cb-8325-49d7-9887-071cee2ed21d" />

</details>

## 🚀 Quick Start

> [!IMPORTANT]
> Run the command below only if you've read and fully understood the script.

> **Requirements:** sudo • curl

```bash
bash <(curl -fsSL https://fsiraj.github.io/dotfiles/install.sh)
```

> **Supported Systems:** macOS • Ubuntu • Arch Linux

<details>
<summary>Slow (and Safe) Start</summary>

> The install script detects your OS, installs your tooling, and deploys the dotfiles. Before running it, download it and read the `main()` function. Everything is modular, so you can comment out any step you don't want. For example, `setup_language_tools` installs Rust and Python tooling — skip it if you don't need either.
>
> The same goes for `install_packages`, which pulls in a lot that isn't strictly required. It installs `node`, for instance, which many Neovim plugins and LSPs rely on — but you'll still get a very usable IDE without it. It also installs `ghostty`, which you can drop if you'd rather keep your current terminal or are working over SSH.
>
> You can skip the script entirely and treat it as a reference, running only the commands relevant to you. It's nothing complicated — it just exists to save you the trouble of tracking every requirement and dependency by hand.
>
> ⚠️ The script does **not** back up existing configs. Check `.config/` in this repo to see which apps may conflict, and rename any configs you already have. For example, if you already use Neovim: `mv ~/.config/nvim ~/.config/nvim.bak`.

</details>

## 🛠️ What's Included

> Full IDE experience using popular well-maintained tools, packages, and plugins

#### 💻 **Terminal & Shell**

> - **Terminal:** [Ghostty](https://ghostty.org/) - Lightning fast GPU-accelerated terminal
> - **Shell:** [ZSH](https://www.zsh.org/) - Fast UNIX shell with modern enhancements
> - **Prompt:** [Oh My Posh](https://ohmyposh.dev/) - Beautiful, customizable prompt

#### ⚡ **Development**

> - **Editor:** [Neovim](https://neovim.io/) - The hyperextensible Vim-based text editor
> - **Multiplexing:** [tmux](https://github.com/tmux/tmux) - Terminal workspace management
> - **AI:** Integrated into Neovim with [sidekick.nvim](https://github.com/folke/sidekick.nvim):

#### 🔧 **Languages**

> - **Python:** [uv](https://docs.astral.sh/uv/) - Ultra-fast Python package installer and resolver
> - **Rust:** [rustup](https://rustup.rs/) - The Rust toolchain installer
> - **JavaScript:** [nodejs](https://nodejs.org/en) - An unfortunate dependency

#### 🎨 **Theming**

> - **Font:** [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/JetBrainsMono) - Perfect for coding
> - **Default Theme:** GitHub - Clean theme inspired by GitHub's interface

## 🌈 Theme System

> Works perfectly for the 4 themes and their variants showcased above

**Synchronized theming across all applications!**

> Switch themes instantly using the shell command `theme` or Neovim colorscheme picker <kbd>\<space\>sc</kbd> and watch as the entire development environment adapts seamlessly.

**Want to add more themes?**

> Use any existing theme as a template.

---

<div align="center">

**Happy coding!** 🎉

</div>
