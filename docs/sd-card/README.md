# SD Card

The Flipper Zero's microSD card is the persistent state for everything: apps, captures, configurations, theme packs.

| Doc | What |
|---|---|
| [layout.md](layout.md) | Standard Momentum directory tree |
| [deployment.md](deployment.md) | Bulk transfer methods (card reader vs CDC) |
| [macos-pitfalls.md](macos-pitfalls.md) | AppleDouble, Unicode normalization, Spotlight |

**Recommended workflow for batch updates**: pull SD, copy via USB SD reader on Mac, run cleanup script, eject, reinsert.
