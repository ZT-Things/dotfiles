#!/bin/bash
FOCUSED_PID=$(hyprctl activewindow -j | jq -r '.pid')

# Find the shell among all children (zsh/bash/fish)
SHELL_PID=$(pgrep -P "$FOCUSED_PID" -a | grep -E 'zsh|bash|fish' | awk '{print $1}')

# Fall back to focused PID if not found
TARGET_PID="${SHELL_PID:-$FOCUSED_PID}"
CWD=$(readlink -f /proc/$TARGET_PID/cwd 2>/dev/null || echo "$HOME")

thunar "$CWD" &
