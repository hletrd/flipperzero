#!/usr/bin/env bash
# build-apps.sh — rebuild custom apps against the current ufbt SDK
#
# Usage: ./scripts/build-apps.sh [stock|momentum|unleashed]
#
# Default target: momentum.
#
# Build strategy per target:
#   - momentum:  prefer forks/momentum-apps/<name>/ if present (curated v6.6+),
#                fall back to apps/<name>/ otherwise
#   - stock:     always build from apps/<name>/ (against stock SDK)
#   - unleashed: always build from apps/<name>/ (against unleashed SDK)
#
# Why the override: forks/momentum-apps/ holds versions specifically tuned for
# Momentum's BLE/SubGHz/NFC stacks. The stand-alone apps/ submodules track
# upstream "works on stock" sources and can be older or use removed APIs.

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
  momentum)   INDEX_URL="https://up.momentum-fw.dev/firmware/directory.json" ;;
  stock)      INDEX_URL="https://update.flipperzero.one/firmware/directory.json" ;;
  unleashed)  INDEX_URL="https://up.unleashedflip.com/directory.json" ;;
  *)
    echo "error: unknown target: $TARGET (must be stock|momentum|unleashed)" >&2
    exit 1
    ;;
esac

echo "ufbt: switching SDK to $TARGET..."
"$UFBT" update --index-url="$INDEX_URL" --channel=release

OUT_DIR="$REPO/build/apps-$TARGET"
mkdir -p "$OUT_DIR"

# Resolve the source directory for a given app name.
# When TARGET=momentum, prefer forks/momentum-apps/<name>/ if present.
resolve_source() {
  local name="$1"
  if [[ "$TARGET" == "momentum" ]] \
     && [[ -f "$REPO/forks/momentum-apps/$name/application.fam" ]]; then
    echo "$REPO/forks/momentum-apps/$name"
  elif [[ -f "$REPO/apps/$name/application.fam" ]]; then
    echo "$REPO/apps/$name"
  else
    echo ""
  fi
}

# Apps to build: union of apps/ submodules + any explicitly named ones.
APPS=()
for d in "$REPO/apps"/*/; do
  [[ -f "${d}application.fam" ]] && APPS+=("$(basename "$d")")
done

# Always include ble_spam from momentum-apps (no apps/ble-spam submodule anymore)
if [[ "$TARGET" == "momentum" ]] && [[ -f "$REPO/forks/momentum-apps/ble_spam/application.fam" ]]; then
  APPS+=("ble_spam")
fi

for app in "${APPS[@]}"; do
  src="$(resolve_source "$app")"
  if [[ -z "$src" ]]; then
    echo "skip $app (no source for target $TARGET)"
    continue
  fi

  echo
  echo "=== building $app from $(basename "$(dirname "$src")")/$(basename "$src") for $TARGET ==="
  ( cd "$src" && "$UFBT" build )

  # ufbt writes to ~/.ufbt/build/<appid>.fap — find by recent mtime
  FAP=$(find "$HOME/.ufbt/build" -maxdepth 1 -name "*.fap" -mmin -2 -print0 \
        | xargs -0 ls -t 2>/dev/null | head -1)
  if [[ -n "$FAP" ]]; then
    cp "$FAP" "$OUT_DIR/$(basename "$FAP")"
    echo "  → $OUT_DIR/$(basename "$FAP")"
  fi
done

echo
echo "Built apps for $TARGET in $OUT_DIR/"
ls -la "$OUT_DIR"
