#!/usr/bin/env python3

import html
import json
import os
import subprocess
import sys
from typing import Any

HERDR_BIN = os.environ.get("HERDR_BIN", "herdr")
STATE_PRIORITY = {
    "blocked": 0,
    "unknown": 1,
    "unavailable": 1,
    "error": 1,
    "working": 2,
    "idle": 3,
    "done": 3,
}


def waybar_payload(text: str, tooltip: str, css_class: str) -> dict[str, str]:
    return {"text": text, "tooltip": tooltip, "class": css_class}


def unavailable_payload() -> dict[str, str]:
    return waybar_payload("󰅙", "Herdr unavailable", "unavailable")


def load_agents() -> list[dict[str, Any]]:
    result = subprocess.run(
        [HERDR_BIN, "agent", "list"],
        check=True,
        capture_output=True,
        text=True,
        timeout=3,
    )
    payload = json.loads(result.stdout)
    agents = payload.get("result", {}).get("agents")
    if not isinstance(agents, list):
        raise ValueError("Herdr response has no agent list")
    return [agent for agent in agents if isinstance(agent, dict)]


def display_name(agent: dict[str, Any], index: int) -> str:
    name = agent.get("name") or agent.get("agent") or "agent"
    pane_id = agent.get("pane_id")
    label = f"{name} ({pane_id})" if pane_id else f"{name} {index}"
    return html.escape(str(label))


def aggregate(agents: list[dict[str, Any]]) -> dict[str, str]:
    if not agents:
        return waybar_payload("󰒲 0", "No Herdr agents detected", "idle")

    statuses = [str(agent.get("agent_status", "unknown")).lower() for agent in agents]
    overall = min(statuses, key=lambda status: STATE_PRIORITY.get(status, 1))
    tooltip_lines = ["Herdr agents"]
    for index, (agent, status) in enumerate(zip(agents, statuses, strict=True), start=1):
        tooltip_lines.append(f"{display_name(agent, index)}: {html.escape(status)}")

    total = len(agents)
    if overall == "blocked":
        blocked = statuses.count("blocked")
        return waybar_payload(f"󰀪 {blocked}/{total}", "\n".join(tooltip_lines), "blocked")
    if overall in {"unknown", "unavailable", "error"} or overall not in STATE_PRIORITY:
        degraded = sum(
            status in {"unknown", "unavailable", "error"} or status not in STATE_PRIORITY
            for status in statuses
        )
        return waybar_payload(f"󰅙 {degraded}/{total}", "\n".join(tooltip_lines), "unavailable")
    if overall == "working":
        working = statuses.count("working")
        return waybar_payload(f"󰐊 {working}/{total}", "\n".join(tooltip_lines), "working")
    return waybar_payload(f"󰒲 {total}", "\n".join(tooltip_lines), "idle")


def main() -> int:
    try:
        payload = aggregate(load_agents())
    except (FileNotFoundError, json.JSONDecodeError, subprocess.SubprocessError, ValueError):
        payload = unavailable_payload()

    json.dump(payload, sys.stdout, ensure_ascii=False)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
