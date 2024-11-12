# Dotfiles

This repo contains my personal dotfiles configuration for Linux and Mac OS. Most of the things below can be installed using your package manager (`brew`, `apt`, ...).

## References
A summary of my setup:
- Editor: [VS Code](https://code.visualstudio.com/)
- Shell: [ZSH](https://www.zsh.org/)
    - Multiplexing: [tmux](https://github.com/tmux/tmux)
        - Plugin Manager: [tpm](https://github.com/tmux-plugins/tpm)
    - Prompt: [Oh My Posh](https://ohmyposh.dev/)
    - Plugin Manager: [zinit](https://github.com/zdharma-continuum/zinit)
- Color Scheme: [Catppuccin Mocha](https://catppuccin.com/palette)
- Font: [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/JetBrainsMono)


## Instructions

### Installation

First install VS Code however you like, then run the command appropriate for your OS.
```bash 
sudo apt install zsh stow fzf zoxide eza tmux git # Ubuntu
brew install stow fzf zoxide eza tmux git font-jetbrains-mono-nerd-font # MacOS
# Make zsh default shell (same for any POSIX OS)
chsh -s $(which zsh)
```
Install the font manually on Linux. Oh My Posh and Zinit are installed automatically by `.zshrc`. TPM is installed automatically by `tmux.conf`

Catppuccin Mocha is included in `extensions.txt` for VS Code. To install in the terminal follow the links for [`iterm2`](https://github.com/catppuccin/iterm), [`gnome-terminal`](https://github.com/catppuccin/gnome-terminal), or [other ports](https://catppuccin.com/ports).

### Activation

To activate these configurations, run the commands below:
```bash
# Be sure to clone into your home folder
cd && git clone https://github.com/fsiraj/dotfiles.git
cd dotfiles
# Creates symlinks for all configs
stow .
```

VS Code removes symlinks on the `settings.json` file, so is a bit more tedious to work with:
```bash
# Likely won't be symlink but will copy file over
ln -f .config/vscode/settings.json ~/.config/Code/User/settings.json
# Install extensions with VS Code's CLI tool
cat .config/vscode/extensions.txt | xargs -n 1 code --install-extension
```

Install tmux plugins:
```bash
tmux
# prefix + I
```

Notes:
- `fzf` outdated on Ubuntu so manually sourcing `zsh` integration.
- Move installation to setup script for quicker `zsh` loading.

## Nvim Migration

- Requirements: git make unzip gcc ripgrep xsel neovim lua5.4 
- Additional:
    - luarocks
    - fd-find, ln -s $(which fdfind) ~/.local/bin/fd
    - nodejs, npm
- Copilot: gh, gh auth login, gh extension install github/gh-copilot
- sudo add-apt-repository ppa:neovim-ppa/unstable -y
