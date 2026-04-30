# Infrared

Flipper Zero has an IR transmitter (940 nm LED) and receiver. Range ~10 m line-of-sight indoors.

## Common protocols

| Protocol | Carrier | Encoding | Used by |
|---|---|---|---|
| **NEC** | 38 kHz | Pulse-distance | Most consumer electronics (TV, audio) |
| **NECext** (extended NEC) | 38 kHz | 32-bit address | Newer NEC variants |
| **Samsung32** | 38 kHz | NEC-like | Samsung TVs |
| **RC5 / RC5x** | 36 kHz | Manchester | Philips, older European |
| **RC6** | 36 kHz | Pulse-period | Microsoft Media Center, some TVs |
| **Sony SIRC** | 40 kHz | Pulse-width | Sony devices |
| **Kaseikyo** | 37 kHz | 48-bit | Panasonic, Denon, others |
| **AC universal** | varies | Long blob (per brand) | Air conditioners — protocol per manufacturer |

## Workflow on Flipper

### 1. Capture a remote

Infrared → **Learn New Remote** → point the original remote at the Flipper's IR receiver (top edge) → press the button you want. Flipper detects protocol if it's a common one, or stores as RAW.

### 2. Universal Remote

Infrared → **Universal Remote** comes pre-loaded with brand databases:

- TV (Samsung, LG, Sony, TCL, Hisense, Vizio, Philips, Panasonic, etc.)
- Audio (universal speaker codes)
- AC (Mitsubishi, Daikin, LG, Samsung, Panasonic, Toshiba, Hitachi, Carrier, etc.)
- Projector (Epson, BenQ, Optoma, etc.)

When you don't have the original remote, brute-force through the brand list until something responds.

### 3. Save & replay

Captured remotes are saved to `/infrared/<your-name>.ir`. Each `.ir` file is a JSON-like text with one or more buttons. Edit by hand to rename buttons, add new ones, etc.

## File format

```
Filetype: IR signals file
Version: 1
#
name: Power
type: parsed
protocol: NECext
address: 04 00 00 00
command: 02 00 00 00
#
name: Vol+
type: raw
frequency: 38000
duty_cycle: 0.330000
data: 9024 4512 564 564 564 1692 ...
```

`type: parsed` is decoded; `type: raw` is just timing intervals at the carrier frequency.

## Two giant IR databases on the SD

Both deployed under `/infrared/`:

| Path | Contents |
|---|---|
| `/infrared/IRDB/` | logickworkshop/Flipper-IRDB — community-maintained, ~9000 device files, well-organized by brand/model |
| `/infrared/UberGuidoZ/` | UberGuidoZ collection — fewer but includes some not in IRDB |
| `/infrared/assets/universal/` | Momentum's bundled universal codes (used by the Universal Remote feature) |

When the Universal Remote brand-walk doesn't find your TV/AC, check IRDB by exact model number — it's usually there.

## AC remotes (the hard case)

AC remotes encode the *full state* (mode, temp, fan speed, swing, timer) in each transmission, not single button presses. So an "AC On" capture from your remote at 24°C cooling won't help you set 18°C heat — you'd need each state captured separately.

Flipper's IRDB has many AC files with the most common state combinations. If yours isn't there, capture the buttons you care about (specifically the ones for your typical states) and save them as a custom remote.

## Useful apps

Already on SD under `/apps/Infrared/`:

- `irdb_searcher` — full-text search across the universal IR database
- `flippinghexer` — TV-B-Gone style brute force across all brands rapidly
