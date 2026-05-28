#!/bin/bash

OS=""

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_BIN_HOME="$HOME/.local/bin"

BREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
GHOSTTY_INSTALL_URL="https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh"
CARGO_BINSTALL_URL="https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh"

COLOR_STEP="1;35"     # Magenta
COLOR_SUCCESS="1;32"  # Green
COLOR_ERROR="1;31"    # Red
COLOR_COMPLETE="1;33" # Yellow

step() { printf "\n\033[%sm==> %s\033[0m\n" "$COLOR_STEP" "$1"; }
success() { printf "\033[%sm  ✓ %s\033[0m\n" "$COLOR_SUCCESS" "$1"; }
error() { printf "\033[%sm  ! %s\033[0m\n" "$COLOR_ERROR" "$1"; }
finish() { printf "\n\033[%sm ✨ %s\033[0m\n" "$COLOR_COMPLETE" "$1"; }

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
    step "Detecting operating system..."

    if [ "$(uname)" = "Darwin" ]; then
        OS="macos"
    elif [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        OS="$ID"
    else
        error "Unsupported OS"
        exit 1
    fi

    # Validate OS is supported
    case "$OS" in
    arch | ubuntu | macos) ;;
    *)
        error "Unsupported OS: $OS"
        exit 1
        ;;
    esac

    success "detected: $OS"
}

install_macos_packages() {
    step "Installing packages for macOS..."

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
        fzf zoxide eza fd ripgrep bat \
        node imagemagick \
        oh-my-posh fastfetch \
        neovim \
        2>/dev/null
    brew install --quiet --cask ghostty font-jetbrains-mono-nerd-font 2>/dev/null

    success "macOS packages installed!"
}

install_ubuntu_packages() {
    step "Installing packages for ubuntu..."

    sudo apt update -qq
    sudo apt install -qq build-essential git unzip curl zsh tmux xsel stow

    if ! installed brew; then
        /bin/bash -c "$(curl -fsSL "$BREW_INSTALL_URL")"
        printf "%s\n" "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)\"" >>"$HOME/.zshrc.local"
    fi
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    brew install --quiet \
        fzf zoxide eza fd ripgrep bat \
        node imagemagick \
        oh-my-posh fastfetch \
        neovim \
        2>/dev/null
    brew install --quiet --cask font-jetbrains-mono-nerd-font 2>/dev/null

    # ghostty (stable)
    /bin/bash -c "$(curl -fsSL "$GHOSTTY_INSTALL_URL")"
    success "ubuntu packages installed!"
}

install_arch_packages() {
    step "Installing packages for arch..."

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

    success "arch packages installed!"
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
    step "Setting up language tools..."

    install_or_update "uv" \
        "curl -LsSf https://astral.sh/uv/install.sh | sh" \
        "uv self update"

    success "uv installed!"

    install_or_update "rustup" \
        "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" \
        "rustup update"

    success "rustup installed!"

    # installed by package managers
    if installed node; then
        success "node installed"
    fi

    curl -L --proto '=https' --tlsv1.2 -sSf $CARGO_BINSTALL_URL | bash 2>/dev/null
    cargo binstall -y tree-sitter-cli
    success "tree-sitter-cli installed!"
}

setup_shell() {
    step "Setting up zsh..."

    # Change shell to zsh
    if ! echo "$SHELL" | grep -q "zsh"; then
        chsh -s "$(which zsh)"
    fi
    if ! grep -q 'export ZDOTDIR=' "$HOME/.zshenv"; then
        # shellcheck disable=SC2016
        printf 'export ZDOTDIR="$HOME/.config/zsh"\nsource "$ZDOTDIR/.zshenv"\n' >>"$HOME/.zshenv"
    fi

    success "shell set to zsh!"

    # Install zinit for zsh plugins
    ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
    mkdir -p "$(dirname "$ZINIT_HOME")"
    clone_or_pull "https://github.com/zdharma-continuum/zinit.git" "$ZINIT_HOME"
    success "zinit installed!"

    # Update zsh plugins
    zsh -c "source '$ZINIT_HOME/zinit.zsh' && zinit update --quiet && compinit"
    success "zsh plugins updated!"

    # Live reload prompts on theme change
    oh-my-posh enable reload

    # Use clean nvim as git editor
    git config --global core.editor "nvim --clean"
}

setup_dotfiles() {
    step "Setting up dotfiles..."

    clone_or_pull "https://github.com/fsiraj/dotfiles.git" "$HOME/dotfiles"
    stow -v -d "$HOME/dotfiles" -t "$HOME/.config" .config

    success "dotfiles stowed!"
}

setup_tmux_plugins() {
    step "Setting up tmux plugins..."

    TPM_HOME="$HOME/.config/tmux/plugins/tpm"
    clone_or_pull "https://github.com/tmux-plugins/tpm" "$TPM_HOME"

    PLUGINS_DIR="$(dirname "$TPM_HOME")"
    if [ "$(find "$PLUGINS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)" -le 1 ]; then
        "$TPM_HOME/bin/install_plugins"
    else
        "$TPM_HOME/bin/update_plugins" all
    fi

    success "tmux plugins installed!"
}

setup_neovim_plugins() {
    step "Setting up neovim..."

    nvim --headless "+Lazy! sync" +qa
    nvim --headless "+MasonToolsUpdateSync" +qa

    echo "" && success "neovim plugins and language tools installed!"
}

main() {
    detect_os
    install_packages
    setup_language_tools
    setup_dotfiles
    setup_shell
    setup_tmux_plugins
    setup_neovim_plugins
    finish "Setup complete!"
}

main "$@"
