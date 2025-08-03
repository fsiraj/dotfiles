# Minimal, Fast, Beautiful

## Summary

- Terminal Emulator: [Ghostty](https://ghostty.org/)
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

  ```bash
  # Be sure to clone into your home folder
  cd && git clone https://github.com/fsiraj/dotfiles.git
  cd dotfiles
  # Install tools and dependencies - only supports macos, arch, and ubuntu
  ./install.sh 
  # Activate configs with symlinks
  stow .
  # Install tmux plugins 
  tmux  
  # then press `<C-a>I`
  # Install neovim plugins
  nvim  
  # plugins auto-install
  # for external tools type `:Mason` then `U`
  # to check health, type `:che`
  ```

#### Theme

Themes are automatically synced across everything if you use fzf-lua's colorscheme picker in neovim to change it. This is achieved using the `style.lua` file, where you can add any additional themes you want. Currently, it supports tokyonight, catppuccin, rose-pine, and nord.

