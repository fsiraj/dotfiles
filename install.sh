#!/bin/sh

# Determine the OS
if [ "$(uname)" = "Darwin" ]; then
    OS="macos"
elif [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS="$ID"
else
    echo "Unsupported OS"
    exit 1
fi

# Unsupported OS
case "$OS" in
arch | ubuntu | macos) ;;
*)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

printf "\033[1;32mDetected OS: %s\033[0m\n" "$OS"

# Install (most) packages
case "$OS" in
arch)
    sudo pacman -Syu --needed \
        git make unzip base-devel \
        zsh tmux stow \
        fzf zoxide eza fd ripgrep \
        lua node \
        ttf-jetbrains-mono-nerd
    sudo pacman -S --needed yay
    yay -S neovim-git ghostty-git
    curl -s https://ohmyposh.dev/install.sh | bash -s
    ;;

ubuntu)
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt install \
        git make unzip \
        zsh tmux xsel stow \
        eza fd-find ripgrep \
        lua nodejs npm \
        neovim
    curl -s https://ohmyposh.dev/install.sh | bash -s
    # Ubuntu's packaged fzf is outdated, install from source...
    XDG_BIN_HOME="$HOME/.local/bin"
    FZF_ROOT="$XDG_BIN_HOME/.fzf"
    if [ ! -d "$FZF_ROOT" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_ROOT"
        "$FZF_ROOT"/install --bin && cp "$FZF_ROOT/bin/fzf" "$XDG_BIN_HOME"
    fi
    # Ubuntu's zoxide package has extra steps, this is easier...
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    # Ubuntu's fd is called fdfind
    ln -sf "$(which fdfind)" ~/.local/bin/fd
    # Ubuntu doesn't package the nerd fonts...
    if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        wget -O JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        mkdir -p ~/.local/share/fonts
        unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
        fc-cache -fv
        rm JetBrainsMono.zip
    fi
    ;;

macos)
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # shellcheck disable=2034
    HOMEBREW_NO_ENV_HINTS=true
    brew install --quiet \
        git make unzip gnu-sed \
        zsh tmux stow \
        fzf zoxide eza fd ripgrep \
        lua node \
        neovim \
        jandedobbeleer/oh-my-posh/oh-my-posh
    brew install --quiet --cask ghostty@tip font-jetbrains-mono-nerd-font
    ;;
esac

# Install language tools
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Change shell to zsh
if ! echo "$SHELL" | grep -q "zsh"; then
    chsh -s "$(which zsh)"
fi

# Install zinit for zsh plugins
XDG_DATA_HOME="$HOME/.local/share"
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
