# CLAUDE.md

Project instructions for Claude Code (and other AI agents via the `AGENTS.md` symlink).

## Project context

This is a personal **Flipper Zero research workbench** — a meta-repository of firmware forks, app collections, protocol databases, and original documentation. The owner uses it for:

1. Reproducible firmware builds and recovery from a known state
2. Analysis of personally-owned RF devices (a Kia K5 DL3 2022 smart key, intercom RFID/iButton keys, etc.)
3. Educational study of wireless protocol security (Sub-GHz, NFC, RFID, BLE)

**It is not a product.** Everything operates on devices the owner has authorization to test.

## Repo structure

The repo is organized as a meta-repo with **15 git submodules**:

- `forks/<name>/` — full firmware forks or large reference collections
- `apps/<name>/` — standalone apps that build into single `.fap` files
- `docs/` — original knowledge base (this is the only original prose; everything in `forks/` and `apps/` is upstream code)

When working in this repo:

| Location | Origin | What to do |
|---|---|---|
| `docs/`, `README.md`, `CLAUDE.md`, `.gitignore`, `.gitmodules` | Original | OK to edit |
| `forks/*/`, `apps/*/` | Upstream submodules | **Never edit directly.** Modifications belong upstream |
| `/Volumes/Flipper SD/` (when SD card is mounted) | Generated/deployed | OK to modify, but it's runtime state, not source |

## Build instructions per firmware

All firmware forks share the `fbt` build system:

```bash
cd forks/<firmware>
./fbt FORCE=1 flash_usb_full   # build + flash via USB CDC
./fbt updater_package          # build TGZ for qFlipper install
./fbt fap_dist                 # build all external apps as .fap
```

**`FBT_NO_SYNC=1`** environment var skips submodule re-sync (recommended once initial sync completes).

The Flipper firmware build downloads its own arm-none-eabi GCC toolchain into `forks/<fw>/toolchain/` (~600 MB) on first run.

## App build via ufbt

For standalone apps (with `application.fam`):

```bash
# Configure for Momentum SDK (target firmware)
ufbt update --index-url=https://up.momentum-fw.dev/firmware/directory.json --channel=release

# Or for stock
ufbt update --channel=release

# Build a .fap from anywhere with application.fam
cd apps/tpms && ufbt build
# → ~/.ufbt/build/<app>.fap
```

`.fap` files are ABI-locked to the firmware they're built against. Stock and Momentum currently share API 87.1, so apps built against either tend to work on both. Unleashed/RogueMaster have divergent ABIs — their `.fap` files are not portable.

## Working with the Flipper

Key commands when the Flipper is connected:

```bash
# Find the serial device
ls /dev/cu.usbmodemflip_*

# Push a single file
python3 forks/upstream-firmware/scripts/storage.py -p /dev/cu.usbmodemflip_* send <local> <remote>

# Push a tree
python3 forks/upstream-firmware/scripts/storage.py -p /dev/cu.usbmodemflip_* send-tree <local-dir> <remote-dir>
```

USB CDC throughput is 10–30 KB/s. **For >50 MB of data, pull the SD card and use a USB SD reader on the Mac instead.** See `docs/sd-card/deployment.md`.

## SD card layout (Momentum)

Standard Momentum partitions on the Flipper's microSD:

```
/                       (SD root, mounts as /ext on Flipper)
├── apps/<Category>/    .fap apps grouped by category
├── apps_assets/        Read-only resources for apps
├── apps_data/          Per-app data/config storage
├── asset_packs/        Theme/animation/sound packs
├── badusb/             DuckyScript payloads
├── dolphin/            Dolphin AI animation frames
├── infrared/           IR codes (universal/, plus user folders)
├── ibutton/            iButton key dumps
├── ibutton_fuzzer/     Fuzzer base data
├── lfrfid/             125 kHz RFID dumps
├── lfrfid_fuzzer/      Fuzzer base data
├── mifare_fuzzer/      Mifare key dictionaries
├── nfc/                NFC card dumps
├── subghz/             Sub-GHz captures (.sub) and TPMS DB
├── u2f/                U2F keys
├── update/             Firmware update bundles
└── wav_player/         WAV samples
```

