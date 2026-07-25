# This is the only file that needs a symlink in $HOME
export ZDOTDIR="$HOME/.config/zsh"

# Force XDG-compliance
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"

# User specific
export EDITOR="nvim"
export TMUX_PLUGIN_DIR="$XDG_CONFIG_HOME/tmux/plugins"

export FZF_DEFAULT_OPTS="\
--cycle --color=base16,pointer:22,separator:0,info:-1:dim,gutter:232,bg+:232 \
--bind tab:down,btab:up,ctrl-space:toggle,change:top \
--bind ctrl-d:half-page-down,ctrl-u:half-page-up \
--bind bspace:backward-delete-char,ctrl-h:backward-delete-char \
"
export HOMEBREW_NO_ENV_HINTS=true
export MASON_BIN="$HOME/.local/share/nvim/mason/bin"
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
export CLAUDE_CODE_TMUX_TRUECOLOR=1

# Keep PATHs unique
typeset -U path PATH
typeset -U fpath FPATH
path=("$XDG_BIN_HOME" "$MASON_BIN" $path)
fpath=(~/.zfunc $fpath)

# Set up cargo and brew
cargo_env="$HOME/.cargo/env"
for brew_bin in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [ -x "$brew_bin" ] && eval "$("$brew_bin" shellenv zsh)" && break
done
[ -f "$cargo_env" ] && source "$cargo_env"

# Unnecessary and slow
export skip_global_compinit=1
