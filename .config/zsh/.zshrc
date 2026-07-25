# XDG directories created in install.sh and set in .zshenv

# Keep PATH unique
typeset -U path PATH
path=("$XDG_BIN_HOME" "$MASON_BIN" $path)

# Keep zsh in emacs mode, not vi
bindkey -e

# Free up C-s for nested tmux prefix
stty -ixon

# Custom completions
fpath=(~/.zfunc $fpath)

# Load prompt
eval "$(oh-my-posh init zsh --config "$HOME"/.config/ohmyposh/omp.json)"

# History
HISTSIZE=10000
HISTFILE=$ZDOTDIR/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory hist_find_no_dups hist_ignore_all_dups hist_ignore_space sharehistory

# Zinit
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

# Compinit (most expensive step)
_zsh_setup_completions() {
    zicompinit
    zicdreplay
    source <(zoxide init --cmd cd zsh)  # Tab + Space-Tab completion for cd
    source <(fzf --zsh)                 # Hijacks Tab completion and sets keybinds 
    bindkey -r '^[c'
}

# Plugins (turbo mode)
zinit wait lucid light-mode for \
    atload'_zsh_setup_completions' zsh-users/zsh-completions \
                                   Aloxaf/fzf-tab \
    atload'_zsh_autosuggest_start' zsh-users/zsh-autosuggestions \
                                   zsh-users/zsh-syntax-highlighting

# Configure completion behavior
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
bindkey "^[[Z" autosuggest-accept                               # shift + tab
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' # case insensitive matching
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'         # show color for matches
zstyle ':completion:*' menu no                                  # disable defualt in favour of fzf-tab
zstyle ':fzf-tab:*' use-fzf-default-opts yes                    # inherit opts from fzf env vars
zstyle ':fzf-tab:complete:cd:*' fzf-preview '
    eza -aT --level=2 --color=always --icons=always $realpath
'                                                               # show directory preview on cd

# Custom functions and aliases
tinted() {
    "$HOME/.config/tinted-theming/tinted.sh" "$@"
}

theme() {
    local theme="${1:-$(tinted list | fzf --reverse --prompt "Select colorscheme: ")}"
    [[ -z "$theme" ]] && return
    tinted apply "$theme"
}

palette() {
    tinted palette "$@"
}

attach() {
    if [[ -z "$1" ]]; then
        local sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -v '^_')
        [[ -z "$sessions" ]] && echo "No tmux sessions." && return 1
        local session=$(echo "$sessions" | fzf --reverse --height=16 --prompt "Session: ")
        [[ -z "$session" ]] && return 1
        tmux attach -t "$session"
    else
        tmux new -A -s "$1"
    fi
}

alias clear="clear -x"
alias reload="clear -x && exec zsh"
alias install="bash ~/dotfiles/install.sh"

alias ls="eza --group-directories-first --color=auto --icons=auto"
alias ll="ls -l --time-style=relative"
alias la="ls -a"
alias lt="ls -T"
alias lla="ls -al"

alias ga="git add -v"
alias gc="git commit -vm"
alias gca="git commit --amend"
alias gs="git status -sb"
gl() {
    git log -n 15 --color=always --pretty=format:'%C(auto)%h%x1f%d%x1f%s' "$@" |
        awk -F$'\x1f' '$2=="" {print $1" "$3; next} {printf "%s%s\n        %s\n",$1,$2,$3}'
}
alias gb="git branch"
alias gch="git checkout"
alias gp="git pull"
alias gf="git fetch"
alias gd="git diff"
alias grhh="git reset --hard HEAD"
alias grs="git restore --staged"

alias venv="source .venv/bin/activate"

# Source local shell customizations if present
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi

# System Info
if command -v fastfetch &>/dev/null; then
    ff() { fastfetch --config "$HOME"/.config/fastfetch/ff.jsonc "$@"; }
    if [[ $- == *i* && $COLUMNS -ge 100 && -z $NO_FF ]]; then
        ff
    fi
fi
