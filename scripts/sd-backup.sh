#!/usr/bin/env bash
# sd-backup.sh — back up captures from a Flipper SD card to local backup tree
#
# Usage: ./scripts/sd-backup.sh [/Volumes/Flipper SD] [backup-dir]
#
# Default backup-dir: ~/flipperzero-sd-backup/$(date +%Y%m%d-%H%M%S)/
#
# Backs up only USER-GENERATED captures, NOT firmware-bundled databases.
# (i.e., your own .sub/.nfc/.rfid/.ibtn/.ir captures, not the IRDB/UberGuidoZ DBs).
#
# This output is NOT stored in the git repo by default — personal captures
# are credentials. See captures/README.md.

set -euo pipefail

SD="${1:-/Volumes/Flipper SD}"
DEST="${2:-$HOME/flipperzero-sd-backup/$(date +%Y%m%d-%H%M%S)}"

if [[ ! -d "$SD" ]]; then
  echo "error: SD card not mounted at: $SD" >&2
  exit 1
fi

mkdir -p "$DEST"
echo "Backing up $SD → $DEST"

# Capture-bearing folders, but skip bundled DBs
RSYNC_FLAGS=(-a --info=stats1 --exclude='._*' --exclude='.DS_Store'
             --exclude='IRDB/' --exclude='UberGuidoZ/'
             --exclude='bruteforce/' --exclude='intercom-keys/'
             --exclude='Starnew/' --exclude='assets/' --exclude='universal/')

for dir in subghz nfc lfrfid ibutton infrared badusb; do
  if [[ -d "$SD/$dir" ]]; then
    echo "  $dir/..."
    mkdir -p "$DEST/$dir"
    rsync "${RSYNC_FLAGS[@]}" "$SD/$dir/" "$DEST/$dir/" || true
  fi
done

# Always-backup: favorites and user config
[[ -f "$SD/favorites.txt" ]] && cp "$SD/favorites.txt" "$DEST/"

# Per-app data (small; keep)
if [[ -d "$SD/apps_data" ]]; then
  echo "  apps_data/..."
  rsync -a --exclude='._*' "$SD/apps_data/" "$DEST/apps_data/"
fi

echo
du -sh "$DEST"
echo "done"
