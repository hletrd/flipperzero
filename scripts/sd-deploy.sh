#!/usr/bin/env bash
# sd-deploy.sh — initialize a Flipper SD card from this repo's submodules
#
# Usage: ./scripts/sd-deploy.sh [/Volumes/Flipper SD]
#
# Performs:
#   1. Extract Momentum's resources.tar.gz (apps + dolphin + assets + fuzzers)
#   2. Overlay UberGuidoZ (Sub-GHz, NFC, IR, BadUSB)
#   3. Overlay Flipper-IRDB
#   4. Overlay flipperzero-bruteforce sub_files
#   5. Overlay intercom-keys
#   6. Overlay Flipper-Starnew (split iButton/RFID)
#   7. Cleanup macOS metadata
#
# Prerequisites:
#   - Momentum built at least once: `cd forks/momentum && ./fbt updater_package`
#   - SD card mounted at the path argument (default /Volumes/Flipper SD)
#   - All submodules initialized

set -euo pipefail

SD="${1:-/Volumes/Flipper SD}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -d "$SD" ]]; then
  echo "error: SD card not mounted at: $SD" >&2
  exit 1
fi

# Find Momentum's update bundle
RESOURCES=$(find "$REPO/forks/momentum/dist/f7-C" -maxdepth 3 -name 'resources.tar.gz' 2>/dev/null | head -1)
if [[ -z "$RESOURCES" ]]; then
  echo "error: Momentum not built. Run:" >&2
  echo "  cd forks/momentum && ./fbt updater_package" >&2
  exit 1
fi

echo "Source bundle: $RESOURCES"
echo "Target SD:     $SD"
echo

# Step 1: Extract Momentum bundle (apps + dolphin + assets + fuzzers + DBs)
echo "[1/7] Extracting Momentum resources..."
( cd "$SD" && tar -xzf "$RESOURCES" --exclude='._*' )

# Step 2: UberGuidoZ Sub-GHz / NFC / IR / BadUSB
RSYNC_FLAGS=(-a --exclude='.git' --exclude='.git*' --exclude='.DS_Store'
             --exclude='._*' --exclude='*.md' --exclude='*.html'
             --exclude='*.bat' --exclude='LICENSE*')

echo "[2/7] UberGuidoZ Sub-GHz..."
rsync "${RSYNC_FLAGS[@]}" "$REPO/forks/uberguidoz-flipper/Sub-GHz/" "$SD/subghz/UberGuidoZ/"

echo "[3/7] UberGuidoZ NFC..."
rsync "${RSYNC_FLAGS[@]}" "$REPO/forks/uberguidoz-flipper/NFC/" "$SD/nfc/UberGuidoZ/"

echo "[4/7] UberGuidoZ Infrared..."
rsync "${RSYNC_FLAGS[@]}" "$REPO/forks/uberguidoz-flipper/Infrared/" "$SD/infrared/UberGuidoZ/"

echo "[5/7] UberGuidoZ BadUSB..."
rsync "${RSYNC_FLAGS[@]}" \
  --exclude='*passwordgrabber*' --exclude='*DiscordGrabber*' --exclude='*credgrab*' \
  "$REPO/forks/uberguidoz-flipper/BadUSB/" "$SD/badusb/UberGuidoZ/"

echo "[6/7] Flipper-IRDB..."
rsync "${RSYNC_FLAGS[@]}" --exclude='_data/' "$REPO/forks/flipper-irdb/" "$SD/infrared/IRDB/"

echo "[6/7] bruteforce sub files..."
mkdir -p "$SD/subghz/bruteforce"
rsync "${RSYNC_FLAGS[@]}" "$REPO/apps/bruteforce/sub_files/" "$SD/subghz/bruteforce/"

echo "[6/7] intercom-keys..."
mkdir -p "$SD/lfrfid/intercom-keys"
rsync "${RSYNC_FLAGS[@]}" --exclude='_config.yml' --exclude='Makefile' --exclude='AUTHORS.md' \
  "$REPO/forks/flipperzero-goodies/intercom-keys/" "$SD/lfrfid/intercom-keys/"

echo "[6/7] Flipper-Starnew (iButton + RFID split)..."
mkdir -p "$SD/ibutton/Starnew" "$SD/lfrfid/Starnew"
rsync -a --include='*.ibtn' --include='StarButton/***' --exclude='*' \
  "$REPO/forks/flipper-starnew/" "$SD/ibutton/Starnew/"
rsync -a --include='*.rfid' --include='StarRFID/***' --exclude='*' \
  "$REPO/forks/flipper-starnew/" "$SD/lfrfid/Starnew/"

# Step 7: Cleanup
echo "[7/7] Cleanup macOS metadata..."
"$REPO/scripts/sd-clean.sh" "$SD"

echo
echo "Deployed. SD card ready."
df -h "$SD" | tail -1
