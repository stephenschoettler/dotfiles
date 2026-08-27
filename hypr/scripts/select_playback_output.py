#!/usr/bin/env python3
"""Pick a PipeWire playback sink and move current playback streams to it."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from dataclasses import dataclass
from typing import Any

PACTL = os.environ.get("PACTL_BIN", "pactl")
FUZZEL = os.environ.get("FUZZEL_BIN", "fuzzel")


class OutputPickerError(RuntimeError):
    """A user-facing output picker failure."""


@dataclass(frozen=True)
class Sink:
    name: str
    description: str
    state: str


def run_command(command: list[str], *, input_text: str | None = None) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            command,
            input=input_text,
            text=True,
            capture_output=True,
            check=False,
        )
    except OSError as error:
        raise OutputPickerError(f"Could not run {command[0]}: {error}") from error


def pactl_json(*arguments: str) -> Any:
    result = run_command([PACTL, "--format=json", *arguments])
    if result.returncode != 0:
        detail = result.stderr.strip() or f"exit status {result.returncode}"
        raise OutputPickerError(f"pactl {' '.join(arguments)} failed: {detail}")
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise OutputPickerError(f"pactl {' '.join(arguments)} returned invalid JSON") from error


def default_sink_name() -> str:
    result = run_command([PACTL, "get-default-sink"])
    if result.returncode != 0:
        detail = result.stderr.strip() or f"exit status {result.returncode}"
        raise OutputPickerError(f"pactl get-default-sink failed: {detail}")
    return result.stdout.strip()


def clean_label(value: str) -> str:
    return " ".join(value.split())


def list_sinks() -> list[Sink]:
    records = pactl_json("list", "sinks")
    if not isinstance(records, list):
        raise OutputPickerError("pactl list sinks returned an unexpected record type")

    sinks: list[Sink] = []
    for record in records:
        if not isinstance(record, dict) or not isinstance(record.get("name"), str):
            continue
        name = record["name"]
        properties = record.get("properties")
        if not isinstance(properties, dict):
            properties = {}
        description = record.get("description") or properties.get("device.description") or name
        state = record.get("state") or "UNKNOWN"
        sinks.append(
            Sink(
                name=name,
                description=clean_label(str(description)) or name,
                state=str(state),
            )
        )
    return sinks


def choose_sink(sinks: list[Sink], current: str) -> Sink | None:
    ordered = sorted(sinks, key=lambda sink: (sink.name != current, sink.description.casefold(), sink.name))
    rows = [f"{'●' if sink.name == current else '○'} {sink.description}" for sink in ordered]
    result = run_command(
        [
            FUZZEL,
            "--dmenu",
            "--index",
            "--only-match",
            "--no-exit-on-keyboard-focus-loss",
            "--no-icons",
            "--minimal-lines",
            f"--lines={min(len(rows), 6)}",
            "--width=70",
            "--prompt=Output: ",
        ],
        input_text="\n".join(rows) + "\n",
    )
    selection = result.stdout.strip()
    if result.returncode != 0 or not selection:
        return None
    try:
        index = int(selection)
        return ordered[index]
    except (ValueError, IndexError) as error:
        raise OutputPickerError("fuzzel returned an invalid sink selection") from error


def select_named_sink(sinks: list[Sink], name: str) -> Sink:
    for sink in sinks:
        if sink.name == name:
            return sink
    raise OutputPickerError(f"Unknown playback sink: {name}")


def require_success(command: list[str]) -> None:
    result = run_command(command)
    if result.returncode != 0:
        detail = result.stderr.strip() or f"exit status {result.returncode}"
        raise OutputPickerError(f"{' '.join(command[:2])} failed: {detail}")


def switch_to_sink(sink: Sink) -> None:
    require_success([PACTL, "set-default-sink", sink.name])

    records = pactl_json("list", "sink-inputs")
    if not isinstance(records, list):
        raise OutputPickerError("pactl list sink-inputs returned an unexpected record type")

    failures: list[str] = []
    for record in records:
        if not isinstance(record, dict) or "index" not in record:
            continue
        stream_id = str(record["index"])
        result = run_command([PACTL, "move-sink-input", stream_id, sink.name])
        if result.returncode != 0:
            detail = result.stderr.strip() or f"exit status {result.returncode}"
            failures.append(f"stream {stream_id}: {detail}")
    if failures:
        raise OutputPickerError("Some playback streams could not be moved: " + "; ".join(failures))


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--list", action="store_true", help="print live sink records as JSON")
    mode.add_argument("--select", metavar="SINK_NAME", help="select a sink without opening fuzzel")
    return parser.parse_args()


def main() -> int:
    arguments = parse_arguments()
    try:
        sinks = list_sinks()
        current = default_sink_name()

        if arguments.list:
            print(
                json.dumps(
                    [
                        {
                            "name": sink.name,
                            "description": sink.description,
                            "state": sink.state,
                            "default": sink.name == current,
                        }
                        for sink in sinks
                    ],
                    indent=2,
                )
            )
            return 0

        if not sinks:
            raise OutputPickerError("No playback sinks are available")
        sink = select_named_sink(sinks, arguments.select) if arguments.select else choose_sink(sinks, current)
        if sink is None:
            return 0
        switch_to_sink(sink)
        return 0
    except OutputPickerError as error:
        print(f"output picker: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
