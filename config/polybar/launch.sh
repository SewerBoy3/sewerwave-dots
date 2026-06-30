#!/usr/bin/env bash
# Launch polybar on all connected monitors

set -euo pipefail

CONFIG="${HOME}/.config/polybar/config.ini"
POLYBAR_BIN="$(command -v polybar)"

killall -q polybar 2>/dev/null || true

if ! mapfile -t monitors < <(polybar --list-monitors 2>/dev/null | cut -d: -f1); then
    monitors=("")
fi

if ((${#monitors[@]} == 0)); then
    monitors=("")
fi

for mon in "${monitors[@]}"; do
    MONITOR=$mon "$POLYBAR_BIN" --config="$CONFIG" sewerwave 2>/dev/null &
done

wait
