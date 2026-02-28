#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
LINES_FILE="$DIR/lines.txt"
ENGINE_FILE="$DIR/engine_mode"
REPLACEMENT_FILE="$DIR/replacement.txt"
TMP_WAV="/tmp/tts_output.wav"

# --- Default engine ---
[ -f "$ENGINE_FILE" ] || echo "fifo" > "$ENGINE_FILE"
ENGINE="$(cat "$ENGINE_FILE")"

# --- Ensure files exist ---
[ -f "$LINES_FILE" ] || { echo "lines.txt not found"; exit 1; }
[ -f "$REPLACEMENT_FILE" ] || touch "$REPLACEMENT_FILE"

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

# --- Apply whole-word replacements safely ---
if [ -s "$REPLACEMENT_FILE" ]; then
    while IFS='=' read -r KEY VALUE; do
        [ -z "${KEY:-}" ] && continue

        # Strip surrounding quotes from VALUE
        VALUE="${VALUE%\"}"
        VALUE="${VALUE#\"}"

        # Escape sed special chars in KEY and VALUE
        ESC_KEY=$(printf '%s\n' "$KEY" | sed 's/[.[\*^$()+?{|\\]/\\&/g')
        ESC_VALUE=$(printf '%s\n' "$VALUE" | sed 's/[&/\]/\\&/g')

        # Replace whole words only
        TEXT=$(printf '%s\n' "$TEXT" | \
               sed -E "s/(^|[^[:alnum:]_])${ESC_KEY}([^[:alnum:]_]|$)/\1${ESC_VALUE}\2/g")

    done < "$REPLACEMENT_FILE"
fi

# --- Stop previous playback ---
pkill -f "pw-play --target tts_sink" 2>/dev/null || true

# --- Speak ---
ENGINE="$(cat "$ENGINE_FILE")"

if [ "$ENGINE" = "fifo" ]; then
    # Piper via FIFO
    echo "$TEXT" > /tmp/piper_fifo
else
    # eSpeak direct
    espeak -a 200 "$TEXT" --stdout | pw-play --target tts_sink -
fi

# --- Optional cleanup ---
rm -f "$TMP_WAV"
