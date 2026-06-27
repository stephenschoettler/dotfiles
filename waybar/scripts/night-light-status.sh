#!/usr/bin/env bash
set -euo pipefail
exec "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/night_light.sh" status
