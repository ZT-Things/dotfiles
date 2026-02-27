#!/usr/bin/env bash

FIFO="/tmp/piper_fifo"
MODEL="$HOME/.local/share/piper/en_US-lessac-medium.onnx"

rm -f "$FIFO"
mkfifo "$FIFO"

# Keep FIFO permanently open so Piper never sees EOF
tail -f /dev/null > "$FIFO" &
KEEPER_PID=$!

piper-tts \
  --model "$MODEL" \
  --cuda \
  --length_scale 1.35 \
  --output-raw < "$FIFO" | \
pw-cat \
  --playback \
  --raw \
  --format s16 \
  --rate 22050 \
  --channels 1 \
  --volume 1.7 \
  --target=tts_sink \
  -

kill $KEEPER_PID
