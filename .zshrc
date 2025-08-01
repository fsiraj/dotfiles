OS=$(uname -s)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_BIN_HOME="$HOME/.local/bin"
export PATH="$XDG_BIN_HOME:$PATH"

# ohmyposh
if ! command -v oh-my-posh &>/dev/null; then
    [ "$OS" = "Linux" ] && curl -s https://ohmyposh.dev/install.sh | bash -s
    [ "$OS" = "Darwin" ] && brew install jandedobbeleer/oh-my-posh/oh-my-posh
fi
POSH_CONFIG_NAME="simple"
eval "$(oh-my-posh init zsh --config "$HOME"/.config/ohmyposh/$POSH_CONFIG_NAME.omp.toml)"

# zinit
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# fzf
FZF_ROOT="$XDG_BIN_HOME/.fzf"
if [ ! -d "$FZF_ROOT" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_ROOT"
    "$FZF_ROOT"/install --bin && cp "$FZF_ROOT/bin/fzf" "$XDG_BIN_HOME"
fi

# zoxide
if ! command -v zoxide &>/dev/null; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# uv
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Load plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -U compinit && compinit
zinit cdreplay -q

# Configure completion behavior
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey "^[[Z" autosuggest-accept                                      # shift + tab
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'        # case insensitive matching
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'                # show color for matches
zstyle ':completion:*' menu no                                         # disable defualt in favour of fzf-tab
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
source <(fzf --zsh)

# Define aliases
if command -v eza &>/dev/null; then
    alias ls="eza --git-ignore --group-directories-first --color=auto --icons=auto"
    alias ll="eza -al --group-directories-first --color=auto --icons=auto"
    alias la="eza -a --group-directories-first --color=auto --icons=auto"
else
    alias ls="ls"
    alias ll="ls -Al"
    alias la = "ls -A"
fi

alias c="clear -x"
alias cd..="cd .."
alias reload="source ~/.zshrc"

alias ga="git add -v"
alias gc="git commit -vm"
alias gs="git status -sb"
alias gl="git log --oneline -n 10"
alias gb="git branch"
alias gch="git checkout"
alias gp="git pull"
alias gd="git diff"
alias grhh="git reset --hard HEAD"
alias grs="git restore --staged"

alias py="python3"
alias venv="source .venv/bin/activate"
alias d="deactivate"

alias n="nvim"
