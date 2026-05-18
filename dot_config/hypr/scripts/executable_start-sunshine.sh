#!/usr/bin/env bash

# Wait until the current Wayland socket exists, but do not block forever.
wayland_socket="${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}"
for _ in $(seq 1 50); do
    if [ -n "${WAYLAND_DISPLAY}" ] && [ -S "${wayland_socket}" ]; then
        break
    fi
    sleep 0.2
done

# Sunshine often exits on logout with a broken Wayland pipe. Clear any
# start-limit state before retrying on the next login.
sunshine_units=(
    app-dev.lizardbyte.app.Sunshine.service
    sunshine.service
)

unit_exists() {
    systemctl --user list-unit-files "$1" --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "$1"
}

for unit in "${sunshine_units[@]}"; do
    if unit_exists "$unit"; then
        systemctl --user reset-failed "$unit"
        systemctl --user restart "$unit"
        exit $?
    fi
done

echo "No Sunshine user service found; skipping restart." >&2
