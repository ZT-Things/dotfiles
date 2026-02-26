#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
LINES_FILE="$DIR/lines.txt"
ENGINE_FILE="$DIR/engine_mode"
TMP_WAV="/tmp/tts_output.wav"

# --- Default engine ---
[ -f "$ENGINE_FILE" ] || echo "fifo" > "$ENGINE_FILE"
ENGINE="$(cat "$ENGINE_FILE")"

# --- Sanity checks ---
[ -f "$LINES_FILE" ] || { echo "lines.txt not found"; exit 1; }

# --- Select line ---
CHOICE=$(
  {
    echo "Type custom text..."
    echo "Toggle engine (current: $ENGINE)"
    cut -d '=' -f1 "$LINES_FILE"
  } | wofi --dmenu \
           --prompt "Select line:" \
           --cache-file=/dev/null
)

[ -z "${CHOICE:-}" ] && exit 0

# --- Toggle engine ---
if [[ "$CHOICE" == Toggle\ engine* ]]; then
    if [ "$ENGINE" = "fifo" ]; then
        echo "espeak" > "$ENGINE_FILE"
    else
        echo "fifo" > "$ENGINE_FILE"
    fi
    exit 0
fi

# --- Resolve text ---
if [ "$CHOICE" = "Type custom text..." ]; then
    TEXT=$(wofi --dmenu \
                --prompt "Say:" \
                --cache-file=/dev/null)
else
    SAFE_CHOICE=$(printf '%s\n' "$CHOICE" | sed 's/[][\\.^$*]/\\&/g')
    LINE=$(grep "^$SAFE_CHOICE=" "$LINES_FILE" || true)
    TEXT=$(echo "$LINE" | sed -E 's/^[^=]+="(.*)"$/\1/')
fi

[ -z "${TEXT:-}" ] && exit 0

# --- Stop previous playback ---
pkill -f "pw-play --target tts_sink" 2>/dev/null || true

# --- Speak ---
ENGINE="$(cat "$ENGINE_FILE")"

if [ "$ENGINE" = "fifo" ]; then
    # Piper via FIFO
    echo "$TEXT" > /tmp/piper_fifo
else
    # eSpeak direct
    espeak "$TEXT" --stdout | pw-play --target tts_sink -
fi

# --- Optional cleanup ---
rm -f "$TMP_WAV"
