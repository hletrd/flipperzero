# Knowledge Base

Hierarchical reference for everything in this repo.

## Contents

### [Firmware](firmware/)
- [comparison.md](firmware/comparison.md) — fork lineage, when to choose which
- [installation.md](firmware/installation.md) — flash via fbt / qFlipper / web updater
- [recovery.md](firmware/recovery.md) — DFU recovery for bricked devices

### [Research](research/)
- [sub-ghz.md](research/sub-ghz.md) — 300/315/433/868/915 MHz, OOK, FSK, rolling codes
- [nfc.md](research/nfc.md) — 13.56 MHz, ISO14443A/B, Mifare, EMV
- [rfid.md](research/rfid.md) — 125 kHz LF (EM4100, HID, Indala, T5577)
- [infrared.md](research/infrared.md) — NEC, RC5, Sony SIRC, AC protocols
- [ibutton.md](research/ibutton.md) — 1-Wire (Dallas, Cyfral, Metakom)
- [badusb.md](research/badusb.md) — DuckyScript, HID emulation
- [bluetooth.md](research/bluetooth.md) — BLE advertisements, LE Audio, BLE Spam
- [tpms.md](research/tpms.md) — tire pressure sensor protocols (Schrader, Renault, Toyota, etc.)
- [u2f.md](research/u2f.md) — Flipper as a U2F security key
- [sdr.md](research/sdr.md) — RTL-SDR / HackRF integration with Flipper workflow

### [Cars](cars/)
- [smart-keys.md](cars/smart-keys.md) — RKE / PKES / immobilizer architecture
- [kia-k5-dl3.md](cars/kia-k5-dl3.md) — owner's specific car (CQOFD00790, 433.92 MHz, 4A chip)
- [hyundai-kia-vulnerabilities.md](cars/hyundai-kia-vulnerabilities.md) — Game Boy emulator, RollBack

### [SD Card](sd-card/)
- [layout.md](sd-card/layout.md) — Momentum directory structure
- [deployment.md](sd-card/deployment.md) — bulk transfer (CDC vs card reader)
- [macos-pitfalls.md](sd-card/macos-pitfalls.md) — AppleDouble, Unicode normalization

### [Hardware](hardware/)
- [flipper-zero.md](hardware/flipper-zero.md) — STM32WB55, CC1101, ST25R3916, RFM69-style LF
- [proxmark3.md](hardware/proxmark3.md) — Proxmark3 RDV4 — when to reach for it instead
- [gpio-addons.md](hardware/gpio-addons.md) — WiFi DevBoard, NRF24, GPS, external CC1101, GPIO sensors

### [Apps](apps/)
- [api-compatibility.md](apps/api-compatibility.md) — `.fap` ABI lock-in, Momentum vs stock vs UL/RM

### [Legal](legal/)
- [README.md](legal/README.md) — ethics, regulatory framing, what's OK on your own gear

## How to read this

Documents are short, dense, and link to each other. Start at whichever subsection matches your immediate question. Each major folder has its own `README.md` if more guidance is needed.

Source authority order (highest → lowest):
1. Submodule upstream READMEs (firmware-specific quirks)
2. This knowledge base (synthesized + opinionated)
3. Forum posts / blog posts (linked from notes — verify before trusting)
