#!/usr/bin/env bash

set -eu

if pgrep -x hyprlock >/dev/null 2>&1; then
    exit 0
fi

systemctl --user start hyprlock.service

# Give the compositor a moment to hand session locking over to hyprlock
# before suspend continues.
for _ in $(seq 1 50); do
    if pgrep -x hyprlock >/dev/null 2>&1; then
        exit 0
    fi
    sleep 0.1
done

echo "hyprlock did not start in time" >&2
exit 1
