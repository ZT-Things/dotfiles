#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
LINES_FILE="$DIR/lines.txt"
MODEL="$HOME/.local/share/piper/en_US-lessac-medium.onnx"
TMP_WAV="/tmp/tts_output.wav"

# --- Sanity checks ---
[ -f "$MODEL" ] || { echo "Model not found: $MODEL"; exit 1; }
[ -f "$LINES_FILE" ] || { echo "lines.txt not found"; exit 1; }

# --- Select line ---
CHOICE=$(
  {
    echo "Type custom text..."
    cut -d '=' -f1 "$LINES_FILE"
  } | wofi --dmenu \
           --prompt "Select line:" \
           --cache-file=/dev/null
)

[ -z "${CHOICE:-}" ] && exit 0

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

# --- Stop previous playback (optional cleanup) ---
pkill -f "pw-play --target tts_sink" 2>/dev/null || true

# --- Generate WAV with Piper ---
echo "$TEXT" | \
piper-tts \
  -m "$MODEL" \
  --volume 2.5 \
  -f "$TMP_WAV"

# --- Play into virtual sink ---
pw-play --target tts_sink "$TMP_WAV"

# --- Optional cleanup ---
rm -f "$TMP_WAV"
