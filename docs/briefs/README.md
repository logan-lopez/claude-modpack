# Briefs

Each brief is a self-contained handoff for a fresh session. New ones go here, numbered in order,
and move to `archive/` when they're done. Ideas that aren't scheduled yet are in
[`FUTURE.md`](FUTURE.md).

## Where things stand

*Updated 2026-10-19.*

- Built: the packwiz pack in `pack/` on NeoForge 21.1.264, with about 200 mods from Logan's old
  1.20.1 pack (Create and its addons, the TaCZ port, Apotheosis, storage, magic, worldgen,
  building, quality of life), a headless server check, and a `.mrpack` export. Logan plays it in
  Prism, synced from `packwiz serve`; it loads with 8 GB of memory and the mods work.
- In flight: nothing.
- Next: briefs 03 and 04 are awaiting review. Then brief 05, the last mods before the main list
  freezes (backups, pregeneration, sound physics), then brief 06, a Better Combat trial on its own
  branch that ends in Logan's go or no-go. After that, integrations and default settings, and the
  melee parity pass, which need briefs ([`FUTURE.md`](FUTURE.md)).
- Loose ends waiting on Logan: shaders on a moving Create contraption, and Controlling's keybind
  conflicts, haven't been checked yet (the second feeds the integrations brief).
- Other loose ends: the server check binds Minecraft's default port 25565, so a local server
  already on it would get in the way (not seen yet); shellcheck isn't installed, so neither script
  has had a pass.

## Open

3. [`03-replacements-and-new-mods.md`](03-replacements-and-new-mods.md) (done, awaiting
   review): 1.21.1 stand-ins for the old mods that didn't come over, the Sodium add-ons that fit
   Sodium 0.8.12, and eight suggested mods, in four batches.
4. [`04-tacz-gun-packs-and-addons.md`](04-tacz-gun-packs-and-addons.md) (done, awaiting
   review): Elite X, Fallout, Endless Ammo and Gun Durability back. Create Armorer goes in
   `pack/tacz/` through TaCZ Pack Upgrader. Adds TaCZ Addon, Turrets, Structure Loot and Curios
   for Ammo Box, plus a guide page on where guns come from.
5. [`05-backups-pregen-and-sound.md`](05-backups-pregen-and-sound.md) (done, awaiting
   review): Simple Backups, Chunky and Sound Physics Remastered, the last mods before the main
   list freezes, and a guide section on looking after a world.
6. [`06-better-combat-trial.md`](06-better-combat-trial.md): Better Combat, Combat Roll and
   Apothic Combat on a `better-combat-trial` branch, with the hand checks that decide go or no-go.

## Done

Archived in [`archive/`](archive/). They record what was asked for and why, not how the code works
now. For that, read `CLAUDE.md` and the code.

