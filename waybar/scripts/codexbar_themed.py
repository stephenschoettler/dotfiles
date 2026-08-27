#!/usr/bin/env python3
"""Run Codexbar with the active Waybar palette applied to all Pango colors."""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Mapping, Sequence

WAYBAR_DIR = Path(__file__).resolve().parents[1]
DEFAULT_COLORS_PATH = WAYBAR_DIR / "colors.css"
DEFAULT_CODEXBAR_PATH = Path.home() / ".local" / "bin" / "codexbar"

# Codexbar only exposes CLI overrides for severity colors. Its remaining framed
# tooltip roles use these One Dark defaults when Omarchy is absent, so translate
# those exact output colors after Codexbar has fetched and rendered real data.
UPSTREAM_ROLE_COLORS = {
    "accent": "#61afef",
    "foreground": "#abb2bf",
    "dim": "#5c6370",
    "empty": "#3e4451",
    "low": "#98c379",
    "mid": "#e5c07b",
    "high": "#d19a66",
    "critical": "#e06c75",
}

WAYBAR_ROLE_TOKENS = {
    "accent": "purple",
    "foreground": "foreground",
    "dim": "comment",
    "empty": "current-line",
    "low": "green",
    "mid": "yellow",
    "high": "orange",
    "critical": "red",
}

CSS_HEX_COLOR = re.compile(
    r"^\s*@define-color\s+([a-zA-Z0-9_-]+)\s+(#[0-9a-fA-F]{6})\s*;\s*$",
    re.MULTILINE,
)
UPSTREAM_COLOR_PATTERN = re.compile(
    "|".join(re.escape(color) for color in UPSTREAM_ROLE_COLORS.values()),
    re.IGNORECASE,
)


def load_palette(colors_path: Path) -> dict[str, str]:
    """Load the simple hexadecimal tokens needed by the Codexbar card."""
    css = colors_path.read_text(encoding="utf-8")
    tokens = {name: value.lower() for name, value in CSS_HEX_COLOR.findall(css)}
    missing = sorted(set(WAYBAR_ROLE_TOKENS.values()) - tokens.keys())
    if missing:
        raise ValueError(
            f"{colors_path} is missing hexadecimal Waybar token(s): {', '.join(missing)}"
        )
    return {role: tokens[token] for role, token in WAYBAR_ROLE_TOKENS.items()}


def recolor_pango(markup: str, palette: Mapping[str, str]) -> str:
    """Replace all known upstream role colors in one non-cascading pass."""
    replacements = {
        source.lower(): palette[role]
        for role, source in UPSTREAM_ROLE_COLORS.items()
    }
    return UPSTREAM_COLOR_PATTERN.sub(
        lambda match: replacements[match.group(0).lower()], markup
    )


def themed_arguments(arguments: Sequence[str], palette: Mapping[str, str]) -> list[str]:
    """Append severity overrides so the active theme wins over caller defaults."""
    return [
        *arguments,
        "--color-low",
        palette["low"],
        "--color-mid",
        palette["mid"],
        "--color-high",
        palette["high"],
        "--color-critical",
        palette["critical"],
    ]


def run(
    arguments: Sequence[str],
    *,
    colors_path: Path = DEFAULT_COLORS_PATH,
    codexbar_path: Path = DEFAULT_CODEXBAR_PATH,
) -> subprocess.CompletedProcess[str]:
    """Execute upstream once, preserving its data path and adapting valid JSON output."""
    palette = load_palette(colors_path)
    command = [str(codexbar_path), *themed_arguments(arguments, palette)]
    completed = subprocess.run(command, text=True, stdout=subprocess.PIPE, check=False)

    try:
        payload = json.loads(completed.stdout)
    except (json.JSONDecodeError, TypeError):
        return completed
    if not isinstance(payload, dict):
        return completed

    for field in ("text", "tooltip"):
        value = payload.get(field)
        if isinstance(value, str):
            payload[field] = recolor_pango(value, palette)

    output = json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n"
    return subprocess.CompletedProcess(
        command,
        completed.returncode,
        stdout=output,
        stderr=completed.stderr,
    )


def error_payload(message: str) -> str:
    return json.dumps(
        {
            "text": "⚠",
            "tooltip": f"Codexbar theme adapter: {message}",
            "class": "critical",
        },
        ensure_ascii=False,
        separators=(",", ":"),
    ) + "\n"


def main(arguments: Sequence[str]) -> int:
    try:
        completed = run(arguments)
    except (OSError, ValueError) as exc:
        sys.stdout.write(error_payload(str(exc)))
        return 0
    sys.stdout.write(completed.stdout)
    return completed.returncode


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
