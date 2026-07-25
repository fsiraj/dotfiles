# Force XDG-compliance
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"

# User specific
export EDITOR="nvim"
export FZF_DEFAULT_OPTS="\
--cycle --color=base16,pointer:22,separator:0,info:-1:dim,gutter:232,bg+:232 \
--bind tab:down,btab:up,ctrl-space:toggle,change:top \
--bind ctrl-d:half-page-down,ctrl-u:half-page-up \
--bind bspace:backward-delete-char/eof,ctrl-h:backward-delete-char/eof"
export HOMEBREW_NO_ENV_HINTS=true
export MASON_BIN="$HOME/.local/share/nvim/mason/bin"
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
export CLAUDE_CODE_PLUGIN_CACHE_DIR="$CLAUDE_CONFIG_DIR/plugins"
export CLAUDE_CODE_TMUX_TRUECOLOR=1

cargo_env="$HOME/.cargo/env"
brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"

[ -f "$cargo_env" ] && source "$cargo_env"
[ -f "$brew_bin" ] && eval "$("$brew_bin" shellenv zsh)"

# Unnecessary and slow
export skip_global_compinit=1
