#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import json
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / "codexbar_themed.py"
SPEC = importlib.util.spec_from_file_location("codexbar_themed", SCRIPT)
assert SPEC and SPEC.loader
codexbar_themed = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(codexbar_themed)


class CodexbarThemedTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tempdir.cleanup)
        self.colors_path = Path(self.tempdir.name) / "colors.css"
        self.colors_path.write_text(
            """/* Active theme: test */
@define-color foreground #f8f8f2;
@define-color comment #6272a4;
@define-color current-line #44475a;
@define-color green #50fa7b;
@define-color yellow #f1fa8c;
@define-color orange #ffb86c;
@define-color red #ff5555;
@define-color purple #bd93f9;
""",
            encoding="utf-8",
        )

    def test_load_palette_maps_all_card_roles(self) -> None:
        palette = codexbar_themed.load_palette(self.colors_path)

        self.assertEqual(
            palette,
            {
                "accent": "#bd93f9",
                "foreground": "#f8f8f2",
                "dim": "#6272a4",
                "empty": "#44475a",
                "low": "#50fa7b",
                "mid": "#f1fa8c",
                "high": "#ffb86c",
                "critical": "#ff5555",
            },
        )

    def test_recolor_pango_replaces_every_upstream_role_simultaneously(self) -> None:
        palette = codexbar_themed.load_palette(self.colors_path)
        markup = " ".join(
            f"<span foreground='{color}'>{role}</span>"
            for role, color in codexbar_themed.UPSTREAM_ROLE_COLORS.items()
        )

        recolored = codexbar_themed.recolor_pango(markup, palette)

        for role, color in palette.items():
            self.assertIn(f"foreground='{color}'>{role}</span>", recolored)
        for color in codexbar_themed.UPSTREAM_ROLE_COLORS.values():
            self.assertNotIn(color, recolored)

    def test_run_preserves_arguments_and_recolors_valid_waybar_json(self) -> None:
        upstream = {
            "text": "<span foreground='#50fa7b'>󰚩 96%</span>",
            "tooltip": (
                "<span foreground='#61afef'>╭──╮</span>"
                "<span foreground='#abb2bf'>Weekly</span>"
                "<span foreground='#5c6370'>Resets</span>"
                "<span foreground='#3e4451'>░</span>"
                "<span foreground='#98c379'>█</span>"
            ),
            "class": "low",
        }
        completed = subprocess.CompletedProcess(
            args=[], returncode=0, stdout=json.dumps(upstream) + "\n"
        )

        with patch.object(codexbar_themed.subprocess, "run", return_value=completed) as run:
            result = codexbar_themed.run(
                ["--icon", "󰚩", "--frame", "--tooltip-pace-pts"],
                colors_path=self.colors_path,
                codexbar_path=Path("/mock/codexbar"),
            )

        command = run.call_args.args[0]
        self.assertEqual(
            command[:5],
            ["/mock/codexbar", "--icon", "󰚩", "--frame", "--tooltip-pace-pts"],
        )
        self.assertEqual(
            command[-8:],
            [
                "--color-low",
                "#50fa7b",
                "--color-mid",
                "#f1fa8c",
                "--color-high",
                "#ffb86c",
                "--color-critical",
                "#ff5555",
            ],
        )
        payload = json.loads(result.stdout)
        self.assertEqual(payload["text"], upstream["text"])
        self.assertIn("foreground='#bd93f9'>╭──╮", payload["tooltip"])
        self.assertIn("foreground='#f8f8f2'>Weekly", payload["tooltip"])
        self.assertIn("foreground='#6272a4'>Resets", payload["tooltip"])
        self.assertIn("foreground='#44475a'>░", payload["tooltip"])
        self.assertIn("foreground='#50fa7b'>█", payload["tooltip"])

    def test_invalid_upstream_json_is_returned_unchanged(self) -> None:
        completed = subprocess.CompletedProcess(args=[], returncode=0, stdout="not-json\n")
        with patch.object(codexbar_themed.subprocess, "run", return_value=completed):
            result = codexbar_themed.run(
                [], colors_path=self.colors_path, codexbar_path=Path("/mock/codexbar")
            )

        self.assertEqual(result.stdout, "not-json\n")
        self.assertEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
