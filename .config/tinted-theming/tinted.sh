#!/bin/zsh -f
# Theme helpers for the tinty-based setup. One file, several subcommands:
#   tinted.sh list                  -> scheme names, base24 preferred over base16
#   tinted.sh apply <name>          -> apply base24-<name> if it exists, else base16-<name>
#   tinted.sh accent [--hex|--ansi] -> curated accent's color in base16/24 slot, hex, or ansi
#   tinted.sh palette [-a|idx]      -> print the terminal color palette

accent_idx=22

list() {
    tinty list | sed -nE 's/^base(16|24)-//p' | sort -u
}

apply() {
    name="$1"
    [ -z "$name" ] && return
    tinty list | grep -qx "base24-$name" && sys=base24 || sys=base16
    tinty apply "$sys-$name"
}

sync_ghostty() {
    dst="$HOME/.config/ghostty/theme.ghostty"
    [ -n "$TINTY_THEME_FILE_PATH" ] && cp -f "$TINTY_THEME_FILE_PATH" "$dst"
    printf 'palette = %s=%s\n' "$accent_idx" "$(accent --hex)" >> "$dst"
    killall -SIGUSR2 ghostty 2>/dev/null || true
}

sync_claude() {
    mkdir -p "$HOME/.claude/themes"
    node "$TINTY_THEME_FILE_PATH" > "$CLAUDE_CONFIG_DIR/themes/tinted.json"
}

accent() {
    [[ $1 == --ansi ]] && { printf 'colour%s' "$accent_idx"; return; }
    local slot
    case "$(tinty current 2>/dev/null)" in
        *tokyo-night-terminal*)   slot=08 ;;
        *ayu*|*gruvbox*)          slot=09 ;;
        *rose-pine*)              slot=0A ;;
        *nord*)                   slot=0D ;;
        *tokyo-night*)            slot=12 ;;
        *)                        slot=0E ;;
    esac
    if [[ $1 == --hex ]]; then
        tinty info 2>/dev/null | awk -F'|' -v s="base$slot" '$3~s{gsub(/ /,"",$4);print $4;exit}'
    else
        printf '%s' "$slot"
    fi
}

palette() {
    local all i r b bc t
    [[ $1 == -a || $1 == --all ]] && all=1
    # Print one cell: the index over its color as background
    cell() printf "\e[48;5;%dm %3d \e[0m" $1 $1
    # Single index: print its cell, then query the terminal for its hex
    if [[ $1 == <-> ]]; then
        cell $1; unfunction cell
        printf '\e]4;%d;?\e\\' $1; read -rs -d '\' -t 0.2 r
        printf '%s\n' "$r" | sed -E 's/.*rgb:(..)..\/(..)..\/(..).*/: #\1\2\3/'
        return
    fi
    # Base 16: two rows of 8
    for ((i = 0; i < 16; i++)); do
        cell $i; (((i + 1) % 8 == 0)) && echo
    done
    if [[ -n $all ]]; then
        echo
        # 6x6x6 cube (16-231): 2x3 grid of 6x6 blocks
        for ((t = 0; t < 12; t++)); do
            for ((bc = 0; bc < 3; bc++)); do
                r=$((t / 6 * 3 + bc))
                for ((b = 0; b < 6; b++)); do cell $((16 + 36 * r + 6 * (t % 6) + b)); done
                ((bc < 2)) && printf "  "
            done
            echo; ((t == 5)) && echo
        done
        echo
        # Grayscale 232-255: two rows of 12
        for ((i = 232; i < 256; i++)); do
            cell $i; (((i - 231) % 8 == 0)) && echo
        done
    fi
    unfunction cell
}

case "$1" in
    list   ) list         ;;
    apply  ) apply   "$2" ;;
    accent ) accent  "$2" ;;
    palette) palette "$2" ;;
    sync-ghostty) sync_ghostty ;;
    sync-claude ) sync_claude  ;;
    *) echo "usage: tinted.sh {list|apply <name>|accent [--hex|--ansi]|palette [-a|<index>]}" >&2; exit 1 ;;
esac
