#!/usr/bin/env bash

# Path to a small state file
STATE_FILE="$HOME/.cache/dnd_state"

# Initialize if missing
[ ! -f "$STATE_FILE" ] && echo "off" > "$STATE_FILE"

STATE=$(cat "$STATE_FILE")

if [[ "$1" == "toggle" ]]; then
    if [[ "$STATE" == "off" ]]; then
        makoctl mode -a do-not-disturb
        echo "on" > "$STATE_FILE"
    else
        makoctl mode -r do-not-disturb
        echo "off" > "$STATE_FILE"
    fi
fi

# Output the icon/text for Waybar
STATE=$(cat "$STATE_FILE")
if [[ "$STATE" == "on" ]]; then
    echo "󰂟 "  # MDI bell-off-outline
else
    echo "󰂞 "  # MDI bell-outline
fi
