#!/usr/bin/python
# pyright: reportMissingImports=false
"""Persistent Hypridle inhibitor controlled by SwayNC."""

from __future__ import annotations

import fcntl
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
from typing import Any

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

RUNTIME_DIR = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp"))
STATE_PATH = RUNTIME_DIR / "swaync-keep-awake.json"
LOCK_PATH = RUNTIME_DIR / "swaync-keep-awake.lock"
LOG_PATH = RUNTIME_DIR / "swaync-keep-awake.log"
SCRIPT_PATH = Path(__file__).resolve()
APP_NAME = "SwayNC Keep Awake"
REASON = "Keep Awake control is enabled"


def screen_saver_owner(connection: Gio.DBusConnection) -> str:
    reply = connection.call_sync(
        "org.freedesktop.DBus",
        "/org/freedesktop/DBus",
        "org.freedesktop.DBus",
        "GetNameOwner",
        GLib.Variant("(s)", ("org.freedesktop.ScreenSaver",)),
        GLib.VariantType.new("(s)"),
        Gio.DBusCallFlags.NONE,
        -1,
        None,
    )
    return str(reply.unpack()[0])


def process_start_ticks(pid: int) -> int | None:
    try:
        fields = Path(f"/proc/{pid}/stat").read_text().split()
        return int(fields[21])
    except (FileNotFoundError, IndexError, OSError, ValueError):
        return None


def read_state() -> dict[str, Any] | None:
    try:
        state = json.loads(STATE_PATH.read_text())
        pid = int(state["pid"])
        start_ticks = int(state["start_ticks"])
        command = Path(f"/proc/{pid}/cmdline").read_bytes().split(b"\0")
    except (FileNotFoundError, KeyError, OSError, ValueError, json.JSONDecodeError):
        return None

    if process_start_ticks(pid) != start_ticks:
        return None
    if str(SCRIPT_PATH).encode() not in command or b"_daemon" not in command:
        return None
    try:
        connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
        if screen_saver_owner(connection) != state["service_owner"]:
            return None
    except (GLib.Error, KeyError):
        return None
    return state


def is_active() -> bool:
    return read_state() is not None


def remove_stale_state() -> None:
    if is_active():
        return
    try:
        STATE_PATH.unlink()
    except FileNotFoundError:
        pass


def start() -> None:
    if is_active():
        return
    remove_stale_state()
    with LOG_PATH.open("ab", buffering=0) as log:
        subprocess.Popen(
            [sys.executable, str(SCRIPT_PATH), "_daemon"],
            stdin=subprocess.DEVNULL,
            stdout=log,
            stderr=log,
            start_new_session=True,
            close_fds=True,
        )
    for _ in range(30):
        if is_active():
            return
        time.sleep(0.1)
    raise RuntimeError(f"Keep Awake failed to start; see {LOG_PATH}")


def stop() -> None:
    state = read_state()
    if state is None:
        remove_stale_state()
        return
    pid = int(state["pid"])
    os.kill(pid, signal.SIGTERM)
    for _ in range(30):
        if not is_active():
            remove_stale_state()
            return
        time.sleep(0.1)
    raise RuntimeError(f"Keep Awake process {pid} did not stop")


def write_state(pid: int, cookie: int, service_owner: str) -> None:
    payload = {
        "pid": pid,
        "start_ticks": process_start_ticks(pid),
        "cookie": cookie,
        "service_owner": service_owner,
    }
    temporary = STATE_PATH.with_suffix(".tmp")
    temporary.write_text(json.dumps(payload, sort_keys=True) + "\n")
    os.replace(temporary, STATE_PATH)


def run_daemon() -> None:
    LOCK_PATH.parent.mkdir(parents=True, exist_ok=True)
    with LOCK_PATH.open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return

        connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
        reply = connection.call_sync(
            "org.freedesktop.ScreenSaver",
            "/org/freedesktop/ScreenSaver",
            "org.freedesktop.ScreenSaver",
            "Inhibit",
            GLib.Variant("(ss)", (APP_NAME, REASON)),
            GLib.VariantType.new("(u)"),
            Gio.DBusCallFlags.NONE,
            -1,
            None,
        )
        cookie = int(reply.unpack()[0])
        service_owner = screen_saver_owner(connection)
        pid = os.getpid()
        write_state(pid, cookie, service_owner)

        loop = GLib.MainLoop()

        def service_owner_changed(
            _connection: Gio.DBusConnection,
            _sender: str,
            _path: str,
            _interface: str,
            _signal: str,
            parameters: GLib.Variant,
            _user_data: object,
        ) -> None:
            _name, _old_owner, new_owner = parameters.unpack()
            if new_owner != service_owner:
                loop.quit()

        connection.signal_subscribe(
            "org.freedesktop.DBus",
            "org.freedesktop.DBus",
            "NameOwnerChanged",
            "/org/freedesktop/DBus",
            "org.freedesktop.ScreenSaver",
            Gio.DBusSignalFlags.NONE,
            service_owner_changed,
            None,
        )
        connection.connect("closed", lambda *_args: loop.quit())

        def request_stop(_signum: int, _frame: object) -> None:
            loop.quit()

        signal.signal(signal.SIGTERM, request_stop)
        signal.signal(signal.SIGINT, request_stop)
        try:
            loop.run()
        finally:
            try:
                connection.call_sync(
                    "org.freedesktop.ScreenSaver",
                    "/org/freedesktop/ScreenSaver",
                    "org.freedesktop.ScreenSaver",
                    "UnInhibit",
                    GLib.Variant("(u)", (cookie,)),
                    None,
                    Gio.DBusCallFlags.NONE,
                    -1,
                    None,
                )
            finally:
                try:
                    STATE_PATH.unlink()
                except FileNotFoundError:
                    pass


def main() -> int:
    action = sys.argv[1] if len(sys.argv) > 1 else "status"
    if action == "status":
        print("true" if is_active() else "false")
    elif action == "on":
        start()
    elif action == "off":
        stop()
    elif action == "toggle":
        stop() if is_active() else start()
    elif action == "set" and len(sys.argv) == 3 and sys.argv[2] in {"true", "false"}:
        start() if sys.argv[2] == "true" else stop()
    elif action == "_daemon":
        run_daemon()
    else:
        print(f"Usage: {Path(sys.argv[0]).name} [status|on|off|toggle|set true|set false]", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (GLib.Error, OSError, RuntimeError) as error:
        print(f"keep-awake: {error}", file=sys.stderr)
        raise SystemExit(1)
