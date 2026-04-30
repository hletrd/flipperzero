# NFC (13.56 MHz)

The Flipper Zero uses an ST25R3916 NFC chip — supports ISO/IEC 14443 Type A & B, 15693 (vicinity), FeliCa, and ISO 18092 (peer-to-peer).

## Common targets

| Card type | Standard | Common deployments |
|---|---|---|
| **Mifare Classic** 1K/4K | ISO 14443A | Building access, transit (older), hotel keys |
| **Mifare Plus / DESFire** | ISO 14443A | Modern access cards, transit, payment cards |
| **Mifare Ultralight / NTAG** | ISO 14443A | NFC tags, posters, small access |
| **NTAG21x** (213/215/216) | ISO 14443A | Programmable tags, Amiibo, anti-counterfeit |
| **iCLASS / SEOS** | ISO 14443B / 15693 | HID enterprise access (LF + HF) |
| **EMV** (Visa/Mastercard) | ISO 14443A/B | Contactless payment |
| **FeliCa** | ISO 18092 | Japan/Asia transit (Suica, Pasmo, Octopus) |

## Workflow on Flipper

### 1. Detect a card

NFC → **Read** → tap the card to the back of the Flipper (around the iButton 1-Wire pad area, where the HF antenna is). The Flipper auto-detects type, ATQA, SAK, UID.

### 2. By card type

| Detected type | Typical outcome |
|---|---|
| Mifare Classic | Flipper attempts dictionary attack with stock + custom keys (`/nfc/assets/mf_classic_dict.nfc`). If sectors crack → full dump |
| Mifare Ultralight | Reads memory directly (often unprotected) |
| NTAG21x | Reads memory; may write if not locked |
| Mifare Plus / DESFire | UID only — encrypted SAM cannot be read without keys |
| iCLASS | UID + reader-side info; full read needs default/custom keys |
| EMV | Card brand, last digits, expiry, transaction log (depending on card config). Cannot extract live cryptogram or clone for payment |

### 3. Save & emulate

Saved dumps in `/nfc/`. Emulation requires a successful read of all sectors:

- Mifare Classic 1K/4K: full emulation
- NTAG21x: write-back if blank target available  
- DESFire: cannot emulate (crypto not breakable)

### 4. Custom keys

Mifare Classic security relies on per-sector 6-byte keys. Add known keys to `/nfc/assets/mf_classic_dict_user.nfc` (one per line, hex). Common transit/access dictionaries are widely circulated.

## Hyundai / Kia Digital Key 2 (NFC card key)

The Kia/Hyundai NFC card key (Kia Digital Key 2 Touch) uses a **secure element** — likely NXP SmartMX or Infineon SLE family. Flipper can read:

- UID and ATQA/SAK
- ISO 14443A type and protocol info

Flipper **cannot**:

- Read the encrypted application data
- Crack the AES challenge-response
- Clone the card to function with the vehicle

Same applies to a Proxmark3 RDV4 — the SE-based protocol is not exploitable with current public attacks. The card is paired to a specific VIN at registration time and uses keys never exposed to readers.

## EMV (payment cards)

Flipper can read and display:

- Card scheme (Visa/MC/Amex/JCB)
- PAN (full 16 digits) on most older cards; **most modern cards mask the PAN** unless an unauthenticated AID gives it up
- Expiry date
- Transaction log (last 10–20 transactions, if the issuer enables it)

Flipper **cannot**:

- Generate valid transaction cryptograms (requires the card's secure element)
- Be used to make payments
- Skim live transactions (the data captured isn't a full payment authorization)

EMV reads are mostly informational. Don't expect "tap-to-pay" emulation — that's not how EMV works.

## Mifare Fuzzer

Built into Momentum — `/mifare_fuzzer/` on the SD card holds the fuzzing dictionaries. From the NFC menu, attack a Mifare Classic with the fuzzer if dictionary attack fails. It walks through known weak keys + brute-force ranges. Slow (hours to days) and noisy.

## Hardware comparison

| Task | Flipper Zero | Proxmark3 RDV4 |
|---|---|---|
| Read/emulate Mifare Classic | ✅ good | ✅ better (more attacks) |
| Read NTAG | ✅ | ✅ |
| Sniff card↔reader transactions | weak | ✅ (purpose-built) |
| Crack DESFire / SmartMX | ❌ | ❌ (no public crypto break) |
| iCLASS / SEOS | ✅ basic | ✅ (full attack chain) |
| MFKey32 (recover keys from sniffed nonces) | possible with apps | ✅ (built-in) |

For serious NFC research, **Proxmark3 RDV4** is the better tool. Flipper's HF capabilities are good but the antenna is small and the API is a subset of what Proxmark exposes.

## Useful apps

In the Momentum-curated app catalog (already on SD card under `/apps/NFC/`):

- `nfc_magic` — write to "magic" Chinese-clone cards (UID-changeable Mifare)
- `metroflip` — transit card decoder (multiple regions)
- `picopass` — iCLASS / Picopass attack
- `seader` — iCLASS Elite / SEOS reader credentials extractor
- `iso14443a_emulator` — generic emulation of recorded cards
