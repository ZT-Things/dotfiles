:#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
ENGINE_FILE="$DIR/engine_mode"
REPLACEMENT_FILE="$DIR/replacement.txt"

# --- Default engine ---
[ -f "$ENGINE_FILE" ] || echo "fifo" > "$ENGINE_FILE"

# --- Get custom text immediately ---
TEXT=$(rofi -dmenu -p "Say" \
     -theme-str '
        * {
            background: #1e1e1e;
            foreground: #ffffff;
        }
        window {
            background-color: @background;
            width: 400px;
        }
        textbox {
            background-color: #2a2a2a;
            text-color: @foreground;
        }
        listview {
            lines: 0;
        }
     ')

[ -z "${TEXT:-}" ] && exit 0

# --- Apply replacements ---
if [ -f "$REPLACEMENT_FILE" ] && [ -s "$REPLACEMENT_FILE" ]; then
    while IFS='=' read -r KEY VALUE; do
        [ -z "${KEY:-}" ] && continue

        VALUE="${VALUE%\"}"
        VALUE="${VALUE#\"}"

        ESC_KEY=$(printf '%s\n' "$KEY" | sed 's/[.[\*^$()+?{|\\]/\\&/g')
        ESC_VALUE=$(printf '%s\n' "$VALUE" | sed 's/[&/\]/\\&/g')

        TEXT=$(printf '%s\n' "$TEXT" | \
               sed -E "s/(^|[^[:alnum:]_])${ESC_KEY}([^[:alnum:]_]|$)/\1${ESC_VALUE}\2/g")

    done < "$REPLACEMENT_FILE"
fi

# --- Stop previous playback ---
pkill -f "pw-play --target tts_sink" 2>/dev/null || true

# --- Speak ---
ENGINE="$(cat "$ENGINE_FILE")"

if [ "$ENGINE" = "fifo" ]; then
    echo "$TEXT" > /tmp/piper_fifo
else
    espeak -a 200 "$TEXT" --stdout | pw-play --target tts_sink -
fi
