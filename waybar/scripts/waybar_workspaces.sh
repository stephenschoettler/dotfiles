#!/bin/bash

LOG_FILE="/tmp/waybar_workspaces.log"
# This script is called per monitor, so we append the monitor name to the log file
# to avoid race conditions and keep logs separate.
if [[ -n "$1" ]]; then
    LOG_FILE="/tmp/waybar_workspaces_$1.log"
fi

echo "--- Waybar Workspace Script Starting at $(date) for monitor $1 ---" > "$LOG_FILE"

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo "{\"text\": \"Error: jq not installed\", \"class\": \"error\"}"
    echo "Error: jq is not installed. Please install it to use this script." >> "$LOG_FILE"
    exit 1
fi

# Check for socat dependency
if ! command -v socat &> /dev/null; then
    echo "{\"text\": \"Error: socat not installed\", \"class\": \"error\"}"
    echo "Error: socat is not installed. Please install it to use this script." >> "$LOG_FILE"
    exit 1
fi

# --- Configuration ---
WORKSPACE_OFFSET=10
# ---------------------

# Attempt to get HYPRLAND_INSTANCE_SIGNATURE if not already set
# This is crucial for connecting to the correct Hyprland socket
if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    echo "HYPRLAND_INSTANCE_SIGNATURE environment variable is not set. Trying to derive it from hyprctl instance." >> "$LOG_FILE"
    HYPRLAND_INSTANCE_SIGNATURE=$(hyprctl instance | grep "instance" | awk '{print $NF}')
    if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
        echo "Error: Could not derive HYPRLAND_INSTANCE_SIGNATURE from 'hyprctl instance'." >> "$LOG_FILE"
        echo "{\"text\": \"Error: No Hyprland instance\", \"class\": \"error\"}"
        exit 1
    else
        echo "Derived HYPRLAND_INSTANCE_SIGNATURE: $HYPRLAND_INSTANCE_SIGNATURE" >> "$LOG_FILE"
    fi
else
    echo "HYPRLAND_INSTANCE_SIGNATURE is set: $HYPRLAND_INSTANCE_SIGNATURE" >> "$LOG_FILE"
fi

HYPR_INSTANCE_SOCKET_PATH="/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Check if the socket file exists before proceeding
if [[ ! -e "$HYPR_INSTANCE_SOCKET_PATH" ]]; then
    echo "Error: Hyprland socket file not found at $HYPR_INSTANCE_SOCKET_PATH. Hyprland might not be fully running or the signature is wrong." >> "$LOG_FILE"
    echo "{\"text\": \"Error: Socket not found\", \"class\": \"error\"}"
    exit 1
fi

generate_waybar_json() {
    local WAYBAR_MONITOR_NAME=$1
    echo "---" >> "$LOG_FILE"
    echo "Generating for monitor: '$WAYBAR_MONITOR_NAME' at $(date)" >> "$LOG_FILE"
    
    if [[ -z "$WAYBAR_MONITOR_NAME" ]]; then
        echo "Error: Monitor name not provided to script." >> "$LOG_FILE"
        echo "{\"text\": \"Error: No monitor name\", \"class\": \"error\"}"
        return
    fi

    local MONITORS
    MONITORS=$(hyprctl -j monitors)
    if [[ $? -ne 0 ]]; then echo "Error: Failed to get monitors from hyprctl." >> "$LOG_FILE"; return; fi

    local WORKSPACES
    WORKSPACES=$(hyprctl -j workspaces)
    if [[ $? -ne 0 ]]; then echo "Error: Failed to get workspaces from hyprctl." >> "$LOG_FILE"; return; fi
    
    local ACTIVE_WS_ON_MONITOR_ID
    ACTIVE_WS_ON_MONITOR_ID=$(echo "$MONITORS" | jq -r --arg name "$WAYBAR_MONITOR_NAME" '.[] | select(.name == $name) | .activeWorkspace.id')
    echo "Detected active workspace ID on this monitor: '$ACTIVE_WS_ON_MONITOR_ID'" >> "$LOG_FILE"

    local MONITOR_WORKSPACES
    MONITOR_WORKSPACES=$(echo "$WORKSPACES" | jq -c --arg name "$WAYBAR_MONITOR_NAME" '[.[] | select(.monitor == $name)] | sort_by(.id)')
    echo "Filtered workspaces for this monitor: $MONITOR_WORKSPACES" >> "$LOG_FILE"

    local JSON_OUTPUT="["
    local FIRST=true

    for ws in $(echo "${MONITOR_WORKSPACES}" | jq -r '.[] | @base64'); do
        _jq() {
            echo "${ws}" | base64 --decode | jq -r "${1}"
        }

        local WS_ID=$(_jq '.id')
        local WS_WINDOWS=$(_jq '.windows')

        local DISPLAY_ID=$WS_ID
        if (( WS_ID > WORKSPACE_OFFSET )); then
            DISPLAY_ID=$((WS_ID - WORKSPACE_OFFSET))
        fi

        local CLASSES=""
        if [[ "$WS_ID" == "$ACTIVE_WS_ON_MONITOR_ID" ]]; then
            CLASSES="active" # Use "active" to match the CSS
        fi
        
        local JSON_PART="{\"id\": ${WS_ID}, \"text\": \"${DISPLAY_ID}\", \"class\": \"${CLASSES}\"}"
        
        if $FIRST;
        then
            JSON_OUTPUT="$JSON_OUTPUT$JSON_PART"
            FIRST=false
        else
            JSON_OUTPUT="$JSON_OUTPUT,$JSON_PART"
        fi
    done

    JSON_OUTPUT="$JSON_OUTPUT]"
    echo "Final JSON for Waybar: $JSON_OUTPUT" >> "$LOG_FILE"
    echo "$JSON_OUTPUT"
}

# Initial output
generate_waybar_json "$1"

# Listen for Hyprland events
socat -u UNIX-CONNECT:"$HYPR_INSTANCE_SOCKET_PATH" - | while read -r event; do
    # Log all events for debugging
    echo "Received Hyprland event: $event" >> "$LOG_FILE"
    case ${event%>>*} in
        workspace|focusedmon|createworkspace|destroyworkspace|movewindow|monitoradded|monitorremoved)
            generate_waybar_json "$1"
    esac
done
