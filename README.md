<div align="center">

<img src="docs/assets/hero.svg" width="180" alt="Flipper Zero Lab"/>

# Flipper Zero Lab

**A curated workbench for Flipper Zero research, custom firmware, and RF protocol exploration.**

<p>
  <img src="https://img.shields.io/badge/Hardware-Flipper%20Zero-FF8C00?style=flat-square" alt="Hardware"/>
  <img src="https://img.shields.io/badge/Firmware-Momentum-9333EA?style=flat-square" alt="Firmware"/>
  <img src="https://img.shields.io/badge/Submodules-15-success?style=flat-square" alt="Submodules"/>
  <img src="https://img.shields.io/badge/Bands-125kHz%20%7C%20Sub--GHz%20%7C%20BLE%20%7C%2013.56MHz-blue?style=flat-square" alt="Bands"/>
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square" alt="Status"/>
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square" alt="License"/>
</p>

<p>
  <code>Sub-GHz</code> · <code>NFC</code> · <code>RFID</code> · <code>Infrared</code> · <code>iButton</code> · <code>BadUSB</code> · <code>BLE</code> · <code>SDR</code> · <code>RKE</code> · <code>PKES</code>
</p>

</div>

---

## What's here

A meta-repo aggregating every popular Flipper Zero firmware fork, app collection, and protocol database as **git submodules** — so each upstream commit is reproducible — plus a hierarchical knowledge base under [`docs/`](docs/) covering RF protocol research, smart-key analysis, SD card layout, and firmware comparison.

This is **personal research material**, not a product. It targets:
- Backup and recovery of a personal Flipper Zero
- Analysis of personally-owned RF devices (key fobs, garage remotes, RFID/iButton keys)
- Educational study of wireless protocol security

## Repo layout

```
.
├── forks/                      Custom firmware forks (submodules)
│   ├── upstream-firmware/      flipperdevices/flipperzero-firmware (stock OFW)
│   ├── momentum/               Next-Flip/Momentum-Firmware
│   ├── momentum-apps/          Next-Flip/Momentum-Apps
│   ├── unleashed/              DarkFlippers/unleashed-firmware
│   ├── roguemaster/            RogueMaster/flipperzero-firmware-wPlugins
│   ├── syberxspace-firmware/   SyberxSpace/flipperzero-firmware-wPlugins-noG
│   ├── evilcrowrf/             h-RAT/EvilCrowRF_Custom_Firmware_CC1101_FlipperZero
│   ├── awesome-flipperzero/    djsime1/awesome-flipperzero (index of all things)
│   ├── uberguidoz-flipper/     UberGuidoZ/Flipper (apps + Sub-GHz/NFC/IR/BadUSB DBs)
│   ├── flipper-irdb/           logickworkshop/Flipper-IRDB (community IR database)
│   ├── flipperzero-goodies/    wetox-team/flipperzero-goodies (intercom keys)
│   └── flipper-starnew/        glutesha/Flipper-Starnew (iButton/RFID key collection)
├── apps/                       Standalone apps (submodules)
│   ├── tpms/                   wosk/flipperzero-tpms
│   ├── bruteforce/             tobiabocchi/flipperzero-bruteforce (sub-file generator)
│   └── ble-spam/               noproto/ble_spam_ofw
└── docs/                       Knowledge base (this is the gold)
```

## Quick start

```bash
# Clone with all submodules
git clone --recursive https://github.com/hletrd/flipperzero.git
cd flipperzero

# Build & flash Momentum (the recommended firmware)
cd forks/momentum
./fbt FORCE=1 flash_usb_full

# Or build from upstream (stock OFW)
cd forks/upstream-firmware
./fbt FORCE=1 flash_usb_full
```

If you only want one firmware, do a partial submodule init:

```bash
git submodule update --init forks/momentum
```

## Documentation

The knowledge base lives under [`docs/`](docs/). Start with:

- [`docs/firmware/comparison.md`](docs/firmware/comparison.md) — fork comparison, when to choose which
- [`docs/firmware/installation.md`](docs/firmware/installation.md) — install via fbt / qFlipper / web updater
- [`docs/firmware/recovery.md`](docs/firmware/recovery.md) — DFU recovery for bricked devices
- [`docs/research/`](docs/research/) — Sub-GHz, NFC, RFID, IR, iButton, BadUSB, BLE deep dives
- [`docs/cars/`](docs/cars/) — automotive key fob research (RKE / PKES / smart keys)
- [`docs/sd-card/`](docs/sd-card/) — SD layout, deployment, macOS-on-FAT pitfalls
- [`docs/hardware/`](docs/hardware/) — Flipper Zero, Proxmark3 RDV4, complementary tools
- [`docs/legal/`](docs/legal/) — ethics and regulatory landscape

## Hardware references

| Device | Role |
|---|---|
| **Flipper Zero** (STM32WB55, CC1101 + ST25R3916 + RFM69-style LF) | Main target, all firmware |
| **Proxmark3 RDV4** | Heavy-lifting LF/HF RFID/NFC analysis where Flipper falls short |
| **microSD reader** | Bulk data deployment to Flipper SD card (USB CDC is too slow) |

## Status

| Component | State |
|---|---|
| Momentum firmware on device | ✅ Flashed (mntm-dev-a663836b) |
| SD card initialized | ✅ Apps + DBs (apps, asset_packs, dolphin, infrared, subghz, nfc, lfrfid, u2f, fuzzers) |
| 266 Momentum-verified `.fap` apps | ✅ Deployed |
| UberGuidoZ Sub-GHz / NFC / IR / BadUSB | ✅ Deployed |
| Flipper-IRDB | ✅ Deployed |
| Custom apps (TPMS, BLE Spam) | ✅ Built against Momentum SDK |

## License

This meta-repo's own contents (docs, README, hero, build glue) are MIT. Each submodule retains its upstream license — see each submodule's repo.

---

<div align="center">
<sub>Personal research repo. Use Flipper Zero responsibly. See <a href="docs/legal/">docs/legal</a>.</sub>
</div>
