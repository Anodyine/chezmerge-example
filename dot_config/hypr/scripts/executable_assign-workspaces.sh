#!/usr/bin/env bash

set -eu

get_monitor_by_desc() {
    pattern=$1
    printf '%s\n' "$MONITORS_JSON" | jq -r --arg pattern "$pattern" '
        .[]
        | select(.description | test($pattern))
        | .name
    ' | head -n1
}

get_monitor_by_name() {
    monitor_name=$1
    printf '%s\n' "$MONITORS_JSON" | jq -r --arg monitor_name "$monitor_name" '
        .[]
        | select(.name == $monitor_name)
        | .name
    ' | head -n1
}

apply_workspace_rule() {
    workspace_id=$1
    monitor_name=$2
    is_default=$3

    rule="$workspace_id, monitor:$monitor_name, persistent:true"
    if [ "$is_default" = "true" ]; then
        rule="$rule, default:true"
    fi

    hyprctl keyword workspace "$rule" >/dev/null
}

for _ in $(seq 1 20); do
    if MONITORS_JSON=$(hyprctl monitors -j 2>/dev/null); then
        break
    fi
    sleep 0.5
done

if [ -z "${MONITORS_JSON:-}" ]; then
    exit 0
fi

monitor_count=$(printf '%s\n' "$MONITORS_JSON" | jq 'length')
machine_name=$(uname -n)

# Keep the Surface's built-in panel on odd workspaces when the iPad display
# is the only external monitor attached. All other monitor combinations fall
# back to the existing description-based mapping below.
if [ "$machine_name" = "arch-surface" ] && [ "$monitor_count" -eq 2 ]; then
    builtin_monitor=$(get_monitor_by_name 'eDP-1')
    ipad_monitor=$(get_monitor_by_desc 'LG Display')

    if [ -n "$builtin_monitor" ] && [ -n "$ipad_monitor" ]; then
        apply_workspace_rule 1 "$builtin_monitor" true
        apply_workspace_rule 3 "$builtin_monitor" false
        apply_workspace_rule 5 "$builtin_monitor" false
        apply_workspace_rule 7 "$builtin_monitor" false
        apply_workspace_rule 9 "$builtin_monitor" false

        apply_workspace_rule 2 "$ipad_monitor" true
        apply_workspace_rule 4 "$ipad_monitor" false
        apply_workspace_rule 6 "$ipad_monitor" false
        apply_workspace_rule 8 "$ipad_monitor" false
        apply_workspace_rule 10 "$ipad_monitor" false
        exit 0
    fi
fi

even_monitor=$(get_monitor_by_desc 'GN10|Odyssey G95C|YMK EM160')
odd_monitor=$(get_monitor_by_desc '27E3QK|LG ULTRAGEAR|LG Display')

if [ -n "$even_monitor" ]; then
    apply_workspace_rule 2 "$even_monitor" true
    apply_workspace_rule 4 "$even_monitor" false
    apply_workspace_rule 6 "$even_monitor" false
    apply_workspace_rule 8 "$even_monitor" false
    apply_workspace_rule 10 "$even_monitor" false
fi

if [ -n "$odd_monitor" ]; then
    apply_workspace_rule 3 "$odd_monitor" true
    apply_workspace_rule 5 "$odd_monitor" false
    apply_workspace_rule 7 "$odd_monitor" false
    apply_workspace_rule 9 "$odd_monitor" false
fi
