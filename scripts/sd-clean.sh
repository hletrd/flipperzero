#!/usr/bin/env bash
# sd-clean.sh — strip macOS metadata from a Flipper SD card
#
# Usage: ./scripts/sd-clean.sh [/Volumes/Flipper SD]
#
# Removes:
#   - AppleDouble (._*) sidecar files
#   - .DS_Store thumbnail-state files
#   - .fseventsd, .Spotlight-V100, .Trashes metadata folders
#   - Disables Spotlight indexing on the volume
#
# Run after every batch of writes from macOS to the SD card.

set -euo pipefail

SD="${1:-/Volumes/Flipper SD}"

if [[ ! -d "$SD" ]]; then
  echo "error: SD card not mounted at: $SD" >&2
  exit 1
fi

echo "Cleaning $SD..."

# AppleDouble files (most common pollution)
COUNT_AD=$(/usr/bin/find "$SD" -name '._*' 2>/dev/null | wc -l | tr -d ' ')
/usr/bin/find "$SD" -name '._*' -delete 2>/dev/null || true

# .DS_Store
COUNT_DS=$(/usr/bin/find "$SD" -name '.DS_Store' 2>/dev/null | wc -l | tr -d ' ')
/usr/bin/find "$SD" -name '.DS_Store' -delete 2>/dev/null || true

# Metadata folders
rm -rf "$SD/.fseventsd" "$SD/.Spotlight-V100" "$SD/.Trashes" 2>/dev/null || true

# Spotlight off
mdutil -i off "$SD" >/dev/null 2>&1 || true

# Verify
REMAINING=$(/usr/bin/find "$SD" -name '._*' 2>/dev/null | wc -l | tr -d ' ')

echo "  AppleDouble removed: $COUNT_AD"
echo "  .DS_Store removed:   $COUNT_DS"
echo "  Remaining ._:        $REMAINING"

if [[ "$REMAINING" -gt 0 ]]; then
  echo
  echo "warning: $REMAINING AppleDouble files persist (likely Unicode normalization issue)" >&2
  echo "  see docs/sd-card/macos-pitfalls.md" >&2
  echo "  remaining files:"
  /usr/bin/find "$SD" -name '._*' 2>/dev/null | head -5 >&2
fi

echo "done"
