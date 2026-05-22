#!/bin/bash

OS=""

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_BIN_HOME="$HOME/.local/bin"

BREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
GHOSTTY_INSTALL_URL="https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh"

COLOR_INFO="1;36"     # Cyan
COLOR_STEP="1;35"     # Magenta
COLOR_SUCCESS="1;34"  # Blue
COLOR_COMPLETE="1;32" # Green
COLOR_ERROR="1;31"    # Red

log() {
    msg="$1"
    color="${2:-$COLOR_INFO}"
    emoji="${3:-🚀}"
    printf "\033[%sm%s %s\033[0m\n" "$color" "$emoji" "$msg"
}

installed() {
    command -v "$1" >/dev/null 2>&1
}

clone_or_pull() {
    local url="$1"
    local dest="$2"

    if [ ! -d "$dest" ]; then
        git clone "$url" "$dest"
    else
        git -C "$dest" pull
    fi
}

install_or_update() {
    local tool="$1"
    local install_cmd="$2"
    local update_cmd="${3:-$install_cmd}"

    if ! installed "$tool"; then
        eval "$install_cmd"
    else
        eval "$update_cmd"
    fi
}

detect_os() {
    log "Detecting operating system..." "$COLOR_STEP" "🔍"

    if [ "$(uname)" = "Darwin" ]; then
        OS="macos"
    elif [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        OS="$ID"
    else
        log "Unsupported OS" "$COLOR_ERROR" "⛔"
        exit 1
    fi

    # Validate OS is supported
    case "$OS" in
    arch | ubuntu | macos) ;;
    *)
        log "Unsupported OS: $OS" "$COLOR_ERROR" "⛔"
        exit 1
        ;;
    esac

    log "Detected OS: $OS" "$COLOR_SUCCESS" "✅"
}

install_macos_packages() {
    log "Installing packages for macOS..." "$COLOR_STEP" "📦"

    if ! installed brew; then
        /bin/bash -c \
            "$(curl -fsSL "$BREW_INSTALL_URL")"
    fi
    if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install 2>/dev/null || true
    fi
    # shellcheck disable=2034
    brew install --quiet \
        git make unzip gnu-sed tmux stow \
        fzf zoxide eza fd ripgrep bat fastfetch \
        node imagemagick \
        jandedobbeleer/oh-my-posh/oh-my-posh \
        neovim \
        2>/dev/null
    brew install --quiet --cask ghostty font-jetbrains-mono-nerd-font 2>/dev/null

    log "macOS packages installed!" "$COLOR_SUCCESS" "🎉"
}

install_ubuntu_packages() {
    log "Installing packages for ubuntu..." "$COLOR_STEP" "📦"

    sudo apt update -qq
    sudo apt install -qq build-essential git unzip curl zsh tmux xsel stow

    if ! installed brew; then
        /bin/bash -c "$(curl -fsSL "$BREW_INSTALL_URL")"
        printf "%s\n" "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)\"" >>"$HOME/.zshrc.local"
    fi
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    brew install --quiet \
        fzf zoxide eza fd ripgrep bat fastfetch \
        node imagemagick \
        jandedobbeleer/oh-my-posh/oh-my-posh \
        neovim \
        2>/dev/null
    brew install --quiet --cask font-jetbrains-mono-nerd-font 2>/dev/null

    # ghostty (stable)
    if ! installed ghostty; then
        /bin/bash -c \
            "$(curl -fsSL "$GHOSTTY_INSTALL_URL")"
    fi
    log "ubuntu packages installed!" "$COLOR_SUCCESS" "🎉"
}

install_arch_packages() {
    log "Installing packages for arch..." "$COLOR_STEP" "📦"

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
    if ! installed oh-my-posh; then
        curl -s https://ohmyposh.dev/install.sh | bash -s
    fi

    log "arch packages installed!" "$COLOR_SUCCESS" "🎉"
}

install_packages() {
    case "$OS" in
    macos)
        install_macos_packages
        ;;
    arch)
        install_arch_packages
        ;;
    ubuntu)
        install_ubuntu_packages
        ;;
    esac
}

setup_language_tools() {
    log "Setting up language tools..." "$COLOR_STEP" "🛠️"

    install_or_update "uv" \
        "curl -LsSf https://astral.sh/uv/install.sh | sh" \
        "uv self update"

    log "uv installed!" "$COLOR_SUCCESS" "🐍"

    install_or_update "rustup" \
        "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" \
        "rustup update"

    log "rustup installed!" "$COLOR_SUCCESS" "🦀"

    # installed by package managers
    if installed node; then
        log "node installed " "$COLOR_SUCCESS" "😔"
    fi

    cargo install --locked tree-sitter-cli
    log "tree-sitter-cli installed!" "$COLOR_SUCCESS" "🌲"
}

setup_shell() {
    log "Setting up zsh..." "$COLOR_STEP" "🐚"

    # Change shell to zsh
    if ! echo "$SHELL" | grep -q "zsh"; then
        chsh -s "$(which zsh)"
    fi
    if ! grep -q 'export ZDOTDIR=' "$HOME/.zshenv"; then
        # shellcheck disable=SC2016
        printf 'export ZDOTDIR="$HOME/.config/zsh"\nsource "$ZDOTDIR/.zshenv"\n' >>"$HOME/.zshenv"
    fi

    log "shell set to zsh!" "$COLOR_SUCCESS" "🐚"

    # Install zinit for zsh plugins
    ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
    mkdir -p "$(dirname "$ZINIT_HOME")"
    clone_or_pull "https://github.com/zdharma-continuum/zinit.git" "$ZINIT_HOME"
    log "zinit installed!" "$COLOR_SUCCESS" "🔌"

    # Update zsh plugins
    zsh -c "source '$ZINIT_HOME/zinit.zsh' && zinit update --quiet && compinit"
    log "zsh plugins updated!" "$COLOR_SUCCESS" "🔌"

}

setup_dotfiles() {
    log "Setting up dotfiles..." "$COLOR_STEP" "📁"

    clone_or_pull "https://github.com/fsiraj/dotfiles.git" "$HOME/dotfiles"
    stow -v -d "$HOME/dotfiles" -t "$HOME/.config" .config

    log "dotfiles stowed!" "$COLOR_SUCCESS" "🔗"
}

setup_tmux_plugins() {
    log "Setting up tmux plugins..." "$COLOR_STEP" "🪟"

    TPM_HOME="$HOME/.config/tmux/plugins/tpm"
    clone_or_pull "https://github.com/tmux-plugins/tpm" "$TPM_HOME"

    PLUGINS_DIR="$(dirname "$TPM_HOME")"
    if [ "$(find "$PLUGINS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)" -le 1 ]; then
        "$TPM_HOME/bin/install_plugins"
    else
        "$TPM_HOME/bin/update_plugins" all
    fi

    log "tmux plugins installed!" "$COLOR_SUCCESS" "🔌"
}

setup_neovim_plugins() {
    log "Setting up neovim..." "$COLOR_STEP" "💤"

    nvim --headless "+Lazy! sync" +qa
    nvim --headless "+MasonToolsUpdateSync" +qa

    echo "" && log "neovim plugins and language tools installed!" "$COLOR_SUCCESS" "🔌"
}

main() {
    detect_os
    install_packages
    setup_language_tools
    setup_shell
    setup_dotfiles
    setup_tmux_plugins
    setup_neovim_plugins
    log "Setup complete!" "$COLOR_COMPLETE" "✅"
}

main "$@"
