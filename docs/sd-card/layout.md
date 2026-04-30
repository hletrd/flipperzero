# SD Card Layout (Momentum)

The Flipper Zero's microSD card is mounted as `/ext/` inside the Flipper firmware, and as `/Volumes/Flipper SD/` (or whatever you named it) on the Mac when accessed via card reader.

Format: **exFAT** by default. FAT32 also works for cards <32 GB. **Don't use APFS** — Flipper firmware doesn't read it.

## Top-level directory tree

```
/
├── Manifest                Firmware-installed file manifest (don't touch)
├── favorites.txt           User favorites menu list
├── apps/                   Installed .fap apps, organized by category
│   ├── Bluetooth/
│   ├── Games/
│   ├── GPIO/
│   ├── iButton/
│   ├── Infrared/
│   ├── Media/
│   ├── NFC/
│   ├── RFID/
│   ├── Scripts/
│   ├── Sub-GHz/
│   ├── Tools/
│   └── USB/
├── apps_assets/            Read-only resources (icons, fonts, animations)
│   └── <appid>/
├── apps_data/              Per-app data + config storage
│   └── <appid>/
├── asset_packs/            Theme packs (animations + sound + icons)
├── badusb/                 DuckyScript .txt files
├── dolphin/                Dolphin-AI animation frames
├── infrared/               IR captures + universal database
│   ├── assets/
│   │   └── universal/      Bundled brand databases
│   ├── IRDB/               Flipper-IRDB community database (this repo deploys here)
│   └── UberGuidoZ/         UberGuidoZ IR collection
├── ibutton/                .ibtn key files
├── ibutton_fuzzer/         Fuzzer dictionaries
├── lfrfid/                 .rfid key files
├── lfrfid_fuzzer/          Fuzzer dictionaries
├── mifare_fuzzer/          Mifare key dictionaries
├── nfc/                    .nfc card dumps
│   └── assets/
│       ├── mf_classic_dict.nfc
│       └── mf_classic_dict_user.nfc
├── subghz/                 .sub captures
│   ├── assets/             TPMS database, RAW protocol assets
│   ├── bruteforce/         Generated bruteforce attack files
│   └── UberGuidoZ/
├── u2f/                    U2F authenticator keys
├── update/                 Firmware update bundles
└── wav_player/             WAV samples
```

## File extensions

| Extension | Purpose |
|---|---|
| `.fap` | Compiled Flipper Application Package |
| `.sub` | Sub-GHz capture (RAW or decoded) |
| `.ir` | Infrared remote (multi-button JSON-ish) |
| `.nfc` | NFC card dump |
| `.rfid` | 125 kHz RFID dump |
| `.ibtn` | iButton key |
| `.bad` / `.txt` | DuckyScript payload |
| `.fff` | Flipper Format File (generic — used for many things) |
| `.fmf` | Flipper Music File |

All Flipper file types are **plain text** with key-value structure (Filetype line + version + content). You can edit them in any text editor.

## Where to put your own captures

| Type | Where | Example filename |
|---|---|---|
| Sub-GHz remote | `/subghz/<your-name>/` | `/subghz/garage/main.sub` |
| Captured NFC card | `/nfc/<your-name>/` | `/nfc/work_badge.nfc` |
| RFID key | `/lfrfid/<your-name>/` | `/lfrfid/gym_key.rfid` |
| iButton | `/ibutton/<your-name>/` | `/ibutton/intercom.ibtn` |
| IR remote (your own) | `/infrared/<your-name>/` | `/infrared/livingroom_tv.ir` |
| BadUSB payload | `/badusb/<your-name>/` | `/badusb/setup_dev_env.txt` |

Use folders to keep things tidy — Flipper's file browser navigates them, and the search-by-folder helps when you have hundreds.

## What to NEVER touch

- `Manifest` — firmware-installed manifest. Modifying it can confuse Momentum's resource validator on next boot.
- `dolphin/` — animation frames. Editing breaks the dolphin AI.
- `apps_data/<appid>/` — apps store their own state here. Modifying user-data can corrupt app state.

## Restoring a wiped SD

If you reformat the SD card or it gets corrupted, re-deploy in this order:

1. Format as exFAT or FAT32 (use Disk Utility on Mac, or `sudo diskutil eraseDisk ExFAT 'Flipper SD' /dev/diskN`)
2. Mount on Mac
3. Extract `forks/momentum/dist/f7-C/f7-update-mntm-dev-*/resources.tar.gz` to the SD root: `cd /Volumes/'Flipper SD' && tar -xzf <path>/resources.tar.gz`
4. Run cleanup pass for AppleDouble files (see [macos-pitfalls.md](macos-pitfalls.md))
5. Add your custom captures, IR DB, etc.
6. Eject cleanly, insert into Flipper

The Flipper will recognize the structure and boot normally. No firmware re-flash needed.