1. [`01-pack-skeleton-and-server-check.md`](archive/01-pack-skeleton-and-server-check.md) (sized
   L, was S, because the outside tools behaved as the brief's checked facts said): the packwiz
   pack, `scripts/server-check.sh` proven against a real missing-dependency failure, Create and
   the TaCZ port passing it, the `.mrpack` export, and the Prism guide.
2. [`02-port-old-mod-list.md`](archive/02-port-old-mod-list.md) (sized L, was M): 197 of the old
   pack's mods with NeoForge 1.21.1 builds, in ten batches that each passed the server check, the
   guide's mod list with what was left behind, and the fixes for Logan's first launch (JEI and
   Sodium pinned).

**The pack exists.** With 01 and 02, the old pack's ground is covered on 1.21.1 and it plays.
What follows fills the gaps and makes the mods work together.

## Decisions already made

Don't relitigate these. If one turns out to be wrong in practice, stop and say so.

| Decision | Choice | Why |
| --- | --- | --- |
| Minecraft version | 1.21.1 | Most of the mods Logan wants are on it (Logan, 2026-10-19). |
| Mod loader | NeoForge (21.1.x) | Create and its addons, and the TaCZ port, are there (Logan, 2026-10-19). |
| TaCZ | The unofficial NeoForge port, Modrinth `tacz-1.21.1` | Official TaCZ is 1.20.1 Forge only. Logan accepted the community-fork risk (2026-10-19). |
| Pack tooling | packwiz, pack in `pack/`, Modrinth first | Text manifests pinned by hash, which Claude can read and diff; exports `.mrpack` (Logan, 2026-10-19). |
| Client | Prism Launcher with packwiz-installer auto-sync, `.mrpack` import as the fallback | Logan, 2026-10-19. |
| What a session verifies | A headless server boot (`scripts/server-check.sh`); client-side checks are Logan's | Claude can't play the game. A server boot catches crashes and missing dependencies (Logan, 2026-10-19). |
| The old pack | A guide to what Logan likes, not a port: fresh worlds, and only mods with NeoForge 1.21.1 builds. Its list is [`assets/02/old-modlist.txt`](assets/02/old-modlist.txt) | Logan, 2026-10-19. |
| MineColonies | Out, with its addons | Logan, 2026-10-19. |
| Create: Steam 'n' Rails | The community port, Modrinth `create-steam-n-rails-1.21.1` | Official stops at 1.20.1; same risk as the TaCZ port, and a fresh world has little to lose (Logan, 2026-10-19). |
| Renderer | Sodium 0.8.12 + Iris 1.8.14-beta.1, both pinned. Was Sodium 0.6.13 + Iris 1.8.12 until Logan's first launch | Oculus has no 1.21.1 build (Logan chose Sodium + Iris, 2026-10-19). Supplementaries declares itself incompatible with Sodium below 0.8.12-beta.1, and Iris 1.8.14-beta.1 is the Iris built against that Sodium (Logan picked 0.8.12 over the exact beta, 2026-10-19). |
| Ad Astra | In, without its Create integrations | They have no 1.21.1 build; KubeJS can bridge recipes later (Logan, 2026-10-19). |
| JEI | Pinned to 19.56.0.441 | Petrolpark's Library (for Petrol's Parts) accepts only JEI below 19.57, as a client-side rule the server check can't see; newer JEI stops the client at the loading screen (brief 02, 2026-10-19). |
| Alex's Mobs | The community port Alex's Mobs Continued, Modrinth `alexs-mobs-continued` | The official mod stops at 1.20.1; Continued is the active port, the other (`alexs-mobs-1.21.1`) stalled in 2026-01 (Logan, 2026-10-19). |
| Sodium add-ons | Sodium Extra 0.9.3 and Reese's Sodium Options 2.2.3, pinned, plus Chloride; LambDynamicLights for dynamic lights. Sodium Options API, its Mod Compat and Sodium Dynamic Lights stay out | Newer Extra and Reese's need Sodium 0.8.13, and the pack keeps 0.8.12 for Iris. Every Reese's 2.2.x declares Options API incompatible (Logan, 2026-10-19). |
| Mods considered and turned down | Friends & Foes, The Twilight Forest, Create Aeronautics; Polymorph noted in [`FUTURE.md`](FUTURE.md). Better Combat, turned down for brief 03, came back as brief 06's trial | Logan's picks from brief 03's suggestion list (2026-10-19). |
| The main mod list | Freezes after brief 05. Brief 06's Better Combat trial is the one planned addition after it | Logan wanted the list settled before a world he means to keep; Better Combat adds no blocks, so it can come in or out of a running world (2026-10-19). |
| The last additions | Simple Backups (on its defaults, no shipped config), Chunky, Sound Physics Remastered (an alpha build, accepted) | From an ideate run on what's missing (Logan, 2026-10-19). |
| The Better Combat trial | Better Combat, Cloth Config, Combat Roll and Apothic Combat, on branch `better-combat-trial`; merged on go, deleted on no-go. Apothic Combat is in although it disables Apotheosis' attack-range affix. Balancing melee against guns waits for the melee parity pass | Logan, 2026-10-19. The kill rule stays: anything that gets in the way of TaCZ's aiming or firing is out. |
| Not picked from the 2026-10-19 ideate run | Epic Fight, Distant Horizons, a mob-difficulty mod, AE2 or Refined Storage, Don't Punch My TACZ | Proposed against, and Logan picked around them. Epic Fight takes over the player model TaCZ draws on; Distant Horizons doesn't fit an 8 GB client; Apotheosis, Cataclysm and Mowzie's already make fights harder; Create, Tom's, LaserIO and Sophisticated cover storage; Don't Punch My TACZ patches Punchy, which isn't in (ideate run, 2026-10-19). |
| TaCZ gun packs | Elite X Quality Guns and the unofficial TaCZ Fallout port, both native 1.21.1. Create Armorer is the only 1.20.1 pack, converted by TaCZ Pack Upgrader from `pack/tacz/`. Maxstuff, Gucci & Vuitton and Fiber's stay out | Logan, 2026-10-19 (brief 04). |
| Gun crafting | The gunsmith table keeps its recipes. Create crafting through Immersive TaCZ is an extra route, not a gate | Logan, 2026-10-19 (brief 04). |
| TaCZ addons | TaCZ Tweaks, Apotheosis Modern Ragnarok, Immersive TaCZ, Endless Ammo Refabricated, TaCZ Durability, TaCZ Addon, TACZ Turrets, TaCZ Structure Loot, Curios for Ammo Box. Shod's Create and TacZ Bridge, ArcaneMag and Automagic TACZ Automation were turned down | Logan, 2026-10-19 (brief 04). |
| CurseForge mods that block third-party downloads | Left out | packwiz-installer can't fetch them, so they break the server check and Prism's auto-sync (FTB Ultimine Addition, brief 02, 2026-10-19). |
| How the server check fails | On NeoForge's mod-loading log lines, a crash report, an exit before Done, or a timeout. Never on the exit code, and not on ERROR lines after a pass | NeoForge 21.1.264 exits 0 after a mod-loading failure, and big packs log harmless errors. Evidence in [the server check page](../architecture/server-check.md#decisions) (2026-10-19). |

## Not built

What's deliberately absent, so nobody flags it as missing. Point at `FUTURE.md` where it applies.

- **Client-side checks.** Nothing automated launches a client. Rendering, keybinds and how the
  guns feel are Logan's hand checks.
- **Hosting the pack.** `packwiz serve` on localhost is the only source for the auto-sync
  instance; sharing a build means sending the `.mrpack`.
- **TaCZ gun packs past the port's default.** Brief 04 adds them. Converted 1.20.1 packs other
  than Create Armorer stay out.
- **Configs, recipes and default settings.** Every mod runs on its own defaults, and no KubeJS
  scripts exist yet. See [`FUTURE.md`](FUTURE.md), Integrations.
- **Quests.** No quest book, so FTB Quests is out ([`FUTURE.md`](FUTURE.md), Parked).

## Future direction new work must not block

Each item is cheap to keep possible now and expensive to retrofit later.

- **Hosting `pack/` at a public URL** (GitHub Pages, say) so the auto-sync instance works away
  from this machine. Keep everything the pack needs inside `pack/`, referenced by relative path.
