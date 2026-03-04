#!/usr/bin/env bash
#                _ _
# __      ____ _| | |_ __   __ _ _ __   ___ _ __
# \ \ /\ / / _` | | | '_ \ / _` | '_ \ / _ \ '__|
#  \ V  V / (_| | | | |_) | (_| | |_) |  __/ |
#   \_/\_/ \__,_|_|_| .__/ \__,_| .__/ \___|_|
#                   |_|         |_|
#
# -----------------------------------------------------
# Restore last wallpaper
# -----------------------------------------------------

# -----------------------------------------------------
# Set defaults
# -----------------------------------------------------

ml4w_cache_folder="$HOME/.cache/ml4w/hyprland-dotfiles"

defaultwallpaper="$HOME/.config/ml4w/wallpapers/default.jpg"
persistedwallpaper="$HOME/.config/ml4w/settings/current-wallpaper"

cachefile="$ml4w_cache_folder/current_wallpaper"

# -----------------------------------------------------
# Get current wallpaper
# -----------------------------------------------------

if [ -f "$persistedwallpaper" ]; then
    sed -i "s|~|$HOME|g" "$persistedwallpaper"
    wallpaper=$(cat "$persistedwallpaper")
    if [ -f "$wallpaper" ]; then
        echo ":: Persisted wallpaper $wallpaper exists"
    else
        echo ":: Persisted wallpaper $wallpaper does not exist. Checking cache/default."
        wallpaper=""
    fi
fi

if [ -z "$wallpaper" ] && [ -f "$cachefile" ]; then
    sed -i "s|~|$HOME|g" "$cachefile"
    wallpaper=$(cat "$cachefile")
    if [ -f "$wallpaper" ]; then
        echo ":: Cached wallpaper $wallpaper exists"
    else
        echo ":: Cached wallpaper $wallpaper does not exist. Using default."
        wallpaper="$defaultwallpaper"
    fi
else
    if [ -z "$wallpaper" ]; then
        echo ":: No persisted/cache wallpaper found. Using default wallpaper."
        wallpaper="$defaultwallpaper"
    fi
fi

# -----------------------------------------------------
# Set wallpaper
# -----------------------------------------------------

echo ":: Setting wallpaper with source image $wallpaper"
if [ -f ~/.local/bin/waypaper ]; then
    export PATH=$PATH:~/.local/bin/
fi
waypaper --wallpaper "$wallpaper"
