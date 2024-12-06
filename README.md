# Neovim + Zsh + Tmux

This repo contains my personal dotfiles configuration for Linux and Mac OS. Most of the things below can be installed using your package manager (`brew`, `apt`, ...).

## Summary

- Editor: [Neovim](https://neovim.io/)
  - Plugin Manager: [Lazy](https://github.com/folke/lazy.nvim)
- Shell: [ZSH](https://www.zsh.org/)
  - Multiplexing: [tmux](https://github.com/tmux/tmux)
    - Plugin Manager: [tpm](https://github.com/tmux-plugins/tpm)
  - Prompt: [Oh My Posh](https://ohmyposh.dev/)
  - Plugin Manager: [zinit](https://github.com/zdharma-continuum/zinit)
- Color Scheme: [Tokyo Night](https://github.com/tokyo-night/tokyo-night-vscode-theme?tab=readme-ov-file#color-palette) and [Catppuccin Mocha](https://catppuccin.com/palette)
- Font: [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/JetBrainsMono)

## Setup Instructions

### Install Tools and Dependencies

Install all the packages below using your OS's package manager. The commands below are for Ubuntu which uses `apt`:

```bash
# Essentials
sudo apt install git make unzip gcc 
# Shell
sudo apt install zsh stow fzf zoxide eza tmux
chsh -s $(which zsh)
# Neovim
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt install neovim lua5.4 luarocks ripgrep xsel nodejs npm fd-find
ln -s $(which fdfind) ~/.local/bin/fd
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

Open a session with `nvim`. Lazy is automatically installed by `lazy-plugins.lua` which also installs all neovim plugins. Open a neovim session and run the command `:checkhealth` to diagnose your configuration, use `:Lazy` to manage plugins, and use `:Mason` to manage plugin dependencies. To see keybinds: `<Space>?`.

#### Theme and Font

Catppuccin Mocha is the primary theme, Tokyo Night is second. The themes are installed and set automatically in all cases except the terminal emulator. To install the theme in your terminal, find the relevant port from [Catppuccin Ports](https://catppuccin.com/ports).

The JetbrainsMono Nerd Font has to be installed manually, download and install it using the instructions [here](https://gist.github.com/matthewjberger/7dd7e079f282f8138a9dc3b045ebefa0).

### Notes

#### Future

- `fzf` outdated on Ubuntu so manually sourcing `zsh` integration.
- Could move installation to setup script for quicker `zsh` loading.

#### VS Code Setup (if noevim doesn't work out...)

VS Code removes symlinks on the `settings.json` file, so is a bit more tedious to work with:

```bash
# Likely won't be symlink but will copy file over
ln -f .config/vscode/settings.json ~/.config/Code/User/settings.json
# Install extensions with VS Code's CLI tool
cat .config/vscode/extensions.txt | xargs -n 1 code --install-extension
```
