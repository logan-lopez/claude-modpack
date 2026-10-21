# Briefs

Each brief is a self-contained handoff for a fresh session. New ones go here, numbered in order,
and move to `archive/` when they're done. Ideas that aren't scheduled yet are in
[`FUTURE.md`](FUTURE.md).

## Where things stand

*Updated 2026-10-20.*

- Built: the packwiz pack in `pack/` on NeoForge 21.1.264, 294 entries: about 200 mods from
  Logan's old 1.20.1 pack, 1.21.1 stand-ins and new picks (brief 03), four TaCZ gun packs with
  their addons (brief 04), backups, pregeneration and sound physics (brief 05), and Better Combat
  with Combat Roll (brief 06). The main mod list is frozen. A headless server check and a
  `.mrpack` export back it up. Logan plays it in Prism, synced from `packwiz serve`, and has
  checked every brief's hand checks so far.
- In flight: nothing yet. [Brief 07](07-recipe-fixes-and-ad-astra-on-create.md) is open: the
  first part of integrations, and the first files the pack ships besides mods.
- Next: the reviews of briefs 07 and 08, then [brief 09](09-ftb-quests.md): FTB Quests, a
  sample chapter, and a server check that fails on a broken quest file, so minecraft-mcp can
  write quests into `pack/` next. The rest of integrations and default settings stays in
  [`FUTURE.md`](FUTURE.md); keybinds wait for Logan to find the conflicts in play. The melee
  parity pass waits for Logan to play with Better Combat and guns, and may fold into it.
- Loose ends waiting on Logan:
  - Shaders on a moving Create contraption, and Controlling's keybind conflicts, haven't been
    checked yet (the second feeds the integrations brief).
  - Endless Ammo Refabricated came out at this wrap, but the gun pack it wrote stays in the Prism
    instance's `minecraft/tacz/endlessammo/` until it's deleted by hand. packwiz didn't install
    that folder, so it won't remove it.
  - Whether melee now feels like a real choice next to guns: brief 06's last hand check, and the
    input the melee parity pass needs.
- Other loose ends: the server check binds Minecraft's default port 25565, so a local server
  already on it would get in the way (not seen yet); shellcheck isn't installed, so neither script
  has had a pass.

## Open

1. [`07-recipe-fixes-and-ad-astra-on-create.md`](07-recipe-fixes-and-ad-astra-on-create.md) (M, done, awaiting review):
   a known-errors baseline in the server check, repairs for recipes that fail to load (Almost
   Unified's Silent Gems crushing, Create Compressed, Create Deco's placard), Create pressing and
   crushing for Ad Astra's desh, ostrum and calorite, and a shorter rocket fuel list.
2. [`08-server-build.md`](08-server-build.md) (M, done, awaiting review):
   `scripts/server-pack.sh` writes a server zip that starts on macOS or Windows with `start.sh`
   or `start.bat`, asks about the EULA, keeps its settings across updates and restarts after a
   crash.
3. [`09-ftb-quests.md`](09-ftb-quests.md): FTB Quests and XMod Compat, a hand-written sample
   chapter in `pack/config/ftbquests/quests/`, the server check failing on quest files that don't
   load as written, `scripts/pull-quests.sh` for in-game edits, and the quests page that
   minecraft-mcp generates against.

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

3. [`03-replacements-and-new-mods.md`](archive/03-replacements-and-new-mods.md) (sized S, was
   M): 26 entries, 1.21.1 stand-ins for old mods (Alex's Mobs Continued, LambDynamicLights and
   others), Sodium Extra and Reese's pinned to fit Sodium 0.8.12, and new picks (Cataclysm,
   Mowzie's, TFMG and more). The first client-side rule check.
4. [`04-tacz-gun-packs-and-addons.md`](archive/04-tacz-gun-packs-and-addons.md) (sized M, was
   M): the Elite X and Fallout gun packs, Create Armorer converted from `pack/tacz/`, TaCZ Addon,
   Turrets, Structure Loot, Durability and Curios for Ammo Box, and the guide page on guns.
5. [`05-backups-pregen-and-sound.md`](archive/05-backups-pregen-and-sound.md) (sized S, was M):
   Simple Backups, Chunky and Sound Physics Remastered, the last mods before the freeze, and the
   guide's "Looking after a world".
6. [`06-better-combat-trial.md`](archive/06-better-combat-trial.md) (sized S, was M): Better
   Combat, Combat Roll, Apothic Combat and Cloth Config, trialled on a branch and merged on Logan's
   go, and the guide page on melee. Found that Apothic Combat on 1.21.1 only tidies tooltips.

