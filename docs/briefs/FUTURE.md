# Future

Unscheduled work. Each section has enough in it to become a brief; a section that gets scheduled
gains a line pointing at its brief.

## Replacements for what didn't come over, and new mods

**Scheduled:** [brief 03](03-replacements-and-new-mods.md), with Logan's picks (2026-10-19).

Brief 02 left a dozen of the old pack's mods behind for want of a 1.21.1 build (the Left behind
table in [the mod list](../guide/mods.md#left-behind)). Logan wants the pack filled back out: a
1.21.1 NeoForge mod for each role that went missing, plus mods Claude suggests that fit what the
pack is already about.

- **The question:** for each role left behind, which mod fills it on NeoForge 1.21.1, and what
  else is worth adding.
- **The roles, from the Left behind table:** wildlife (Alex's Mobs and Alex's Delight), more
  Farmer's Delight content (Nether's Delight, Delightful, Silent's Delight), a building wand
  (Construction Wand), Curios slots for lanterns and the spyglass, Apotheosis add-ons
  (Apotheotic Additions, Apothic Curios), Create × Ad Astra recipes (Create Ad Astra Compat and
  Recipes, Rocketed), and Create TaCZ Automation. Some of these may now be a config or a KubeJS
  recipe rather than a mod; the next section covers those.
- **Also ready:** the Sodium add-ons (next-but-one section). They waited for a working first
  launch on plain Sodium + Iris, and that's done (Logan, 2026-10-19). They fit this brief.
- **Suggestions** should be pitched against the pack: Create and its addons, TaCZ, Apotheosis,
  magic, exploration. Each with a line on why it fits and what it overlaps with already in.
  Probably a Parley review round before anything is added: Logan picks.
- **What adding mods taught brief 02** (its report):
  - Modrinth's dependency lists are incomplete. Petrol's Parts, Waystones and Create Wizardry all
    needed mods Modrinth doesn't declare. The server check names what's missing.
  - The server check can't see a client-side rule (`side = "CLIENT"` dependencies, client-only
    mods). Both of Logan's first-launch errors were these. Until the server check covers it (see
    below), check each new mod's `neoforge.mods.toml` ranges against JEI 19.56 and Sodium 0.8.12,
    which are pinned.
  - `packwiz curseforge add` overwrites a Modrinth `.pw.toml` of the same name with a CurseForge
    one, and can add a second copy of a mod already in from Modrinth. `git status --short
    pack/mods` after each CurseForge add, and restore what changed.
  - CurseForge mods whose authors block third-party downloads can't go in (the decisions table).
- **Likely shape:** research and a pick list first, then batches with a server check each, as in
  brief 02. Client-only additions each need Logan's launch.
- **Kill criteria:** a role with no good 1.21.1 mod stays empty; say so in the guide.

## Integrations and default settings

**After the replacements.** Logan, 2026-10-19.

The pack is mods with their default configs. This brief makes them work together and sets
defaults a new instance starts with.

- **The question:** which cross-mod gaps are worth bridging, and which defaults a fresh instance
  should ship.
- **Known candidates:**
  - KubeJS recipes for Ad Astra's materials through Create (the Create Ad Astra mods have no
    1.21.1 build; decisions table).
  - Almost Unified's config, so the pack's many ore and ingot sources collapse to one item each.
  - Keybind conflicts: Logan hasn't been through Controlling's list yet. A default `options.txt`
    (or a keybind config mod) could ship the resolved set.
  - Client defaults: render distance, a shader pack or none, JourneyMap and Jade settings.
- **How defaults ship:** packwiz includes any file under `pack/` that its index lists, so
  `pack/config/` and `pack/defaultconfigs/` go to the instance and the server. Check whether
  packwiz-installer overwrites a file the player has changed before relying on it for
  `options.txt`.
- **Memory** can't be set from the pack: it's Prism's instance setting. The playing guide says
  8 GB.
- **Kill criteria:** none; skip any default Logan has no opinion on.

## Sodium add-ons

The pack moved from Sodium 0.6.13 to 0.8.12 after the first launch (Supplementaries requires
it), so the question below is about Sodium 0.8. The old pack had Sodium Extras (as Embeddium
Extras), Sodium Options API, Sodium Dynamic Lights, Sodium Options Mod Compat and Chloride. The
first launch on plain Sodium + Iris works (Logan, 2026-10-19).

**Scheduled:** [brief 03](03-replacements-and-new-mods.md) takes Sodium Extra 0.9.3, Reese's
2.2.3 and Chloride, and leaves Options API, Mod Compat and Sodium Dynamic Lights out: every
Reese's 2.2.x declares Options API incompatible.

- **The question:** which builds of these run with Sodium 0.8.12, and whether Options API's
  undeclared dependency on Reese's Sodium Options has a build that does too. Each add-on's own
  Sodium range is in its `neoforge.mods.toml`; read it before adding.
