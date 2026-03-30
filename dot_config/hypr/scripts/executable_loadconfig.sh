#!/usr/bin/env bash
hyprctl reload

if [ "$(uname -n)" = "arch-surface" ]; then
    ~/.config/hypr/scripts/assign-workspaces.sh
fi
