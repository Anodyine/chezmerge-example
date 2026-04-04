#!/usr/bin/env bash
#    ___           __
#   / _ \___  ____/ /__
#  / // / _ \/ __/  '_/
# /____/\___/\__/_/\_\
#

set -euo pipefail

LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/nwg-dock-hyprland-launch.lock"
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

DOCK_THEME="modern"
if [ -f "$HOME/.config/ml4w/settings/dock-theme" ]; then
    DOCK_THEME=$(cat "$HOME/.config/ml4w/settings/dock-theme")
fi

echo ":: Using Dock Theme $DOCK_THEME"

if [ ! -f "$HOME/.config/ml4w/settings/dock-disabled" ]; then
    killall nwg-dock-hyprland 2>/dev/null || true

    for _ in {1..20}; do
        if ! pgrep -x nwg-dock-hyprland >/dev/null 2>&1; then
            break
        fi
        sleep 0.1
    done

    mapfile -t monitor_names < <(hyprctl -j monitors | jq -r '.[] | select(.disabled != true) | .name' | awk '!seen[$0]++')
    if [ "${#monitor_names[@]}" -eq 0 ]; then
        echo ":: No active monitors found for dock"
        exit 0
    fi

    dock_args=(-m -p left -i 30 -w 5 -ml 6 -x -s "themes/$DOCK_THEME/style.css" -c "$HOME/.config/hypr/scripts/launcher.sh")
    if [ -f "$HOME/.config/ml4w/settings/dock-autohide" ]; then
        dock_args=(-d "${dock_args[@]}")
    fi

    for monitor in "${monitor_names[@]}"; do
        echo ":: Launching dock on $monitor"
        nwg-dock-hyprland "${dock_args[@]}" -o "$monitor" &
    done
else
    killall nwg-dock-hyprland 2>/dev/null || true
    echo ":: Dock disabled"
fi
