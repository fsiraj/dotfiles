#!/bin/bash
# shellcheck disable=SC1091
# shellcheck disable=SC2015

OS=""

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_BIN_HOME"

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
ok() {
    local code=$?
    [ "$code" -eq 0 ] && success "$1" || error "$1"
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
    step "Detecting operating system..."

    if [ "$(uname)" = "Darwin" ]; then
        OS="macos"
    elif [ -f /etc/os-release ]; then
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
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL "$BREW_INSTALL_URL")"
    fi
    if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install 2>/dev/null || true
    fi
    HOMEBREW_NO_UPDATE_REPORT_NEW=1 brew update --quiet
    brew install --quiet \
        git make unzip gnu-sed tmux stow \
        fzf zoxide eza fd ripgrep bat btop jq jj \
        node imagemagick \
        oh-my-posh fastfetch \
        neovim \
        2>/dev/null
    brew install --quiet --cask ghostty font-jetbrains-mono-nerd-font 2>/dev/null
    ln -sf "$(brew --prefix)/bin/gsed" "$XDG_BIN_HOME/sed"

    success "macOS packages installed!"
}

install_ubuntu_packages() {
    step "Installing packages for ubuntu..."

    sudo apt update -qq
    sudo apt install -y -qq build-essential git unzip curl zsh tmux xsel stow

    if ! installed brew; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL "$BREW_INSTALL_URL")"
    fi
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    HOMEBREW_NO_UPDATE_REPORT_NEW=1 brew update --quiet
    brew install --quiet \
        fzf zoxide eza fd ripgrep bat btop jq jj \
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

    sudo pacman -Syu --needed --noconfirm \
        base-devel git unzip \
        zsh tmux stow fastfetch ghostty \
        fzf zoxide eza fd ripgrep bat btop jq jujutsu \
        nodejs npm imagemagick \
        neovim \
        ttf-jetbrains-mono-nerd

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

    ok "uv installed!"

    install_or_update "rustup" \
        "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path" \
        "rustup update"
    ok "rustup installed!"
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

    # installed by package managers
    if installed node; then
        success "node installed"
    fi

    curl -L --proto '=https' --tlsv1.2 -sSf $CARGO_BINSTALL_URL | bash 2>/dev/null
    cargo binstall -y tree-sitter-cli
    ok "tree-sitter-cli installed!"
}

setup_shell() {
    step "Setting up zsh..."

    # Change shell to zsh
    if ! echo "$SHELL" | grep -q "zsh"; then
        sudo chsh -s "$(which zsh)" "$(id -un)"
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
    ok "zinit installed!"

    # Update zsh plugins
    zsh -ic "zinit update --quiet && compinit"
    ok "zsh plugins updated!"

    # Live reload prompts on theme change
    oh-my-posh enable reload

    # Use clean nvim as git editor
    git config --global core.editor "nvim --clean"
}

setup_dotfiles() {
    step "Setting up dotfiles..."

    clone_or_pull "https://github.com/fsiraj/dotfiles.git" "$HOME/dotfiles"
    stow -v -d "$HOME/dotfiles" -t "$HOME/.config" .config

    ok "dotfiles stowed!"
}

setup_tmux_plugins() {
    step "Setting up tmux plugins..."

    clone_or_pull "https://github.com/tmux-plugins/tmux-resurrect" \
        "$HOME/.config/tmux/plugins/tmux-resurrect"

    ok "tmux plugins installed!"
}

setup_neovim_plugins() {
    step "Setting up neovim..."

    nvim --headless "+Lazy! sync" +qa
    nvim --headless "+MasonToolsUpdateSync" +qa && echo
    ok "neovim plugins and language tools installed!"
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
