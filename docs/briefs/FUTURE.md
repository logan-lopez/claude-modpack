# Future

Unscheduled work. Each section has enough in it to become a brief; a section that gets scheduled
gains a line pointing at its brief.

## Create addons and the rest of the mod list

**Scheduled:** [brief 02](02-port-old-mod-list.md), from Logan's old pack's list.

Logan wants Create's addons, plus more along the lines of TaCZ (2026-10-19).

- **The question:** which addons and mods have NeoForge 1.21.1 builds, and which of them conflict.
- **Likely shape:** add them in batches with `packwiz modrinth add`, running the server check
  after each batch so a failure has few suspects. Each addon that fails gets one line in the
  report: why, and whether it's dropped or waiting on a fix.
- **packwiz's version picking.** Adding Create and TaCZ, packwiz warned that each one's
  "latest version number and newest release date" disagree on Modrinth (Create
  `mc1.21.1-6.0.9` vs `6.0.10+mc1.21.1`). `add` took the newest both times. Check what
  `packwiz update` does with them before using it, and check each added file's loader and game
  version (brief 01's report did it through the Modrinth v2 API by version ID).
- **TaCZ addons and gun packs** need a separate look. Most are built for 1.20.1, and the gun
  packs need the 1.20.1 pack converter. The old pack had Fiber's Gunspack, Elite X Quality Guns,
  Maxstuff, Gucci & Vuitton Attachments, TaCZ Fallout, Endless Ammo, Gun Durability and Create
  TaCZ Automation. Of those, only Fallout has a 1.21.1 build, an unofficial port (Modrinth
  `unofficial-tacz-fallout-gunpack`, checked 2026-10-19).
- **Kill criteria:** none. This is the pack itself.

## Parked
