# XDG directories created in install.sh and set in .zshenv

# Keep PATH unique
typeset -U path PATH
path=("$XDG_BIN_HOME" "$MASON_BIN" $path)

# Source local shell customizations if present (needed here for linux brew)
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi

# Keep zsh in emacs mode, not vi
bindkey -e

# Custom completions
fpath=(~/.zfunc $fpath)

# Load prompt
eval "$(oh-my-posh init zsh --config "$HOME"/.config/ohmyposh/omp.json)"

# Restore a steady bar cursor whenever the shell prompt returns.
autoload -Uz add-zsh-hook
restore_bar_cursor() { printf '\e[5 q'; }
add-zsh-hook precmd restore_bar_cursor

# History
HISTSIZE=10000
HISTFILE=$ZDOTDIR/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory hist_find_no_dups hist_ignore_all_dups hist_ignore_space sharehistory

# Pre-compinit
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"
zinit light zsh-users/zsh-completions

# compinit rebuilt only if stale (most expensive operation)
autoload -Uz compinit
zcompdump=$ZDOTDIR/.zcompdump
cached=-C
[[ -s $zcompdump ]] || cached=
for dir in $fpath; do
    [[ $dir -nt $zcompdump ]] && cached= && break
done
compinit $cached
unset dir cached
zinit cdreplay -q

# Post-compinit
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

# Configure completion behavior
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey "^[[Z" autosuggest-accept                               # shift + tab
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' # case insensitive matching
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'         # show color for matches
zstyle ':completion:*' menu no                                  # disable defualt in favour of fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview '
    eza -aT --level=2 --color=always --icons=always $realpath
' # show directory preview on cd

# Load shell integrations
source <(jj util completion zsh)
eval "$(zoxide init --cmd cd zsh)"
source <(fzf --zsh)
bindkey -r '^[c'

# Custom functions and aliases

ansi16() {
    for i in {0..15}; do
        printf "\e[48;5;${i}m %3d \e[0m" "$i"
        (((i + 1) % 8 == 0)) && echo
    done
}

theme() {
    local theme="${1:-$(
        nvim --headless "+NvimColorschemes" +qa 2>&1 |
            fzf --reverse --height=16 --prompt "Select colorscheme: "
    )}"
    [[ -z "$theme" ]] && return
    nvim --headless "+NvimSyncTheme $theme" +qa 2>/dev/null
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

alias c="clear -x"
alias reload="clear -x && exec zsh"
alias install="bash ~/dotfiles/install.sh"

alias a=attach
alias n="nvim --clean"
alias py="python3"
alias venv="source .venv/bin/activate"

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

alias cat="bat -p"

if command -v fastfetch &>/dev/null; then ff() { fastfetch --config "$HOME"/.config/fastfetch/ff.jsonc "$@"; }
    if [[ $- == *i* && $COLUMNS -ge 100 && -z $NO_FF ]]; then
        ff
    fi
fi
