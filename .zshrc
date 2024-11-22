OS=$(uname -s)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

# Oh My Posh - Prompt
if ! command -v oh-my-posh &> /dev/null; then
    [ "$OS" = "Linux" ] && curl -s https://ohmyposh.dev/install.sh | bash -s
    [ "$OS" = "Darwin" ] && brew install jandedobbeleer/oh-my-posh/oh-my-posh
fi
POSH_CONFIG_NAME="simple"
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/$POSH_CONFIG_NAME.omp.toml)"

# Zinit - plugin manager
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Load plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -U compinit && compinit
zinit cdreplay -q

# Configure completion behavior
bindkey "^[[Z" autosuggest-accept # shift + tab
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' # case insensitive matching
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}' # show color for matches
zstyle ':completion:*' menu no # disable defualt in favour of fzf-tab
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -a $realpath' # preview for zoxide

# Configure history
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

# Load shell integrations
eval "$(zoxide init --cmd cd zsh)"
if [ "$OS" = "Linux" ]; then
    # Outdated package doesn't support --zsh
    source /usr/share/doc/fzf/examples/completion.zsh
    source /usr/share/doc/fzf/examples/key-bindings.zsh
elif [ "$OS" = "Darwin" ]; then
    eval "$(fzf --zsh)"
fi

# Define aliases
alias ls="eza -a --group-directories-first --color=auto --icons=auto"
alias ll="eza -al --group-directories-first --color=auto --icons=auto"
alias cc="clear"
alias cd..="cd .."
alias py="python3"
alias pyv="python3 --version"
alias d="deactivate"

alias ga="git add -v"
alias gc="git commit -vm"
alias gs="git status -sb"
alias gl="git log --oneline -n 10"
alias gch="git checkout"
alias gchb="git checkout -b"
alias gp="git pull"
alias gd="git diff"
alias grhh="git reset --hard HEAD"

alias suggest="gh copilot suggest"
alias explain="gh copilot explain"

alias zshrc="code ~/.zshrc"
alias reload="source ~/.zshrc"

alias vim="nvim"

# Define helpers
src() {
    source "$1/bin/activate"
}
pyvenv() {
    python3 -m venv "$1"
    src "$1"
}
