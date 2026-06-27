#!/usr/bin/env bash
set -euo pipefail

if ! command -v hyprsunset >/dev/null 2>&1; then
    exit 0
fi

if systemctl --user list-unit-files hyprsunset.service >/dev/null 2>&1; then
    systemctl --user start hyprsunset.service >/dev/null 2>&1 || true
    exit 0
fi

exec hyprsunset
