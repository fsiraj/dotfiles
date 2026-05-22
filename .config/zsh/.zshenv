# Force XDG-compliance
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_BIN_HOME="$HOME/.local/bin"

# User specific
export EDITOR="nvim"
export HOMEBREW_NO_ENV_HINTS=true
export MASON_BIN="$HOME/.local/share/nvim/mason/bin"
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export CLAUDE_CODE_PLUGIN_CACHE_DIR="$CLAUDE_CONFIG_DIR/plugins"
. "$HOME/.cargo/env"

# Unnecessary and slow
export skip_global_compinit=1
