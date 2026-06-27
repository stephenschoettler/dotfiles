#!/usr/bin/env bash
set -euo pipefail

for cmd in awk cliphist fuzzel wl-copy; do
    command -v "$cmd" >/dev/null || { echo "Missing: $cmd" >&2; exit 1; }
done

max_items="${CLIPHIST_SELECTOR_LIMIT:-200}"
preview_width="${CLIPHIST_SELECTOR_PREVIEW_WIDTH:-140}"

if [[ ! "$max_items" =~ ^[0-9]+$ || "$max_items" -lt 1 ]]; then
    max_items=200
fi

if [[ ! "$preview_width" =~ ^[0-9]+$ || "$preview_width" -lt 20 ]]; then
    preview_width=140
fi

fuzzel_menu() {
    local prompt=$1 width=$2 lines=$3
    fuzzel --dmenu \
        --match-mode=fuzzy \
        --only-match \
        --prompt "$prompt" \
        --width "$width" \
        --lines "$lines"
}

confirm_clear() {
    local confirm
    confirm=$(
        printf '%s\n%s\n' "Cancel" "Clear clipboard history" |
            fuzzel_menu "Clear clipboard? " 38 2
    )

    [[ "$confirm" == "Clear clipboard history" ]] || exit 0

    cliphist wipe
    wl-copy --clear
}

selection=$(
    {
        printf '%-5s %s\n' "Clear" "clipboard history"
        # Keep launch fast by feeding fuzzel only the most recent entries. awk exits
        # after max_items; cliphist may then receive SIGPIPE, which is expected.
        {
            cliphist -preview-width "$preview_width" list |
                LC_ALL=C awk -v max="$max_items" 'BEGIN { FS="\t" } NR > max { exit } { id=$1; preview=$0; sub(/^[^\t]*\t/, "", preview); gsub(/[[:cntrl:]]/, " ", preview); printf "%-5s %s\n", id, preview }'
        } || true
    } |
        fuzzel_menu "Clipboard (${max_items}) " 76 14
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
