#!/usr/bin/env bash
# build-apps.sh — rebuild all custom apps in apps/ against the current ufbt SDK
#
# Usage: ./scripts/build-apps.sh [--target=stock|momentum]
#
# Default target: momentum (tracks the firmware that's currently flashed)

set -euo pipefail

TARGET="${1:-momentum}"
TARGET="${TARGET#--target=}"

REPO="$(cd "$(dirname "$0")/.." && pwd)"
UFBT="${UFBT:-$HOME/Library/Python/3.14/bin/ufbt}"

if [[ ! -x "$UFBT" ]]; then
  echo "error: ufbt not found at $UFBT" >&2
  echo "install: pip3 install --user --break-system-packages ufbt" >&2
  exit 1
fi

case "$TARGET" in
  momentum)
    INDEX_URL="https://up.momentum-fw.dev/firmware/directory.json"
    ;;
  stock)
    INDEX_URL="https://update.flipperzero.one/firmware/directory.json"
    ;;
  unleashed)
    INDEX_URL="https://up.unleashedflip.com/directory.json"
    ;;
  *)
    echo "error: unknown target: $TARGET (must be stock|momentum|unleashed)" >&2
    exit 1
    ;;
esac

echo "ufbt: switching SDK to $TARGET..."
"$UFBT" update --index-url="$INDEX_URL" --channel=release

OUT_DIR="$REPO/build/apps-$TARGET"
mkdir -p "$OUT_DIR"

for app_dir in "$REPO/apps"/*/; do
  app="$(basename "$app_dir")"
  if [[ ! -f "$app_dir/application.fam" ]]; then
    echo "skip $app (no application.fam — not a single-app source dir)"
    continue
  fi

  echo
  echo "=== building $app for $TARGET ==="
  ( cd "$app_dir" && "$UFBT" build )

  # Find the produced .fap (ufbt always writes to ~/.ufbt/build/)
  FAP=$(find "$HOME/.ufbt/build" -maxdepth 1 -name "*.fap" -mmin -2 | head -1)
  if [[ -n "$FAP" ]]; then
    cp "$FAP" "$OUT_DIR/$(basename "$FAP")"
    echo "  → $OUT_DIR/$(basename "$FAP")"
  fi
done

echo
echo "Built apps for $TARGET in $OUT_DIR/"
ls -la "$OUT_DIR"
