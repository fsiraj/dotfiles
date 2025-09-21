#!/bin/sh

# Colored logging function
log() {
    # Usage: log "message" "color_code" "emoji"
    msg="$1"
    color="${2:-1;36}" # Default: bold cyan
    emoji="${3:-🚀}"
    printf "\033[%sm%s %s\033[0m\n" "$color" "$emoji" "$msg"
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
    log "Unsupported OS" "1;31" "    ⛔"
    exit 1
fi

# Unsupported OS
case "$OS" in
arch | ubuntu | macos) ;;
*)
    log "Unsupported OS: $OS" "1;31" "    ⛔"
    exit 1
    ;;
esac

log "Detected OS: $OS" "1;32" "    ✅"

# Install (most) packages
log "Installing packages for $OS..." "1;35" "📦"
case "$OS" in
arch)
    sudo pacman -Syu --needed \
        base-devel \
        git unzip \
        zsh tmux stow \
        fzf zoxide eza fd ripgrep \
        lua nodejs \
        ttf-jetbrains-mono-nerd
    sudo pacman -S --needed yay
    yay -S --needed neovim-git ghostty-git
    if ! command -v oh-my-posh >/dev/null 2>&1; then
        curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
    log "arch packages installed!" "1;32" "    🎉"
    ;;

ubuntu)
    sudo add-apt-repository ppa:neovim-ppa/unstable -y >/dev/null 2>&1
    sudo apt update -qq
    sudo apt install -qq \
        build-essential \
        git unzip \
        zsh tmux xsel stow \
        eza fd-find ripgrep \
        lua5.4 \
        neovim
    sudo snap install node --classic
    # Ghostty (stable)
    if ! command -v ghostty >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    fi
    # Oh My Posh
    if ! command -v oh-my-posh >/dev/null 2>&1; then
        curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
    # Ubuntu's packaged fzf is outdated, install from source...
    XDG_BIN_HOME="$HOME/.local/bin"
    FZF_ROOT="$XDG_BIN_HOME/.fzf"
    if [ ! -d "$FZF_ROOT" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_ROOT"
        "$FZF_ROOT"/install --bin && cp "$FZF_ROOT/bin/fzf" "$XDG_BIN_HOME"
    fi
    # Ubuntu's zoxide package has extra steps, this is easier...
    if ! command -v zoxide >/dev/null 2>&1; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi
    # Ubuntu's fd is called fdfind...
    ln -sf "$(which fdfind)" ~/.local/bin/fd
    # Ubuntu doesn't package the nerd fonts...
    if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        wget -O JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        mkdir -p ~/.local/share/fonts
        unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
        fc-cache -fv
        rm JetBrainsMono.zip
    fi
    log "ubuntu packages installed!" "1;32" "    🎉"
    ;;

macos)
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # shellcheck disable=2034
    export HOMEBREW_NO_ENV_HINTS=true
    brew install --quiet \
        git make unzip gnu-sed \
        zsh tmux stow \
        fzf zoxide eza fd ripgrep \
        lua node \
        neovim \
        jandedobbeleer/oh-my-posh/oh-my-posh
    brew install --quiet --cask ghostty font-jetbrains-mono-nerd-font
    xcode-select --install 2>/dev/null
    log "macOS packages installed!" "1;32" "    🎉"
    ;;
esac

# Install language tools
log "Setting up language tools..." "1;35" "🛠️"
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    log "uv installed!" "1;32" "    🐍"
else
    log "uv already installed!" "1;34" "    🐍"
fi
if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    log "rustup installed!" "1;32" "    🦀"
else
    log "rustup already installed!" "1;34" "    🦀"
fi

# Setup zsh
log "Setting up zsh..." "1;35" "🐚"
# Change shell to zsh
if ! echo "$SHELL" | grep -q "zsh"; then
    # shellcheck disable=SC2016
    echo 'export ZDOTDIR="$HOME/.config/zsh"' >> ~/.zshenv
    chsh -s "$(which zsh)"
    log "shell changed to zsh!" "1;32" "    🐚"
else
    log "zsh already the default shell!" "1;34" "    🐚"
fi
# Install zinit for zsh plugins
XDG_DATA_HOME="$HOME/.local/share"
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    log "zinit installed!" "1;32" "    🔌"
else
    log "zinit already installed!" "1;34" "    🔌"
fi

# Clone dotfiles to home directory
log "Setting up dotfiles..." "1;35" "📁"
if [ ! -d "$HOME/dotfiles" ]; then
    log "Cloning dotfiles..." "1;35" "🧬"
    git clone https://github.com/fsiraj/dotfiles.git "$HOME/dotfiles"
    cd "$HOME/dotfiles" || exit
    stow -t ~/.config -S .config
    log "dotfiles stowed!" "1;32" "    🔗"
else
    log "dotfiles already present!" "1;34" "    📁"
fi

log "Setting up tmux plugins..." "1;35" "🪟"
# Install tmux plugins
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
    ~/.config/tmux/plugins/tpm/bin/install_plugins
    log "tmux plugins installed!" "1;32" "    🔌"
else
    log "tmux plugins already installed!" "1;34" "    🔌"
fi

# Install neovim plugins and language tools
log "Installing Neovim plugins and language tools..." "1;35" "💤"
nvim --headless "+Lazy! sync --quiet" +qa
nvim --headless "+MasonToolsUpdateSync" +qa
log "neovim plugins and language tools installed!" "1;32" "    🔌"
