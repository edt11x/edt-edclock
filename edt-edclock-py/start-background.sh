#!/bin/bash
# Starts edt-edclock detached from the terminal.
# Safe to call from ~/.profile, ~/.xprofile, a .desktop autostart entry,
# or any login hook — the process survives after the calling shell exits.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV="$SCRIPT_DIR/venv"
LOGFILE="$SCRIPT_DIR/edclock.log"
PIDFILE="$SCRIPT_DIR/edclock.pid"

# ── Kill any existing instance ────────────────────────────────────────────────
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        kill "$OLD_PID"
        sleep 0.3
    fi
    rm -f "$PIDFILE"
fi

# ── Activate virtualenv ───────────────────────────────────────────────────────
if [ ! -d "$VENV" ]; then
    echo "$(date): venv not found — run setup-py.sh first." >> "$LOGFILE"
    exit 1
fi
source "$VENV/bin/activate"

# ── Launch detached (nohup + setsid keeps it alive after terminal closes) ─────
nohup setsid python "$SCRIPT_DIR/main.py" >> "$LOGFILE" 2>&1 &
echo $! > "$PIDFILE"
echo "$(date): started (PID $(cat "$PIDFILE"))" >> "$LOGFILE"
