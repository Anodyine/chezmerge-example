#!/usr/bin/env bash
hyprctl reload

if [ "$(uname -n)" = "arch-surface" ] || [ "$(uname -n)" = "arch-lenovo" ]; then
    ~/.config/hypr/scripts/assign-workspaces.sh
fi
