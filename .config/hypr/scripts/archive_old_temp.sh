#!/usr/bin/env bash
set -euo pipefail

DAYS=30

DIRS=(
  "$HOME/Pictures/temp"
  "$HOME/Documents/temp"
)

LOG_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/temp-archive.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

move_file() {
  local file="$1"
  local base_dir="$2"

  local year_month
  year_month=$(date -d @"$(stat -c %Y "$file")" '+%Y-%m')

  local archive_dir="$base_dir/Archive/$year_month"
  mkdir -p "$archive_dir"

  local filename
  filename=$(basename "$file")

  local target="$archive_dir/$filename"

  # Prevent overwrite collisions
  if [[ -e "$target" ]]; then
    local timestamp
    timestamp=$(date '+%H%M%S')
    target="$archive_dir/${filename%.*}_$timestamp.${filename##*.}"
  fi

  mv "$file" "$target"
  log "Moved: $file -> $target"
}

for dir in "${DIRS[@]}"; do
  if [[ ! -d "$dir" ]]; then
    log "Skipping missing dir: $dir"
    continue
  fi

  find "$dir" \
    -type f \
    -mtime +"$DAYS" \
    -print0 | while IFS= read -r -d '' file; do
      move_file "$file" "$dir"
    done
done

log "Archive run complete"