- **What's known:** each add-on's last 1.21.1 NeoForge build is from early 2025, against Sodium
  0.6, so they may not run on 0.8 at all. Options API's `neoforge.mods.toml` requires
  `reeses_sodium_options`, which Modrinth doesn't list as a dependency; Reese's newest 1.21.1
  build is from 2026-09, likely against Sodium 0.8, which now fits.
- **Likely shape:** add them one at a time with pinned version IDs. The server check never loads
  them (client-only), so each one needs a client launch by Logan.
- **Kill criteria:** any add-on with no build that runs on Sodium 0.8 stays out.

## The server check: client-side rules and log noise

Two changes to `scripts/server-check.sh` from brief 02's report.

- **Client-side rules.** Logan's first launch stopped on two dependency rules the server never
  evaluates: Petrolpark's `side = "CLIENT"` JEI range, and Supplementaries' incompatibility with
  Sodium below 0.8.12-beta.1, a client-only mod. Brief 02's fix session caught both with a
  resolver: sync the client set with packwiz-installer `-s client` into a scratch folder, read
  every `neoforge.mods.toml` (nested jars too), and test each rule with the Maven range classes
  NeoForge uses. Folding that into the check changes what a pass means, so it's a brief, not a
  side change.
- **Known-noise ERROR lines.** Every boot logs about 640 ERROR lines, nearly all loot tables and
  recipes for absent compat mods (`railways` alone is 492, then `create_connected`,
  `create_ironworks`). The summary prints the first 20, so a real error is buried. A filter for
  known-noise sources would make the summary useful again.
- **Also seen:** the resolver flags seven mods whose Minecraft range is `[1.21,1.21.1)` (JEI,
  Iris, Productive Bees, When Dungeons Arise, both compasses, Clean Swing), yet NeoForge loads
  them on 1.21.1. A check built on the resolver has to match NeoForge here, not the range as
  written. Why NeoForge allows it isn't known.
- **Kill criteria:** if the resolver can't match NeoForge's verdicts on the current pack (no
  false failures), keep it as a separate script rather than part of the pass.

## TaCZ gun packs and addons

The old pack had Fiber's Gunspack, Elite X Quality Guns, Maxstuff, Gucci & Vuitton Attachments,
TaCZ Fallout, Endless Ammo, Gun Durability and Create TaCZ Automation. Most are built for 1.20.1,
and the gun packs need the 1.20.1 pack converter. Of those, only Fallout has a 1.21.1 build, an
unofficial port (Modrinth `unofficial-tacz-fallout-gunpack`, checked 2026-10-19).

- **The question:** which gun packs convert cleanly to the port, and whether the converter is
  something a session can run.
- **Kill criteria:** a pack that needs hand fixes after conversion stays out.

## Better Combat, and combat as a direction

Logan turned Better Combat down for brief 03 but wants it noted as a possible direction to
explore (2026-10-19).

- **The question:** whether melee in this pack should change, given guns (TaCZ), spells (Iron's,
  Ars) and Apotheosis gear are already the main ways to fight.
- **What's known:** Better Combat `2.4.0+1.21.1-neoforge` (Modrinth `better-combat`) needs Cloth
  Config and playerAnimator, both already in. Apothic Combat (`apothic-combat`) bridges it with
  Apotheosis; its last 1.21.1 build is 2025-01-19. How it behaves alongside TaCZ isn't known: a
  mod called "Don't Punch My TACZ" exists to fix punch-animation conflicts around TaCZ, which
  hints that the area is fiddly.
- **Likely shape:** an ideate run on combat first, then a small brief with a world to try it in.
- **Kill criteria:** if it fights TaCZ's aiming or firing, it stays out.

## `packwiz update`

Adding Create and TaCZ, packwiz warned that each one's "latest version number and newest release
date" disagree on Modrinth (Create `mc1.21.1-6.0.9` vs `6.0.10+mc1.21.1`). `add` took the newest
both times. Check what `packwiz update --all` does with them before using it, and check each
updated file's loader and game version (brief 01's report did it through the Modrinth v2 API by
version ID). Sodium, Iris and JEI are pinned, so it leaves them alone.

## Parked

- **Polymorph** (Modrinth `polymorph`, 1.2.0 beta): pick the result when two recipes share a
  crafting grid. Turned down for brief 03, noted for later (Logan, 2026-10-19). Back when a
  recipe conflict shows up in play.
- **FTB Ultimine Addition as a hand-placed jar.** Its author excludes it from the CurseForge API,
  so packwiz can't manage it. Back if Logan wants it enough to keep a jar in the instance by hand.
- **FTB Quests and FTB XMod Compat.** A new pack has no quest book. Back when there's a quest
  brief.
