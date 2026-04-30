# macOS + exFAT pitfalls

Working with the Flipper SD card on macOS introduces several quirks. Each has a workaround.

## 1. AppleDouble (`._*`) files

When macOS writes to a non-Apple filesystem (FAT, exFAT, NTFS), it creates a sidecar file `._<original>` for every file containing extended attributes (Finder metadata, resource forks, color tags). These are auto-generated even if your source has none.

### Symptoms

- After `cp` or rsync, the SD card has twice as many files as expected
- `find /Volumes/'Flipper SD' -name '._*' | wc -l` returns thousands
- Flipper app browser shows `._<app>.fap` entries that fail to load

### Fix

```bash
find "/Volumes/Flipper SD" -name '._*' -delete
```

Run this **after** every batch of writes from macOS. rsync's `--exclude='._*'` only excludes from the **source** — the destination still gets them auto-created by macOS.

### Prevention

```bash
# Disable AppleDouble creation system-wide for network/non-Apple FS
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
killall Finder
```

This prevents `.DS_Store` creation on network and USB stores. It does NOT block AppleDouble entirely (those are kernel-level) but reduces them.

For complete elimination: format the SD as APFS (won't work — Flipper firmware can't read APFS) or write from a Linux/Windows machine.

## 2. Unicode normalization mismatch (NFC vs NFD)

exFAT stores filenames in **NFC (composed)** form: a single codepoint for accented characters (`à` = U+00E0).

macOS HFS+ historically used **NFD (decomposed)**: base + combining marks (`à` = U+0061 + U+0300).

When macOS lists exFAT directory entries via `os.listdir()`, the result may be either form, often inconsistent. `os.unlink()` then fails because the path doesn't match what's actually stored.

### Symptoms

```
$ ls "/Volumes/Flipper SD/badusb/foo/"
  payload à upload.txt
  ._payload à upload.txt

$ rm "/Volumes/Flipper SD/badusb/foo/._payload à upload.txt"
# silently does nothing or returns ENOENT
```

### Fix in Python

```python
import os, unicodedata

base = '/Volumes/Flipper SD/badusb/foo'
target = 'payload \u00e0 upload.txt'  # NFC form (single codepoint à)
for form in ('NFC', 'NFD'):
    full = os.path.join(base, unicodedata.normalize(form, target))
    try:
        os.unlink(full)
        print(f'deleted via {form}')
        break
    except OSError as e:
        continue
```

The fix worked when the owner hit this on `payload à upload en ligne.ps1` files in the UberGuidoZ BadUSB collection — NFC form succeeded where NFD form failed with ENOENT.

### Workaround

If a single file is permanently un-deletable, delete its parent directory:

```bash
rm -rf "/path/to/parent"
```

`rm -rf` operates on the inode of the directory, not the file path, and walks the directory entries directly — succeeds where targeted file-deletion fails.

## 3. `.DS_Store`, `.fseventsd`, `.Spotlight-V100`, `.Trashes`

macOS creates these whenever you open a folder in Finder or a process indexes the volume.

```bash
# Delete after writes
find "/Volumes/Flipper SD" -name '.DS_Store' -delete
rm -rf "/Volumes/Flipper SD/.fseventsd" \
       "/Volumes/Flipper SD/.Spotlight-V100" \
       "/Volumes/Flipper SD/.Trashes"
```

### Prevent Spotlight indexing

```bash
mdutil -i off "/Volumes/Flipper SD"
mdutil -E "/Volumes/Flipper SD"  # Erase existing index
```

Spotlight ignores Flipper SD this way.

## 4. Case-sensitivity assumption

exFAT is **case-insensitive but case-preserving**. Some Flipper apps assume case-sensitive paths (more common in Linux-derived code). Symptoms:

- `cd /ext/Apps` works but the app expects `/ext/apps`
- File search returns nothing for `Mfclassic.fap` when file is `mfclassic.fap`

Generally not a problem with the standard Momentum directory structure, but watch for it when copying user data with mixed case.

## 5. Spaces in volume name

The default volume name "Flipper SD" has a space. Quote it everywhere:

```bash
# Correct
ls "/Volumes/Flipper SD"

# Wrong — shell splits into two args
ls /Volumes/Flipper SD
```

## 6. Flipper's `/ext/` vs Mac's `/Volumes/Flipper SD/`

Same content, different mount points:

- On the **Flipper firmware**: SD root is `/ext/`. So `apps/Sub-GHz/foo.fap` on the card is `/ext/apps/Sub-GHz/foo.fap` to Flipper apps.
- On **macOS via card reader**: same content at `/Volumes/Flipper SD/apps/Sub-GHz/foo.fap`.
- On **macOS via storage.py over USB CDC**: storage.py uses `/ext/` paths.

This trips up scripts that assume one or the other.

## Recipe: clean SD after a batch deploy

```bash
SD="/Volumes/Flipper SD"

# Delete AppleDouble
find "$SD" -name '._*' -delete

# Delete Mac metadata folders
rm -rf "$SD/.fseventsd" "$SD/.Spotlight-V100" "$SD/.Trashes"
find "$SD" -name '.DS_Store' -delete

# Disable Spotlight for next session
mdutil -i off "$SD" 2>/dev/null

# Verify clean
echo "Remaining ._ files: $(find "$SD" -name '._*' | wc -l)"
echo "Remaining .DS_Store: $(find "$SD" -name '.DS_Store' | wc -l)"
echo "Total: $(du -sh "$SD")"
```

Run this **at the end of every deployment session**.
