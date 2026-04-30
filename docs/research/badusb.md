# BadUSB

Flipper Zero acts as a USB HID keyboard when plugged into a target computer via USB-C. It can type at full keyboard speed (~50–100 keystrokes/sec). With its DuckyScript interpreter, you can write payloads that execute commands as if a human typed them.

## DuckyScript primer

Saved as `.txt` files in `/badusb/`. Run via Apps → BadUSB → select file → plug into target.

```duckyscript
REM payload: open Spotlight and run Calculator on macOS
DELAY 1000
GUI SPACE
DELAY 500
STRING Calculator
DELAY 200
ENTER
```

Common commands:

| Command | What |
|---|---|
| `STRING <text>` | Types literal text |
| `ENTER` / `RETURN` | Press Enter |
| `GUI` | Cmd (macOS) / Win (Windows) / Super (Linux) |
| `CTRL`, `ALT`, `SHIFT` | Modifier keys |
| `DELAY <ms>` | Wait |
| `REM <comment>` | Comment line |
| `WINDOWS r` | Win+R (Run dialog on Windows) |
| `STRING_DELAY <ms>` | Pause between each character |

Multiple modifiers can be combined: `GUI SHIFT 4` (macOS screenshot-region selector).

## Typical payloads

The UberGuidoZ `/badusb/UberGuidoZ/` collection on the SD has hundreds. Categories:

- **Innocent demos** — open browser, play YouTube, swap wallpaper
- **Productivity** — auto-type long strings, configure dev environment
- **Pranks** — Rickroll, fake error messages, mouse jiggle
- **Pentest legit** — disable Defender (with admin), exfil-via-DNS demos
- **Sketchy / not-recommended** — credential dumps, persistent shells

The owner removed `s4dic - BadUSB/DiscordGrabber/` and `s4dic - BadUSB/passwordgrabber/` (Discord token + password exfiltration) — these are credential-theft payloads, not appropriate for personal device deployment.

## Cross-platform considerations

DuckyScript is technically OS-agnostic but most payloads target a specific OS:

| Target OS | Hint in payload |
|---|---|
| Windows | Uses `WINDOWS r`, `cmd.exe`, PowerShell |
| macOS | Uses `GUI SPACE` (Spotlight), `Terminal.app`, `osascript` |
| Linux | Uses `CTRL ALT t` (terminal hotkey varies by DE) |

If you're testing a payload on the wrong OS, it'll mash random keys and either fail silently or open something unintended.

## Keyboard layout

Default DuckyScript assumes **US QWERTY**. If your target machine is set to a different layout (Korean, French AZERTY, etc.), the typed characters will be wrong. Solutions:

1. Set keyboard layout to US on the target before running (often impractical — it's a target)
2. Use `ALT_STRING` variants in some DuckyScript dialects
3. Build/load payloads that target the specific layout

Momentum supports multiple layouts — Apps → BadUSB → Settings → Layout.

## Detection

Most modern endpoint security treats unexpected USB HID devices as suspicious — a Flipper plugged into a managed corporate laptop will likely trip the EDR.

## Use cases (legitimate)

- Auto-typing long terminal commands you can't paste (some VM consoles, KVM-over-IP)
- Demo / training: showing how easy USB attacks can be
- Pentesting under engagement contracts
- Bypassing keyboard remap insanity at boot menus

## Don't

- Plug into a computer you don't own/aren't authorized to test
- Run credential-theft payloads, ever, regardless of target ownership (illegal in most jurisdictions and exfiltrates real secrets)
- Persist beyond a single session — that's malware territory

## Built-in apps related

- `bad_kb` — BadUSB but over Bluetooth HID (no USB connection needed; pairs with target as BLE keyboard). Already on SD under `/apps/Bluetooth/`.
- `bad_usb_arnab` and other variants in Momentum-Apps
