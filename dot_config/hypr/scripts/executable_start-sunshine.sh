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
systemctl --user reset-failed sunshine.service
systemctl --user restart sunshine.service
