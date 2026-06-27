#!/usr/bin/env python3
"""Render Stephen's old Hyprlock ASCII clock as a PNG.

Hyprlock labels use Pango/font glyph rendering. The old clock used Unicode block
characters (`▄`, `▀`, `█`), which looked right stylistically but could show font
metric seams/gaps on the lock screen. This keeps the old 3-row ASCII glyph table
and draws each block cell directly into a transparent PNG, then prints the PNG
path for hyprlock's image reload_cmd.
"""

from __future__ import annotations

import os
from datetime import datetime
from pathlib import Path

from PIL import Image, ImageDraw

CACHE_DIR = Path(os.environ.get("HYPRLOCK_CLOCK_CACHE_DIR", "/home/w0lf/.cache/hyprlock"))
LEGACY_OUTPUT_PATH = Path(os.environ.get("HYPRLOCK_CLOCK_IMAGE", str(CACHE_DIR / "ascii-clock.png")))
COLOR = (80, 250, 123, 255)  # Dracula green

CELL_WIDTH = 14
CELL_HEIGHT = 24
PADDING_X = 10
PADDING_Y = 10
ROW_GAP = 0
CHAR_GAP = 1
AMPM_GAP = 12
AMPM_SCALE = 5

OLD_ASCII_GLYPHS = {
    "0": (" ▄██▄ ", "██  ██", " ▀██▀ "),
    "1": ("▄██", " ██", " ██"),
    "2": ("████▄", " ▄██▀", "███▄▄"),
    "3": ("████▄", " ▄▄██", "▄▄▄█▀"),
    "4": ("██  ██", "▀█████", "    ██"),
    "5": ("███▀▀▀", "▀▀███▄", "▄▄▄██▀"),
    "6": ("▄██▀▀▀", "██▄▄▄ ", "▀█▄▄█▀"),
    "7": ("██████", "  ▄██▀", " ██▀  "),
    "8": ("▄████▄", "██▄▄██", "▀█▄▄█▀"),
    "9": ("▄█▀▀█▄", " ▀▀▀██", " ▄▄██▀"),
    ":": (" ▄ ", "   ", " ▀ "),
}

LETTER_GLYPHS = {
    "A": ("0110", "1001", "1111", "1001", "1001"),
    "M": ("10001", "11011", "10101", "10001", "10001"),
    "P": ("1110", "1001", "1110", "1000", "1000"),
}


def build_ascii_rows(time_text: str) -> list[str]:
    rows = ["", "", ""]
    for char in time_text:
        glyph = OLD_ASCII_GLYPHS.get(char, ("  ", "  ", "  "))
        for row_index in range(3):
            rows[row_index] += glyph[row_index] + (" " * CHAR_GAP)
    return rows


def draw_cell(draw: ImageDraw.ImageDraw, char: str, x: int, y: int) -> None:
    # Coordinates are inclusive; use -1 so adjacent cells touch but do not overlap.
    if char == "█":
        draw.rectangle((x, y, x + CELL_WIDTH - 1, y + CELL_HEIGHT - 1), fill=COLOR)
    elif char == "▄":
        draw.rectangle((x, y + CELL_HEIGHT // 2, x + CELL_WIDTH - 1, y + CELL_HEIGHT - 1), fill=COLOR)
    elif char == "▀":
        draw.rectangle((x, y, x + CELL_WIDTH - 1, y + CELL_HEIGHT // 2 - 1), fill=COLOR)


def draw_ascii_rows(draw: ImageDraw.ImageDraw, rows: list[str]) -> int:
    for row_index, row in enumerate(rows):
        y = PADDING_Y + row_index * (CELL_HEIGHT + ROW_GAP)
        for column_index, char in enumerate(row):
            x = PADDING_X + column_index * CELL_WIDTH
            draw_cell(draw, char, x, y)
    return PADDING_X + max(len(row) for row in rows) * CELL_WIDTH


def letter_width(letter: str) -> int:
    return len(LETTER_GLYPHS[letter][0]) * AMPM_SCALE


def ampm_width(text: str) -> int:
    width = 0
    for letter in text:
        width += letter_width(letter) if letter in LETTER_GLYPHS else AMPM_SCALE * 2
        width += AMPM_SCALE
    return max(0, width - AMPM_SCALE)


def draw_bitmap_text(draw: ImageDraw.ImageDraw, text: str, x: int, y: int) -> None:
    cursor = x
    for letter in text:
        glyph = LETTER_GLYPHS.get(letter)
        if glyph is None:
            cursor += AMPM_SCALE * 2
            continue

        for row_index, row in enumerate(glyph):
            for column_index, pixel in enumerate(row):
                if pixel == "1":
                    px = cursor + column_index * AMPM_SCALE
                    py = y + row_index * AMPM_SCALE
                    draw.rectangle((px, py, px + AMPM_SCALE - 1, py + AMPM_SCALE - 1), fill=COLOR)

        cursor += letter_width(letter) + AMPM_SCALE


def clock_path(now: datetime) -> Path:
    # Hyprlock's image widget can keep showing a cached texture when reload_cmd
    # prints the same filename. Toggle between two minute slots so every minute
    # change also changes the path, while avoiding an unbounded cache directory.
    return CACHE_DIR / f"ascii-clock-{now.minute % 2}.png"


def save_png_atomic(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp_path = path.with_name(f".{path.name}.{os.getpid()}.tmp")
    image.save(tmp_path, format="PNG")
    tmp_path.replace(path)


def write_text_atomic(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp_path = path.with_name(f".{path.name}.{os.getpid()}.tmp")
    tmp_path.write_text(text)
    tmp_path.replace(path)


def current_time() -> datetime:
    if fake_now := os.environ.get("HYPRLOCK_CLOCK_NOW"):
        return datetime.fromisoformat(fake_now)
    return datetime.now()


def render(now: datetime) -> Path:
    output_path = clock_path(now)
    stamp_path = output_path.with_suffix(".stamp")
    stamp = now.strftime("%Y-%m-%d %H:%M %p")

    if (
        output_path.exists()
        and LEGACY_OUTPUT_PATH.exists()
        and stamp_path.exists()
        and stamp_path.read_text().strip() == stamp
    ):
        return output_path

    time_text = now.strftime("%I:%M")
    ampm_text = now.strftime("%p")
    rows = build_ascii_rows(time_text)

    clock_width = max(len(row) for row in rows) * CELL_WIDTH
    clock_height = len(rows) * CELL_HEIGHT + (len(rows) - 1) * ROW_GAP
    width = PADDING_X * 2 + clock_width + AMPM_GAP + ampm_width(ampm_text)
    height = PADDING_Y * 2 + clock_height

    image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    clock_right = draw_ascii_rows(draw, rows)

    ampm_height = len(LETTER_GLYPHS["P"]) * AMPM_SCALE
    ampm_x = clock_right + AMPM_GAP
    ampm_y = PADDING_Y + 2 * (CELL_HEIGHT + ROW_GAP) + (CELL_HEIGHT - ampm_height) // 2
    draw_bitmap_text(draw, ampm_text, ampm_x, ampm_y)

    save_png_atomic(image, output_path)
    save_png_atomic(image, LEGACY_OUTPUT_PATH)
    write_text_atomic(stamp_path, stamp)

    return output_path


if __name__ == "__main__":
    print(render(current_time()))
