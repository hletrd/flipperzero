# Captures

This directory is for the **owner's own captures** — `.sub`, `.nfc`, `.rfid`, `.ibtn`, `.ir`, BadUSB scripts produced by personal use of the Flipper Zero.

**By default, none of these are committed to the public git repo.**

The `.gitignore` keeps everything inside `captures/*/` out of git except the directory placeholders. This is intentional:

- A captured RFID key is a credential. Publishing it is publishing the means to access whatever it opens.
- A captured Sub-GHz signal from your own remote isn't sensitive in itself, but consistent captures over time can leak movement patterns.
- BadUSB scripts that work for your specific environment may include credentials, hostnames, or paths.

## Recommended workflow

1. Make captures on the Flipper. They live on the SD card (`/ext/subghz/`, `/ext/nfc/`, etc.).
2. Pull the SD card, plug into Mac.
3. Run `make sd-backup` — copies user captures to `~/flipperzero-sd-backup/<timestamp>/`.
4. If you want to selectively share *one* capture (e.g., for a write-up), copy it into `captures/<category>/` and add a `.gitkeep`-or-similar override. Be deliberate.

## Subdirectories

```
captures/
├── subghz/        Your Sub-GHz captures (.sub files)
├── nfc/           NFC card dumps (.nfc files)
├── rfid/          125 kHz RFID dumps (.rfid files)
├── ibutton/       iButton key dumps (.ibtn files)
├── infrared/      IR remote captures (.ir files)
└── badusb/        DuckyScript payloads (.txt files)
```

Each has a `.gitkeep` to preserve directory structure across clones. Files inside are gitignored.

## Sharing publicly

If you specifically want to share a capture (anonymized, no actual access value):

1. Strip identifying info (filename, comments) from the file
2. Add a force-include rule: `git add -f captures/subghz/<file>.sub`
3. Document what's in it with a sibling README

This is rare. Most captures should stay private.
