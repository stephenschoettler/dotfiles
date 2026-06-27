#!/usr/bin/env bash
set -euo pipefail

# Prefer Hyprland's native agent when installed. Fall back to KDE's agent so
# package auth keeps working on machines that have not installed hyprpolkitagent.
if systemctl --user list-unit-files hyprpolkitagent.service >/dev/null 2>&1; then
    systemctl --user start hyprpolkitagent.service >/dev/null 2>&1 || true
    exit 0
fi

if [[ -x /usr/lib/hyprpolkitagent/hyprpolkitagent ]]; then
    exec /usr/lib/hyprpolkitagent/hyprpolkitagent
fi

if command -v hyprpolkitagent >/dev/null 2>&1; then
    exec hyprpolkitagent
fi

if [[ -x /usr/lib/polkit-kde-authentication-agent-1 ]]; then
    exec /usr/lib/polkit-kde-authentication-agent-1
fi

if command -v lxqt-policykit-agent >/dev/null 2>&1; then
    exec lxqt-policykit-agent
fi

exit 0
