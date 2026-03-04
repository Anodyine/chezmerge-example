#!/bin/bash
set -e

# Update these variables if your repo path changes
BASE_URL="https://raw.githubusercontent.com/Anodyine/chezmoi-merge-assistant-example/refs/heads/main"
CONFIG_FILE="archinstall-config.json"
FIX_SCRIPT="fix-btrfs-layout.sh"

echo ">> [1/3] Downloading Configuration..."
curl -L -o "$CONFIG_FILE" "$BASE_URL/$CONFIG_FILE"

echo ">> [2/3] Downloading Fix Script..."
curl -L -o "$FIX_SCRIPT" "$BASE_URL/$FIX_SCRIPT"
chmod +x "$FIX_SCRIPT"

echo ">> [3/3] Ready!"
echo "--------------------------------------------------------"
echo "1. Ensure you updated '$FIX_SCRIPT' on GitHub with the NO-SUDO version."
echo "2. Start install with:"
echo "   archinstall --config $CONFIG_FILE"
echo "--------------------------------------------------------"