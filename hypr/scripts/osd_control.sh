#!/usr/bin/env bash
set -euo pipefail

kind=${1:-}
action=${2:-}
max_volume=${OSD_MAX_VOLUME:-150}
volume_limit=$(awk -v v="$max_volume" 'BEGIN { printf "%.2f", v / 100 }')
brightness_device=${OSD_BRIGHTNESS_DEVICE:-nvidia_wmi_ec_backlight}
osd_monitor_mode=${OSD_MONITOR_MODE:-all}

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send "Hyprland" "$*" >/dev/null 2>&1 || true
}

swayosd_monitor_args() {
    local monitor="${OSD_MONITOR:-}"

    case "$osd_monitor_mode" in
        all|"")
            return 0
            ;;
        focused)
            if [[ -z "$monitor" ]] && command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
                monitor=$(hyprctl monitors -j 2>/dev/null | jq -r 'map(select(.focused))[0].name // empty' 2>/dev/null || true)
            fi
            ;;
        *)
            monitor="$osd_monitor_mode"
            ;;
    esac

    if [[ -n "$monitor" ]]; then
        printf '%s\0%s\0' --monitor "$monitor"
    fi
}

run_swayosd() {
    local -a monitor_args=()
    local arg

    while IFS= read -r -d '' arg; do
        monitor_args+=("$arg")
    done < <(swayosd_monitor_args)

    swayosd-client "${monitor_args[@]}" "$@"
}

play_volume_feedback() {
    local sound="${OSD_VOLUME_SOUND:-/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga}"

    [[ -r "$sound" ]] || return 0

    if command -v paplay >/dev/null 2>&1; then
        paplay "$sound" >/dev/null 2>&1 &
    elif command -v pw-play >/dev/null 2>&1; then
        pw-play "$sound" >/dev/null 2>&1 &
    fi
}

fallback_volume() {
    case "$action" in
        up) wpctl set-volume --limit "$volume_limit" @DEFAULT_AUDIO_SINK@ 5%+ ;;
        down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
        micmute) wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
        *) exit 2 ;;
    esac
}

fallback_brightness() {
    case "$action" in
        up) brightnessctl --device="$brightness_device" set +10% ;;
        down) brightnessctl --device="$brightness_device" set 10%- ;;
        max) brightnessctl --device="$brightness_device" set 100% ;;
        *) exit 2 ;;
    esac
}

case "$kind:$action" in
    volume:up)
        if command -v swayosd-client >/dev/null 2>&1; then
            run_swayosd --output-volume +5 --max-volume "$max_volume" || fallback_volume
        else
            fallback_volume
        fi
        play_volume_feedback
        ;;
    volume:down)
        if command -v swayosd-client >/dev/null 2>&1; then
            run_swayosd --output-volume -5 --max-volume "$max_volume" || fallback_volume
        else
            fallback_volume
        fi
        play_volume_feedback
        ;;
    volume:mute)
        if command -v swayosd-client >/dev/null 2>&1; then
            run_swayosd --output-volume mute-toggle || fallback_volume
        else
            fallback_volume
        fi
        play_volume_feedback
        ;;
    volume:micmute)
        if command -v swayosd-client >/dev/null 2>&1; then
            run_swayosd --input-volume mute-toggle || fallback_volume
        else
            fallback_volume
        fi
        ;;
    brightness:up)
        if command -v swayosd-client >/dev/null 2>&1; then
            run_swayosd --brightness +10 --device "$brightness_device" || fallback_brightness
        else
            fallback_brightness
        fi
        ;;
    brightness:down)
        if command -v swayosd-client >/dev/null 2>&1; then
            run_swayosd --brightness -10 --device "$brightness_device" || fallback_brightness
        else
            fallback_brightness
        fi
        ;;
    brightness:max)
        fallback_brightness
        notify "Brightness set to 100%"
        ;;
    media:play)
        if command -v swayosd-client >/dev/null 2>&1; then
            run_swayosd --playerctl play-pause || exec playerctl play-pause
        else
            exec playerctl play-pause
        fi
        ;;
    media:next)
        if command -v swayosd-client >/dev/null 2>&1; then
            run_swayosd --playerctl next || exec playerctl next
        else
            exec playerctl next
        fi
        ;;
    media:prev)
        if command -v swayosd-client >/dev/null 2>&1; then
            run_swayosd --playerctl previous || exec playerctl previous
        else
            exec playerctl previous
        fi
        ;;
    media:stop)
        exec playerctl stop
        ;;
    *)
        echo "Usage: ${0##*/} <volume|brightness|media> <action>" >&2
        exit 2
        ;;
esac
