#!/bin/zsh -f
# Theme helpers for the tinty-based setup.

accent_idx=22
script="${0:A}"

list() {
    tinty list | sed -nE 's/^base(16|24)-//p' | sort -u
}

pick() {
    list | fzf --reverse --prompt "Select colorscheme: " \
        --preview-window=up,21,nowrap,noinfo,border-none \
        --preview "$script preview {}"
}

resolve() {
    tinty list | grep -qx "base24-$1" && echo "base24-$1" || echo "base16-$1"
}

apply() {
    local name="${1:-$(pick)}"
    [ -z "$name" ] && return
    tinty apply "$(resolve "$name")"
}

preview() {
    local name="${1:-$(pick)}"
    [ -z "$name" ] && return
    local -A c; local k v n
    local scheme="$(resolve "$name")"
    # Map each slot (00..0F, 10..17) to its fg escape, lifted from tinty's swatch column
    tinty info "$scheme" | sed -nE 's/.*\[(38;2;[0-9;]+)m.*base(..) .*/\2 \1/p' |
        while read k v; do c[$k]=$'\e['${v}m; done
    local slot="$(accent_slot "$scheme")"
    local a="${c[$slot]:-${c[08]}}"
    local bg="${c[00]/38/48}"
    local comment=$'\e[3m'${c[04]} noitalic=$'\e[23m' dim=$'\e[2m' nodim=$'\e[22m'
    # Terminal indices 0..15, matching tinted-terminal's Ghostty templates.
    local -a ansi=(00 08 0B 0A 0D 0E 0C 05 03 08 0B 0A 0D 0E 0C 07)
    [[ $scheme == base24-* ]] && ansi[10,15]=(12 14 13 16 17 15)
    local -a swatches=("" "")
    for ((n = 0; n < 16; n++)); do
        k=${ansi[n + 1]}
        printf -v v '%s%s %3d ' "${c[$k]/38/48}" "${c[05]}" "$n"
        swatches[n/8+1]+=$v
    done
    # Rust token colors match test/test.html; use scheme slots instead of its Ayu RGBs.
    local -a code=(
        ""
        " ${comment}# Zsh$noitalic"
        # A completed command, then the full Oh My Posh prompt with sample segments.
        " $c[03]╭─ $c[05]tinted palette"
        " ${swatches[1]}$bg"
        " ${swatches[2]}$bg"
        " $c[03]╰─ 16ms"
        ""
        " ${a}╭─ devbox $c[05]• $c[0B]~/dotfiles $c[05]• $c[0D]@ p${dim} ~5 main${nodim} $c[05]• $c[0E] ${dim}.venv${nodim} "
        " ${a}╰─ "
        ""
        " ${comment}// Neovim$noitalic"
        " $c[0D]use $c[08]tinty$c[0F]::$c[05]{$c[0A]Scheme$c[0F], $c[0A]Theme$c[05]}$c[0F];"
        ""
        " $c[0E]fn $c[0D]apply$c[05]($c[08]name$c[0F]: $c[05]&$c[0A]str$c[05]) $c[0F]-> $c[0A]Option$c[05]<$c[0A]Theme$c[05]> {"
        " $c[05]    $c[0E]let $c[05]scheme = $c[0A]Scheme$c[0F]::$c[0D]load$c[05](name)?$c[0F];"
        " $c[05]    $c[0E]let $c[05]theme = scheme$c[0F].$c[0D]with_base$c[05]($c[09]16$c[05])$c[0F].$c[0D]build$c[05]()$c[0F];"
        " $c[05]    theme$c[0F].$c[0D]apply$c[05]()$c[0F];"
        " $c[05]    $c[08]println!$c[05]($c[0B]\"applied: {}\"$c[0F], $c[05]theme$c[0F].$c[0D]name$c[05]())$c[0F];"
        " $c[05]    $c[09]Some$c[05](theme)"
        " $c[05]}"
        ""
    )
    # Paint base00 behind each line; \e[K extends it to the edge
    printf "${bg}%s\e[K\n" "${code[@]}"
    printf '\e[0m'
}

sync_ghostty() {
    dst="$HOME/.config/ghostty/theme.ghostty"
    [ -n "$TINTY_THEME_FILE_PATH" ] && cp -f "$TINTY_THEME_FILE_PATH" "$dst"
    printf 'palette = %s=%s\n' "$accent_idx" "$(accent --hex)" >> "$dst"
    killall -SIGUSR2 ghostty 2>/dev/null || true
}

sync_claude() {
    [ -n "$CLAUDE_CONFIG_DIR" ] || return 0
    mkdir -p "$CLAUDE_CONFIG_DIR/themes"
    node "$TINTY_THEME_FILE_PATH" > "$CLAUDE_CONFIG_DIR/themes/tinted.json"
}

accent_slot() {
    local slot
    case "$1" in
        *tokyo-night-terminal*)   slot=08 ;;
        *ayu*|*gruvbox*)          slot=09 ;;
        *rose-pine*)              slot=0A ;;
        *nord*)                   slot=0D ;;
        *tokyo-night*)            slot=12 ;;
        *)                        slot=0E ;;
    esac
    printf '%s' "$slot"
}

accent() {
    [[ $1 == --ansi ]] && { printf 'colour%s' "$accent_idx"; return; }
    local slot="$(accent_slot "$(tinty current 2>/dev/null)")"
    if [[ $1 == --hex ]]; then
        tinty info 2>/dev/null | awk -F'|' -v s="base$slot" '$3~s{gsub(/ /,"",$4);print $4;exit}'
    else
        printf '%s' "$slot"
    fi
}

palette() {
    local all i r b bc t
    [[ $1 == --all ]] && all=1
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
    preview) preview "$2" ;;
    accent ) accent  "$2" ;;
    palette) palette "$2" ;;
    sync-ghostty) sync_ghostty ;;
    sync-claude ) sync_claude  ;;
    *) cat >&2 <<'EOF'
Theme helpers for the tinty-based setup.

USAGE:
  tinted.sh <subcommand> [flags]  

COMMANDS:
  list                     -> scheme names, base24 preferred over base16
  apply   [name]           -> apply base24-<name> if it exists, else base16-<name>; fzf picks if omitted
  preview [name]           -> prompt and syntax samples in the scheme's colors; fzf picks if omitted
  accent  [--hex|--ansi]   -> curated accent's color in base16/24 slot, hex, or ansi
  palette [--all|<index>]  -> print the terminal color palette
EOF
       exit 1 ;;
esac
