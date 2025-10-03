#!/bin/bash

# Colored logging function
log() {
    # Usage: log "message" "color_code" "emoji" [indent]
    msg="$1"
    color="${2:-1;36}" # Default: bold cyan
    emoji="${3:-🚀}"
    indent="${4:+    }" # Add 4 spaces if 4th parameter exists
    printf "\033[%sm%s%s %s\033[0m\n" "$color" "$indent" "$emoji" "$msg"
}

# Determine the OS
log "Detecting operating system..." "1;35" "🔍"
if [ "$(uname)" = "Darwin" ]; then
    OS="macos"
elif [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS="$ID"
else
    log "Unsupported OS" "1;31" "⛔" "1"
    exit 1
fi

# Unsupported OS
case "$OS" in
arch | ubuntu | macos) ;;
*)
    log "Unsupported OS: $OS" "1;31" "⛔" "1"
    exit 1
    ;;
esac

log "Detected OS: $OS" "1;34" "✅" "1"

# Install (most) packages
log "Installing packages for $OS..." "1;35" "📦"
case "$OS" in
arch)
    sudo pacman -Syu --needed \
        base-devel \
        git unzip \
        zsh tmux stow fastfetch \
        fzf zoxide eza fd ripgrep \
        nodejs \
        imagemagick \
        ttf-jetbrains-mono-nerd
    sudo pacman -S --needed yay
    yay -S --needed neovim-git ghostty-git
    if ! command -v oh-my-posh >/dev/null 2>&1; then
        curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
    log "arch packages installed!" "1;34" "🎉" "1"
    ;;

ubuntu)
    sudo add-apt-repository ppa:neovim-ppa/unstable -y >/dev/null 2>&1
    sudo apt update -qq
    sudo apt install -qq \
        build-essential \
        git unzip curl \
        zsh tmux xsel stow \
        eza fd-find ripgrep \
        imagemagick \
        neovim
    sudo snap install node --classic
    # Ghostty (stable)
    if ! command -v ghostty >/dev/null 2>&1; then
        /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    fi
    # ohmyposh
    if ! command -v oh-my-posh >/dev/null 2>&1; then
        curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
    # fzf - Ubuntu's package is outdated, install from source...
    XDG_BIN_HOME="$HOME/.local/bin"
    FZF_ROOT="$XDG_BIN_HOME/.fzf"
    if [ ! -d "$FZF_ROOT" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_ROOT"
        "$FZF_ROOT"/install --bin && cp "$FZF_ROOT/bin/fzf" "$XDG_BIN_HOME"
    fi
    # zoxide - Ubuntu's package has extra steps, this is easier...
    if ! command -v zoxide >/dev/null 2>&1; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi
    # fd - Ubuntu's is called fdfind...
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    # fastfetch - Ubuntu doesn't package it...
    if ! command -v fastfetch >/dev/null 2>&1; then
        ARCH=$(uname -m | sed 's/x86_64/amd64/')
        curl -fsSL -o "fastfetch-linux-${ARCH}.deb" \
            "https://github.com/fastfetch-cli/fastfetch/releases/download/2.52.0/fastfetch-linux-${ARCH}.deb"
        sudo apt install -qq "./fastfetch-linux-${ARCH}.deb"
        rm "fastfetch-linux-${ARCH}.deb"
    fi
    # Ubuntu doesn't package the nerd fonts...
    if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        curl -fsSL -o JetBrainsMono.zip \
            https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        mkdir -p "$HOME/.local/share/fonts"
        unzip -o JetBrainsMono.zip -d "$HOME/.local/share/fonts/JetBrainsMono"
        fc-cache -fv
        rm JetBrainsMono.zip
    fi
    log "ubuntu packages installed!" "1;34" "🎉" "1"
    ;;

macos)
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install 2>/dev/null || true
    fi
    # shellcheck disable=2034
    export HOMEBREW_NO_ENV_HINTS=true
    brew install --quiet \
        git make unzip gnu-sed \
        zsh tmux stow fastfetch \
        fzf zoxide eza fd ripgrep \
        node \
        imagemagick \
        jandedobbeleer/oh-my-posh/oh-my-posh
    brew install --quiet --HEAD neovim
    brew install --quiet --cask ghostty font-jetbrains-mono-nerd-font
    log "macOS packages installed!" "1;34" "🎉" "1"
    ;;
esac

# Install language tools
log "Setting up language tools..." "1;35" "🛠️"
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    uv self update
fi
log "uv installed!" "1;34" "🐍" "1"

if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
    rustup update
fi
log "rustup installed!" "1;34" "🦀" "1"

if command -v node >/dev/null 2>&1; then
    log "node installed " "1;34" "😔" "1"
fi

# Setup zsh
log "Setting up zsh..." "1;35" "🐚"

# Change shell to zsh
if ! echo "$SHELL" | grep -q "zsh"; then
    chsh -s "$(which zsh)"
fi
if ! grep -q 'export ZDOTDIR=' "$HOME/.zshenv"; then
    # shellcheck disable=SC2016
    echo 'export ZDOTDIR="$HOME/.config/zsh"' >>"$HOME/.zshenv"
fi
log "shell set to zsh!" "1;34" "🐚" "1"

# Install zinit for zsh plugins
ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
else
    git -C "$ZINIT_HOME" pull
fi
log "zinit installed!" "1;34" "🔌" "1"

# Clone dotfiles to home directory
log "Setting up dotfiles..." "1;35" "📁"
if [ ! -d "$HOME/dotfiles" ]; then
    log "cloning dotfiles..." "1;35" "🧬"
    git clone https://github.com/fsiraj/dotfiles.git "$HOME/dotfiles"
else
    git -C "$HOME/dotfiles" pull
fi
stow -d "$HOME/dotfiles" -t "$HOME/.config" .config
log "dotfiles stowed!" "1;34" "🔗" "1"

# Install tmux plugins
log "Setting up tmux plugins..." "1;35" "🪟"
TPM_HOME="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_HOME" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_HOME"
    "$TPM_HOME/bin/install_plugins"
else
    git -C "$TPM_HOME" pull
    "$TPM_HOME/bin/update_plugins" all
fi
log "tmux plugins installed!" "1;34" "🔌" "1"

# Install neovim plugins and language tools
log "Setting up neovim..." "1;35" "💤"
nvim --headless "+Lazy! sync --quiet" +qa
nvim --headless "+MasonToolsUpdateSync" +qa
log "neovim plugins and language tools installed!" "1;34" "🔌" "1"
