#!/usr/bin/env bash
#    ___           __
#   / _ \___  ____/ /__
#  / // / _ \/ __/  '_/
# /____/\___/\__/_/\_\
#

DOCK_THEME="modern"
if [ -f "$HOME/.config/ml4w/settings/dock-theme" ]; then
    DOCK_THEME=$(cat "$HOME/.config/ml4w/settings/dock-theme")
fi

echo ":: Using Dock Theme $DOCK_THEME"

if [ ! -f "$HOME/.config/ml4w/settings/dock-disabled" ]; then
    killall nwg-dock-hyprland
    sleep 0.5

    monitor_names=$(hyprctl -j monitors | jq -r '.[] | select(.disabled != true) | .name')
    if [ -z "$monitor_names" ]; then
        echo ":: No active monitors found for dock"
        exit 0
    fi

    for monitor in $monitor_names; do
        echo ":: Launching dock on $monitor"
        if [ -f "$HOME/.config/ml4w/settings/dock-autohide" ]; then
            nwg-dock-hyprland -m -o "$monitor" -p left -d -i 26 -w 5 -ml 10 -x -s "themes/$DOCK_THEME/style.css" -c "$HOME/.config/hypr/scripts/launcher.sh" &
        else
            nwg-dock-hyprland -m -o "$monitor" -p left -i 26 -w 5 -ml 10 -x -s "themes/$DOCK_THEME/style.css" -c "$HOME/.config/hypr/scripts/launcher.sh" &
        fi
    done
else
    killall nwg-dock-hyprland
    echo ":: Dock disabled"
fi