When initializing a fresh SD card, extract `forks/momentum/dist/f7-C/f7-update-*/resources.tar.gz` to populate everything except `/apps/` (which is built separately and copied via the bundled .fap files).

## macOS + exFAT pitfalls

The Flipper SD is exFAT-formatted. macOS introduces several problems:

1. **AppleDouble (`._*`) files** — macOS auto-creates these for HFS+ metadata. Flipper ignores them, but they pollute. After every copy: `find /Volumes/'Flipper SD' -name '._*' -delete`.
2. **Unicode normalization mismatch** — exFAT stores filenames in NFC, but `os.listdir()` may return NFD. If a delete fails with `ENOENT` despite the file appearing in `ls`, normalize to NFC: `unicodedata.normalize('NFC', name)`.
3. **`.DS_Store`, `.fseventsd`, `.Spotlight-V100`, `.Trashes`** — sweep these too.

The cleanup recipe: `find ... -name '._*' -delete && rm -rf .fseventsd .Spotlight-V100 .Trashes`. See `docs/sd-card/macos-pitfalls.md`.

## Hardware safety

When flashing or recovering firmware:

- **Don't unplug during DFU phase.** The Flipper progresses through bootloader → radio stack → main firmware install with multiple reboots — keep it plugged in until the dolphin desktop reappears.
- **DFU recovery for bricked devices: use qFlipper.** `brew install --cask qflipper` → open app → it auto-detects DFU mode and offers Repair. Do NOT try to flash from DFU via fbt — `flash_usb_full` requires the device booted in normal mode (qFlipper protocol over CDC).
- **SD card is hot-pluggable** when Flipper is off, but pull cleanly when on (Settings → Storage → Unmount before pulling).

## Conventions for any agent working here

1. **Submodules are read-only from this repo's perspective.** Don't `git add` files inside `forks/*/` or `apps/*/`.
2. **Use `git submodule status`** to see if any submodule has drifted. The recorded commits are the deliberate pin.
3. **For docs in `docs/`** — semantic markdown, file-per-topic, link liberally. Hierarchical; each subdirectory has a `README.md` index.
4. **Commit style** — Conventional Commits + gitmoji: `docs: 📝 add Sub-GHz protocol notes`, `feat: ✨ add Momentum SDK build target`, etc. **No `Co-Authored-By: Claude` lines** — owner preference.
5. **GPG signing** is enabled at the user-global level (`commit.gpgsign = true`). Pass `-S` only if needed; usually the global config takes care of it.
6. **Never edit `.gitmodules` URLs without coordinating with the owner** — those are the canonical upstream pointers.

## Out-of-scope behaviors

- **No automated firmware flashing.** Always confirm with the owner before any destructive device operation. Flashing is destructive.
- **No public push without explicit permission.** This repo is intended public, but specific branches or commits may not be.
- **No editing of submodule contents** intending it to "stick" — it won't, and changes get nuked on the next `submodule update`.

## Reference: why this layout?

Submodules vs. monorepo: the firmware forks are huge (several GB combined) and have their own velocity. As submodules they pin to specific commits that are reproducible without bloating this repo with their full history. The owner can then:

- `git submodule update --remote forks/momentum` to track Momentum's tip
- Hold older firmware at fixed commits while Momentum advances
- Easily blame which upstream commit broke a workflow

Submodules also let licensors of the upstream code take responsibility for their own license terms — this repo only references URLs and commit hashes.

## When the owner asks "do X on the Flipper"

Standard sequence:

1. Verify Flipper is connected: `ls /dev/cu.usbmodemflip_*` (must show at least one entry)
2. Pause/cancel any in-flight build that uses the device (don't start a flash while one is running)
3. For data deployment: prefer pulling SD card over `storage.py` (10–30× faster)
4. For app builds: use `ufbt build` from inside the app's source dir
5. For firmware flashes: use `./fbt FORCE=1 flash_usb_full` from the firmware's own source dir
6. After any firmware flash: re-deploy the user's customizations to SD card (firmware doesn't touch SD; user data persists, but if SD was wiped, re-extract `resources.tar.gz`)
