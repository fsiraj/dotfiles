export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_BIN_HOME="$HOME/.local/bin"
export PATH="$XDG_BIN_HOME:$PATH"
export EDITOR="nvim"
fpath=(~/.zfunc $fpath)

# Load prompt
eval "$(oh-my-posh init zsh --config "$HOME"/.config/ohmyposh/config.omp.toml)"

# History
HISTSIZE=10000
HISTFILE=~/.config/zsh/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory hist_find_no_dups hist_ignore_all_dups hist_ignore_space sharehistory

# Pre-compinit
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"
zinit light zsh-users/zsh-completions

# compinit (most expensive operation)
autoload -Uz compinit
zcompdump=${ZDOTDIR:-$HOME}/.zcompdump
if [[ $OSTYPE == darwin* ]]; then
    zcompdump_mtime=$(stat -f %m "$zcompdump" 2>/dev/null || print 0)
else
    zcompdump_mtime=$(stat -c %Y -- "$zcompdump" 2>/dev/null || print 0)
fi
(($(date +%s) - zcompdump_mtime > 86400)) && compinit || compinit -C
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
zstyle ':fzf-tab:complete:*' fzf-preview '
if [[ -d $realpath ]]; then
  eza -a --color=always $realpath
elif [[ -f $realpath ]]; then
  bat --theme base16 --color=always --style=plain $realpath
else
  printf "%s\n" "$word"
fi
' # tab completion preview

# Load shell integrations
eval "$(zoxide init --cmd cd zsh)"
source <(fzf --zsh)
bindkey -r '^[c'

# Custom aliases
if command -v eza &>/dev/null; then
    alias ls="eza --group-directories-first --color=auto --icons=auto"
    alias ll="ls -l"
    alias la="ls -a"
    alias lt="ls -T"
else
    alias ls="ls"
    alias ll="ls -Al"
    alias la="ls -A"
fi

alias c="clear -x"
alias cd..="cd .."
alias reload="exec zsh"
alias update="bash ~/dotfiles/install.sh"

alias ga="git add -v"
alias gc="git commit -vm"
alias gca="git commit --amend"
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

# Custom functions
neogit() {
    nvim +"lua require('neogit').open({ kind = 'replace' })"
}

theme() {
    local theme="${1:-$(
        nvim --headless "+=require('style').colorschemes" +qa 2>&1 |
            grep -o '"[^"]*"' | sed 's/"//g' |
            fzf --reverse --height=16 --prompt "Select colorscheme: "
    )}"
    nvim --headless "+lua require('style').sync_theme('$theme')" +qa 2>/dev/null
}

# fastfetch
if [[ $- == *i* ]]; then
    if command -v fastfetch &>/dev/null; then
        alias ff="fastfetch"
        fastfetch
    fi
fi

# Source local shell customizations if present
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
