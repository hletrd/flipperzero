# Deployment

Two practical ways to get bulk data onto the Flipper's SD card.

## Method A — USB SD card reader (recommended for >50 MB)

```bash
# 1. Power off Flipper
# 2. Remove SD card from Flipper (push-to-eject — slot is on the right edge)
# 3. Insert into USB SD reader, plug into Mac
# 4. SD mounts at /Volumes/Flipper SD/
# 5. Use rsync, cp, Finder, whatever
rsync -a --exclude='.git*' --exclude='._*' --exclude='*.md' \
  /Users/hletrd/git/flipperzero/forks/flipper-irdb/ \
  "/Volumes/Flipper SD/infrared/IRDB/"

# 6. Cleanup macOS metadata
find "/Volumes/Flipper SD" -name '._*' -delete
find "/Volumes/Flipper SD" -name '.DS_Store' -delete
rm -rf "/Volumes/Flipper SD/.fseventsd" "/Volumes/Flipper SD/.Spotlight-V100"

# 7. Eject cleanly
diskutil eject "/Volumes/Flipper SD"

# 8. Reinsert into Flipper, power on
```

**Throughput**: USB 3.0 SD reader → ~50–80 MB/s. The 910 MB the owner deployed took ~30 seconds.

## Method B — `storage.py` over USB CDC (for small adds, <10 MB)

Flipper firmware exposes a CLI over USB CDC at `/dev/cu.usbmodemflip_*`. The upstream firmware repo's `scripts/storage.py` wraps the protocol.

```bash
# Push a single file
python3 forks/upstream-firmware/scripts/storage.py \
  -p /dev/cu.usbmodemflip_<id> \
  send /local/file.fap /ext/apps/Sub-GHz/file.fap

# Push a tree
python3 forks/upstream-firmware/scripts/storage.py \
  -p /dev/cu.usbmodemflip_<id> \
  send-tree /local/dir/ /ext/remote/dir/

# Pull a tree (download FROM Flipper)
python3 forks/upstream-firmware/scripts/storage.py \
  -p /dev/cu.usbmodemflip_<id> \
  receive-tree /ext/subghz/ /local/backup/
```

**Throughput**: USB CDC throttles at **10–30 KB/s**. 910 MB this way would take 8–24 hours. Don't.

## Method C — qFlipper file manager

Open qFlipper → File Manager tab. Drag-drop files between Mac and Flipper. Same underlying CDC protocol as `storage.py` — same throughput limits. Useful for one-off small transfers because the GUI is friendlier.

## Method D — Flipper Mobile app (BLE)

Even slower than CDC (~2–5 KB/s). Not recommended for bulk data; useful for emergency on-the-go transfers.

## Capacity planning

The Flipper Zero ships with various SD card sizes (8 GB / 16 GB / 32 GB factory; 128 GB cards work but waste). The complete deployment in this repo (UberGuidoZ + Flipper-IRDB + Momentum DBs + apps) is ~4 GB.

**Recommended card**: 32 GB exFAT. Plenty of headroom for captures, app data, theme packs.

## Why the 8.5x size inflation on FAT32

FAT32 cluster size with 16+ GB cards is typically 32 KB. Each tiny file (e.g., a 200-byte `.ir` definition) consumes a full 32 KB cluster on disk. The IRDB has ~9000 small files: source = 113 MB, on-disk = ~960 MB.

Solutions:

- **exFAT** — variable cluster size, no fixed minimum. ~10–20% overhead vs source size.
- **Reformat with smaller cluster size** — `mkfs.fat -F 32 -s 8 /dev/diskN` (4 KB clusters). Brings overhead down considerably but reduces large-file performance.
- **Live with it** — modern SD cards are big enough that 8x bloat doesn't matter.

Momentum-formatted Flipper cards default to exFAT, which is fine.

## Eject vs unplug

On Mac, **always eject** the SD card via:

```bash
diskutil eject "/Volumes/Flipper SD"
```

Or right-click in Finder → Eject. Pulling the card without ejecting risks losing recent writes (macOS does delayed writeback).

On the Flipper, before pulling the card:

- Settings → Storage → SD Card → **Unmount**

Then pull. Otherwise running apps may corrupt files.
