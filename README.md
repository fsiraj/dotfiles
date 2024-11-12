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

## Requirements
In addition to the above, also install:
- `git`
- `stow`
- `zoxide`
- `fzf`

## Instructions
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
# Check to see if it's actually a symlink
ln -f .config/vscode/settings.json ~/.config/Code/User/settings.json
# Install extensions manually
cat .config/vscode/extensions.txt
```
