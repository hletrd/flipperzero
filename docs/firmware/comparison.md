# Firmware Comparison

Eight firmware options are tracked in this repo. Only one runs on the device at a time.

## Lineage

```
Stock OFW (flipperdevices/flipperzero-firmware)
├── Unleashed (DarkFlippers/unleashed-firmware)
│   └── RogueMaster (RogueMaster/flipperzero-firmware-wPlugins)
│       └── SyberxSpace-noG (SyberxSpace/flipperzero-firmware-wPlugins-noG)
└── Xtreme → Momentum (Next-Flip/Momentum-Firmware)

Specialty:
└── EvilCrowRF (h-RAT/EvilCrowRF_Custom_Firmware_CC1101_FlipperZero)
    — fork focused on driving an EvilCrow-RF external CC1101 board
```

## Decision matrix

| Goal | Pick | Why |
|---|---|---|
| First-time setup, conservative | **Stock OFW** | Smallest attack surface, official support, App Lab compatibility |
| Most features + stability + active dev | **Momentum** ⭐ | Built-in TPMS reader, BLE Spam, weather, POCSAG, NMEA; active maintenance; close API alignment with stock |
| Region-unlocked + selective rolling-code remotes | **Unleashed** | Stripped region locks, KeeLoq-family rolling-code support for gates (CAME/Nice/BFT/Doorhan/Somfy), conservative changes |
| Lots of plugins/games, themes, "fun" | **RogueMaster** | RM is RM. Less stable, more flair, every community plugin pre-included |
| RogueMaster minus games/animations bloat | **SyberxSpace-noG** | Same as RogueMaster but `-noG` (no games), smaller flash footprint |
| Driving an external CC1101 transceiver via GPIO | **EvilCrowRF** | Specialized fork for the EvilCrow-RF board; not for daily driver |

## API/SDK ABI alignment

This matters for whether `.fap` apps written for one firmware run on another.

| Firmware | API target | `.fap` portability |
|---|---|---|
| Stock OFW | 87.x | App Lab apps work |
| Momentum | 87.1 (tracks stock) | Stock-built `.fap` usually work; Momentum-built apps work on stock; **Momentum-Apps are the safest source** |
| Unleashed | own ABI (UL-flavored) | UL apps don't reliably run on stock/Momentum |
| RogueMaster | tracks Unleashed | Same as UL |
| SyberxSpace | tracks RogueMaster | Same as RM/UL |

**Practical rule**: Don't drag `.fap` files between firmware families without rebuilding. The Momentum-Apps repo (`forks/momentum-apps`) is the curated source for Momentum-compatible apps.

## Update servers

| Firmware | Update directory.json |
|---|---|
| Stock | `https://update.flipperzero.one/firmware/directory.json` |
| Momentum | `https://up.momentum-fw.dev/firmware/directory.json` |
| Unleashed | `https://up.unleashedflip.com/directory.json` |
| RogueMaster | `https://flipper-update.xfw.su/directory.json` (varies) |

Use these with `ufbt update --index-url=<url> --channel=release` to switch ufbt's SDK target.

## Switching between firmware

Re-flashing replaces the on-flash firmware but **does not wipe the SD card**. User data, captures, apps, IR/NFC/Sub-GHz dumps survive a firmware swap. The only potential casualties:

- App `.fap` files in `/apps/` may show "API mismatch" if the new firmware has a different ABI. Re-deploy from the new firmware's bundled apps.
- Some firmwares write protocol-specific data in different paths. Check upstream docs before assuming everything will work.

**For the bullet-proof path**: backup `/Volumes/Flipper SD/` before any firmware swap.
