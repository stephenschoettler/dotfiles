#!/usr/bin/env bash
# Backwards-compatible wrapper around screenshot.sh.
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec "$SCRIPT_DIR/screenshot.sh" output "${1:-focused}"
