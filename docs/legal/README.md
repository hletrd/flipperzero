# Legal & Ethics

This repo accumulates **dual-use security research material**. The same Sub-GHz capture that helps you understand your own car's keyless system can be used to attack someone else's. The bare facts of legality differ by jurisdiction; the underlying ethics are clearer.

## What's clearly fine

- Reading, analyzing, and emulating RFID/NFC/iButton keys you own (your gym key, your apartment intercom key, your work badge if your employer authorizes)
- Capturing and analyzing your own remotes (garage opener you bought, car key on your title, TV remote)
- Building/flashing custom firmware on a Flipper Zero you own
- Studying public protocols, decoding captures from your own gear
- Penetration testing under written authorization
- CTF competitions and educational research

## Gray areas

- **Replaying a fixed-code capture against a system you don't own** — even if you legally read the original (e.g., it's your own building you've forgotten the key code for), unauthorized access is unauthorized access
- **Cloning a card you have temporary access to** — borrowing a friend's hotel key card and cloning it without permission is theft of access
- **BLE Spam in public** — technically illegal radio harassment in most jurisdictions; ethically unfriendly even where unenforced
- **Sub-GHz transmissions outside your country's allocated bands** — Flipper hardware can transmit on frequencies that are licensed (cellular, public safety, aviation) — illegal in every country, even if technically possible

## Clearly off-limits

- Cloning another person's keys, fobs, or cards without permission
- Using Sub-GHz captures to unlock vehicles you don't own
- BadUSB attacks against unauthorized targets
- Defeating retail anti-theft devices
- Manipulating gas pump/POS systems
- Anything involving commercial fraud (payment card skimming, transit-card top-up exploits, gambling machine attacks)

## Regulatory snapshots

### Korea (KCC)

- ISM bands: 433.05–434.79 MHz (general use), 920.9–923.3 MHz (industrial), 13.56 MHz (NFC)
- Unlicensed transmission outside ISM is illegal under Article 24 of the Radio Waves Act
- Penalties: up to ₩30,000,000 fine and/or 3 years imprisonment for unauthorized transmissions causing interference
- Possession of Flipper Zero is legal; use against another person's vehicle/property is criminal

### United States (FCC)

- Part 15 unlicensed: 902–928 MHz, 2.4 GHz, 5 GHz, plus narrower allocations at 433 MHz, 315 MHz
- Part 97 (amateur) for licensed operators: wider bands, but rules-bound
- Computer Fraud and Abuse Act (CFAA, 18 USC 1030) covers unauthorized computer access — has been applied to RFID and keyless entry attacks
- Federal Wiretap Act applies to capturing wireless communications you're not party to in some interpretations

### EU / EEA (CE / RED)

- Directive 2014/53/EU (Radio Equipment Directive) sets ISM allocations: 433.05–434.79, 868.0–868.6, 13.56 MHz
- GDPR may apply to RFID data containing personal information
- Per-country implementations vary; UK has Ofcom regulating

### Where there's no specific Flipper Zero law

There is **no anti-Flipper-Zero law** anywhere — the device is general-purpose RF research equipment. Possession, ownership, and personal-research use are universally permitted. What's regulated is **what you do with it**.

## Self-imposed rules for this repo

The owner uses this repo for:

1. **Personal device research** — own car, own access cards, own gear
2. **Learning protocol fundamentals** — capture-analyze-understand cycle
3. **Backup and recovery** — having clones/backups of legitimate keys

The owner does **not** use it for:

- Operating against vehicles or premises they don't own/have authorization to test
- Spreading sketchy attack tooling (e.g., the `s4dic` Discord/password grabber payloads were removed from the deployed SD)
- BLE Spam in public spaces

This material is shared publicly because the same information is widely available, and because a coherent personal knowledge base is useful for others doing legitimate research. **Do not interpret the existence of an attack tool in this repo as endorsement of using it.**

## Disclaimer

The owner is not a lawyer. Local laws vary, evolve, and are interpreted by individual courts. If you intend to operate at the edge of legality, consult a lawyer in your jurisdiction. Don't trust an internet markdown file as legal advice.
