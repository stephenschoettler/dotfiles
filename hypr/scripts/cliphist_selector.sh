#!/usr/bin/env bash
set -euo pipefail

for cmd in awk cliphist wofi wl-copy; do
    command -v "$cmd" >/dev/null || { echo "Missing: $cmd" >&2; exit 1; }
done

style="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/cliphist_selector.css"

wofi_common=(
    --dmenu
    --cache-file /dev/null
    --matching fuzzy
    --insensitive
    --no-custom-entry
    --style "$style"
)

confirm_clear() {
    local confirm
    confirm=$(
        printf '%s\n%s\n' "Cancel" "Clear clipboard history" |
            wofi "${wofi_common[@]}" \
                --prompt "Clear clipboard?" \
                --width 420 \
                --height 150 \
                --lines 2 \
                --location center
    )

    [[ "$confirm" == "Clear clipboard history" ]] || exit 0

    cliphist wipe
    wl-copy --clear
}

selection=$(
    {
        printf '%-5s %s\n' "Clear" "clipboard history"
        cliphist -preview-width 140 list |
            awk 'BEGIN { FS="\t" } { id=$1; preview=$0; sub(/^[^\t]*\t/, "", preview); gsub(/[[:cntrl:]]/, " ", preview); printf "%-5s %s\n", id, preview }'
    } |
        wofi "${wofi_common[@]}" \
            --prompt "Clipboard" \
            --width 760 \
            --height 560 \
            --lines 14 \
            --location center
)

[[ -n "$selection" ]] || exit 0

id="${selection%%[[:space:]]*}"

case "$id" in
    Clear)
        confirm_clear
        ;;
    ''|*[!0-9]*)
        exit 0
        ;;
    *)
        printf '%s' "$id" | cliphist decode | wl-copy
        ;;
esac
