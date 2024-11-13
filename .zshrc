OS=$(uname -s)

# Set XDG paths
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

# Oh My Posh - Prompt - install if unavailable
if ! command -v oh-my-posh &> /dev/null; then
    if [ "$OS" = "Linux" ]; then
        curl -s https://ohmyposh.dev/install.sh | bash -s
    elif [ "$OS" = "Darwin" ]; then
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
    fi
fi
POSH_CONFIG_NAME="simple"
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/$POSH_CONFIG_NAME.omp.toml)"

# Zinit - plugin manager - install if unavailable
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Autocomplete and suggestions
autoload -U compinit && compinit
zinit cdreplay -q

bindkey "^[[Z" autosuggest-accept # shift + tab
zstyle ":completion:*" matcher-list "m:{[:lower:]}={[:upper:]}" # case insensitive matching
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}" # show color for matches
zstyle ":completion:*" menu no # disable defualt in favour of fzf-tab
zstyle ":fzf-tab:complete:cd:*" fzf-preview "ls --color=always $realpath" # preview for cd
zstyle ":fzf-tab:complete:__zoxide_z:*" fzf-preview "ls --color=always $realpath" # preview for zoxide

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Shell Integrations
eval "$(zoxide init --cmd cd zsh)"
if [ "$OS" = "Linux" ]; then
    # Outdated package doesn't support --zsh
    source /usr/share/doc/fzf/examples/completion.zsh
    source /usr/share/doc/fzf/examples/key-bindings.zsh
elif [ "$OS" = "Darwin" ]; then
    eval "$(fzf --zsh)"
fi

# Aliases

## Common
alias ls="ls -A --color"
alias ll="ls -Al --color"
alias cc="clear"
alias cd..="cd .."
alias py="python3"
alias pyv="python3 --version"
alias d="deactivate"

## Git
alias ga="git add -v"
alias gc="git commit -vm"
alias gs="git status -sb"
alias gl="git log --oneline -n 10"
alias gch="git checkout"
alias gchb="git checkout -b"
alias gp="git pull"

# Edit ZSH
alias zshrc="code ~/.zshrc"
alias reload="source ~/.zshrc"

# Helpers

src() {
    source "$1/bin/activate"
}

pyvenv() {
    python3 -m venv "$1"
    src "$1"
}
