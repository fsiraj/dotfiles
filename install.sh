#!/bin/bash
# shellcheck disable=SC1091
# shellcheck disable=SC2015

OS=""

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_BIN_HOME"
PATH=$PATH:$XDG_BIN_HOME

BREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
GHOSTTY_INSTALL_URL="https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh"
CARGO_BINSTALL_URL="https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh"
OH_MY_POSH_INSTALL_URL="https://ohmyposh.dev/install.sh"

ZINIT_REPO_URL="https://github.com/zdharma-continuum/zinit.git"
DOTFILES_REPO_URL="https://github.com/fsiraj/dotfiles.git"
TMUX_RESURRECT_REPO_URL="https://github.com/tmux-plugins/tmux-resurrect"
TMUX_CONTINUUM_REPO_URL="https://github.com/tmux-plugins/tmux-continuum"

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
    local vcs="${3:-git}"

    if [ "$vcs" = "jj" ]; then
        [ ! -d "$dest" ] && jj git clone --colocate "$url" "$dest" || jj -R "$dest" git fetch
    else
        [ ! -d "$dest" ] && git clone "$url" "$dest" || git -C "$dest" pull
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

install_tools() {
    case "$OS" in
        macos) install_macos_packages ;;
        arch) install_arch_packages ;;
        ubuntu) install_ubuntu_packages ;;
    esac
    install_standalone_tools
}

install_macos_packages() {
    step "Installing packages for macOS..."

    if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install 2>/dev/null || true
    fi

    install_brew
    brew install --quiet \
        git make unzip gnu-sed stow \
        tmux neovim \
        fzf zoxide eza fd ripgrep bat btop jq jj \
        node imagemagick fastfetch \
        2>/dev/null
    brew install --quiet --cask ghostty font-jetbrains-mono-nerd-font 2>/dev/null
    ln -sf "$(brew --prefix)/bin/gsed" "$XDG_BIN_HOME/sed"

    success "macOS packages installed!"
}

install_ubuntu_packages() {
    step "Installing packages for ubuntu..."

    sudo apt update -qq
    sudo apt install -y -qq build-essential git unzip curl zsh xsel stow

    install_brew
    brew install --quiet \
        tmux neovim \
        fzf zoxide eza fd ripgrep bat btop jq jj \
        node imagemagick fastfetch \
        2>/dev/null
    brew install --quiet --cask font-jetbrains-mono-nerd-font 2>/dev/null

    # ghostty (stable)
    /bin/bash -c "$(curl -fsSL "$GHOSTTY_INSTALL_URL")"
    success "ubuntu packages installed!"
}

install_arch_packages() {
    step "Installing packages for arch..."
    sudo pacman -Syu --needed --noconfirm \
        base-devel git unzip less \
        tmux neovim \
        zsh stow fastfetch ghostty \
        fzf zoxide eza fd ripgrep bat btop jq jujutsu \
        nodejs npm imagemagick \
        ttf-jetbrains-mono-nerd

    success "arch packages installed!"
}

install_brew() {
    local brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"
    [ "$OS" = "macos" ] && brew_bin="/opt/homebrew/bin/brew"

    if ! installed brew; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL "$BREW_INSTALL_URL")"
    fi
    eval "$("$brew_bin" shellenv zsh)"
    HOMEBREW_NO_UPDATE_REPORT_NEW=1 brew update --quiet
}

install_standalone_tools() {
    step "Installing tools via their own installer scripts..."

    install_or_update "oh-my-posh" \
        "curl -s $OH_MY_POSH_INSTALL_URL | bash -s" \
        "oh-my-posh upgrade --force"
    ok "oh-my-posh installed!"

    install_or_update "uv" \
        "curl -LsSf https://astral.sh/uv/install.sh | sh" \
        "uv self update"
    ok "uv installed!"

    install_or_update "rustup" \
        "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path" \
        "rustup update 2>/dev/null"
    ok "rustup installed!"
    [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

    curl -L --proto '=https' --tlsv1.2 -sSf $CARGO_BINSTALL_URL | bash 2>/dev/null
    cargo binstall -y tree-sitter-cli
    ok "tree-sitter-cli installed!"

    cargo binstall -y tinty
    ok "tinty installed!"
}

symlink_dotfiles() {
    step "Setting up dotfiles..."

    clone_or_pull "$DOTFILES_REPO_URL" "$HOME/dotfiles" jj
    stow -v -d "$HOME/dotfiles" -t "$XDG_CONFIG_HOME" .config
    ln -sf "$XDG_CONFIG_HOME/zsh/.zshenv" "$HOME/.zshenv"

    ok "dotfiles stowed!"
}

setup_tools() {
    install_zsh_plugins
    install_tmux_plugins
    install_neovim_plugins
    setup_zsh
    setup_tinty
}

install_zsh_plugins() {
    step "Setting up zsh plugins..."

    ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
    mkdir -p "$(dirname "$ZINIT_HOME")"
    clone_or_pull "$ZINIT_REPO_URL" "$ZINIT_HOME"
    ok "zinit installed!"

    zsh -ic "zinit update --quiet && compinit"

    ok "zsh plugins installed!"
}

install_tmux_plugins() {
    step "Setting up tmux plugins..."

    TMUX_PLUGIN_DIR="$XDG_CONFIG_HOME/tmux/plugins"

    clone_or_pull "$TMUX_RESURRECT_REPO_URL" "$TMUX_PLUGIN_DIR/tmux-resurrect"
    clone_or_pull "$TMUX_CONTINUUM_REPO_URL" "$TMUX_PLUGIN_DIR/tmux-continuum"

    ok "tmux plugins installed!"
}

install_neovim_plugins() {
    step "Setting up neovim..."

    nvim --headless "+Lazy! restore" +qa && echo

    ok "neovim plugins installed!"
}

setup_zsh() {
    step "Setting up zsh..."

    if [[ "${SHELL##*/}" != zsh ]]; then
        sudo chsh -s "$(command -v zsh)" "$(id -un)"
    fi

    success "shell set to zsh!"
}

setup_tinty() {
    step "Setting up tinty..."

    tinty sync
    tinty apply "$(tinty current 2>/dev/null || echo base16-catppuccin-mocha)"

    ok "tinty installed!"
}

main() {
    detect_os

    install_tools
    symlink_dotfiles
    setup_tools

    finish "Setup complete!"
}

main "$@"
