# Force XDG-compliance
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"

# User specific
export EDITOR="nvim"
export FZF_DEFAULT_OPTS="--color=base16,pointer:#d7005f,separator:black"
export HOMEBREW_NO_ENV_HINTS=true
export MASON_BIN="$HOME/.local/share/nvim/mason/bin"
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
export CLAUDE_CODE_PLUGIN_CACHE_DIR="$CLAUDE_CONFIG_DIR/plugins"
. "$HOME/.cargo/env"

# Unnecessary and slow
export skip_global_compinit=1
