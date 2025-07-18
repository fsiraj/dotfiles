# Neovim + Zsh + Tmux

This repo contains my personal dotfiles configuration for Linux and Mac OS.

## Summary

- Editor: [Neovim](https://neovim.io/)
  - Plugin Manager: [Lazy](https://github.com/folke/lazy.nvim)
- Shell: [ZSH](https://www.zsh.org/)
  - Multiplexing: [tmux](https://github.com/tmux/tmux)
    - Plugin Manager: [tpm](https://github.com/tmux-plugins/tpm)
  - Prompt: [Oh My Posh](https://ohmyposh.dev/)
  - Plugin Manager: [zinit](https://github.com/zdharma-continuum/zinit)
- Color Scheme: [Catppuccin Mocha](https://catppuccin.com/palette)
- Font: [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/JetBrainsMono)

## Setup Instructions

### Install Tools and Dependencies

Install all the packages below using your OS's package manager. The commands below are for Ubuntu which uses `apt`:

```bash
# Essentials
sudo apt install git make unzip
# Shell (and plugins)
sudo apt install zsh tmux stow eza fd-find # fzf zoxide (installed in .zshrc)
ln -s $(which fdfind) ~/.local/bin/fd
chsh -s $(which zsh)
# Neovim (and plugins)
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt install neovim lua xsel ripgrep nodejs npm # fzf fd (installed above)
```

### Activate Configs with Symlinks

To activate these configurations, run the commands below to create symlinks to where the programs expect their config files to be:

```bash
# Be sure to clone into your home folder
cd && git clone https://github.com/fsiraj/dotfiles.git
cd dotfiles
# Creates symlinks for all configs
stow .
```

### Install Plugins

#### Zsh and Tmux

If you ran the `chsh` command above, your default terminal should now be `zsh` so open a new terminal to check. Oh My Posh and Zinit are installed automatically by `.zshrc`. TPM is installed automatically by `tmux.conf`. To install tmux plugins, open a session with `tmux` and press `<C-a> I`. To update, press `<C-a> U`.

#### Neovim

Open a session with `nvim`. Lazy is automatically installed by `init.lua` which also installs all neovim plugins. Open a neovim session and run the command `:checkhealth` to diagnose your configuration, use `:Lazy` to manage plugins, and use `:Mason` to manage plugin dependencies. To see keybinds: `<Space>?`.

#### Theme and Font

Catppuccin Mocha is the primary theme, Tokyo Night is second. The themes are installed and set automatically in all cases except the terminal emulator. To install the theme in your terminal, find the relevant port from [Catppuccin Ports](https://catppuccin.com/ports).

The JetbrainsMono Nerd Font has to be installed manually, download and install it using the instructions [here](https://gist.github.com/matthewjberger/7dd7e079f282f8138a9dc3b045ebefa0).