**The mod list is settled.** With 03 to 06, what the pack plays with is in and frozen. What's
left is making it work together: keybinds, configs, recipes, and balancing melee against guns.

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
| Mods considered and turned down | Friends & Foes, The Twilight Forest, Create Aeronautics; Polymorph noted in [`FUTURE.md`](FUTURE.md). Better Combat, turned down for brief 03, came back through brief 06's trial and is in | Logan's picks from brief 03's suggestion list (2026-10-19). |
| The main mod list | Frozen since brief 05, with brief 06's Better Combat set on top. Endless Ammo Refabricated came out at the 2026-10-19 wrap | Logan wanted the list settled before a world he means to keep; Better Combat adds no blocks, so it can come in or out of a running world (2026-10-19). |
| The last additions | Simple Backups (on its defaults, no shipped config), Chunky, Sound Physics Remastered (an alpha build, accepted) | From an ideate run on what's missing (Logan, 2026-10-19). |
| Melee | Better Combat, Cloth Config, Combat Roll and Apothic Combat, on their defaults. Apothic Combat stays although its 1.21.1 build only tidies tooltips. Balancing melee against guns waits for the melee parity pass. Was: a trial on branch `better-combat-trial`, with Apothic Combat accepted for a heavy-weapon link and a disabled attack-range affix, which turned out to be its 1.20.1 build's behavior (brief 06) | Logan's go after his hand checks; Apothic Combat kept as harmless (2026-10-19). The kill rule stays: anything that gets in the way of TaCZ's aiming or firing is out. |
| Not picked from the 2026-10-19 ideate run | Epic Fight, Distant Horizons, a mob-difficulty mod, AE2 or Refined Storage, Don't Punch My TACZ | Proposed against, and Logan picked around them. Epic Fight takes over the player model TaCZ draws on; Distant Horizons doesn't fit an 8 GB client; Apotheosis, Cataclysm and Mowzie's already make fights harder; Create, Tom's, LaserIO and Sophisticated cover storage; Don't Punch My TACZ patches Punchy, which isn't in (ideate run, 2026-10-19). |
| TaCZ gun packs | Elite X Quality Guns and the unofficial TaCZ Fallout port, both native 1.21.1. Create Armorer is the only 1.20.1 pack, converted by TaCZ Pack Upgrader from `pack/tacz/`. Maxstuff, Gucci & Vuitton and Fiber's stay out | Logan, 2026-10-19 (brief 04). |
| Gun crafting | The gunsmith table keeps its recipes. Create crafting through Immersive TaCZ is an extra route, not a gate | Logan, 2026-10-19 (brief 04). |
| TaCZ addons | TaCZ Tweaks, Apotheosis Modern Ragnarok, Immersive TaCZ, TaCZ Durability, TaCZ Addon, TACZ Turrets, TaCZ Structure Loot, Curios for Ammo Box. Shod's Create and TacZ Bridge, ArcaneMag and Automagic TACZ Automation were turned down. Endless Ammo Refabricated came out at the 2026-10-19 wrap | Logan, 2026-10-19 (brief 04). Endless Ammo: no gun in the pack fires its calibers (Logan, 2026-10-19). |
| CurseForge mods that block third-party downloads | Left out | packwiz-installer can't fetch them, so they break the server check and Prism's auto-sync (FTB Ultimine Addition, brief 02, 2026-10-19). |
| How the server check fails | On NeoForge's mod-loading log lines, a crash report, an exit before Done, or a timeout. Never on the exit code, and not on ERROR lines after a pass | NeoForge 21.1.264 exits 0 after a mod-loading failure, and big packs log harmless errors. Evidence in [the server check page](../architecture/server-check.md#decisions) (2026-10-19). |
| The server check's load errors | A committed baseline of known recipe, loot-table, data-file, data-map and advancement IDs; on a pass the summary lists new and gone ones. New ones never fail the check | Logan, 2026-10-19 (brief 07). A pass keeps meaning "it booted". |
| Rocket fuel | `ad_astra:fuel` is Ad Astra's fuel and cryo fuel plus `#c:diesel`, `#c:biodiesel`, `#c:gasoline` and `#c:kerosene`. `#c:fuel` is out | Through `#c:fuel`, TFMG's byproduct gases and creosote filled rockets (Logan, 2026-10-19, brief 07). |
| Integrations, first pass | Fix recipes that fail to load, then bridge Ad Astra's metals to Create. Keybinds wait for play | Logan, 2026-10-19 (ideate run, brief 07). |
| Quests | FTB Quests and FTB XMod Compat, from CurseForge (neither is on Modrinth). Was parked until there was a quest brief | Logan, 2026-10-20 (brief 09). minecraft-mcp drafts the chapters. |
| Who owns the quest book | `pack/config/ftbquests/quests/` is the source of truth. In-game editor changes come back through `scripts/pull-quests.sh` and a commit | Logan, 2026-10-20 (brief 09). A generator writes there, and the editor is still the easy way to lay quests out. |
| Quest files in the server check | A quest file that doesn't load as written fails the check. The known-errors baseline still only reports | Logan, 2026-10-20 (brief 09). Quest files are the pack's own, and FTB Quests skips a broken chapter and still reaches Done. |
| The server build | A self-contained zip from `scripts/server-pack.sh`: the server-side mods inside, NeoForge's installer run on first start, Java 21 required rather than bundled, the EULA asked on first start. Defaults a fresh server gets: `allow-flight=true`, `difficulty=hard`, `-Xmx12G`, and a restart after a crash | Logan, 2026-10-19 (brief 08). Mojang's server jar can't be shipped, and there's no hosted pack to sync from. |

## Not built

What's deliberately absent, so nobody flags it as missing. Point at `FUTURE.md` where it applies.

- **Client-side checks.** Nothing automated launches a client. Rendering, keybinds and how the
  guns feel are Logan's hand checks.
- **Hosting the pack.** `packwiz serve` on localhost is the only source for the auto-sync
  instance; sharing a build means sending the `.mrpack`.
- **More TaCZ gun packs.** The pack has the port's default, Elite X, Fallout and Create Armorer.
  Converted 1.20.1 packs other than Create Armorer stay out.
- **Configs, recipes and default settings.** Every mod runs on its own defaults, and no KubeJS
  scripts exist yet; brief 07 ships the first. See [`FUTURE.md`](FUTURE.md), Integrations.
- **Quests.** No quest book yet. [Brief 09](09-ftb-quests.md) adds FTB Quests and a sample
  chapter; real chapters are minecraft-mcp's next plan.

## Future direction new work must not block

Each item is cheap to keep possible now and expensive to retrofit later.

- **Hosting `pack/` at a public URL** (GitHub Pages, say) so the auto-sync instance works away
  from this machine. Keep everything the pack needs inside `pack/`, referenced by relative path.
