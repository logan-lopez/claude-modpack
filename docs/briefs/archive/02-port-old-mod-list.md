# Brief 02: Bring over the old pack's mods

**Size:** L. Around 200 mods from two sources, added in batches, each batch ending in a server
check, with addon conflicts nobody here has run yet.

Read `CLAUDE.md`, [`README.md`](../README.md), [the server check page](../../architecture/server-check.md)
and [`FUTURE.md`](../FUTURE.md)'s "Create addons and the rest of the mod list" first. Brief 01 must
have landed (it has: `9a5e553`).

## Goal

Logan's last pack was a 1.20.1 Forge Create pack. Its mod list is in
[`assets/02/old-modlist.txt`](../assets/02/old-modlist.txt). This pack is a fresh start, not a port:
no worlds come over. But it should match the old one in the main things: Apotheosis, the Create
addons, the storage, magic, worldgen, building and quality-of-life mods he played with.

This brief adds every mod from the old list that has a NeoForge 1.21.1 build and that Logan wants
(the lists below are already filtered), with each batch passing the server check. It also writes a
guide page listing what's in the pack and what was left behind and why, so Logan can compare it
with the old list and ask for additions in a later brief.

## Decisions already made

Decided with Logan, 2026-10-19. Don't revisit silently.

- **Fresh start.** The old list is a guide to what Logan likes, not something to reproduce jar
  for jar. Libraries aren't added by hand: they come in as dependencies.
- **MineColonies is out,** with its addons (Jade Colonies, Town Talk, Colony Curios) and its
  libraries (Structurize, Domum Ornamentum, BlockUI, Multi-Piston).
- **Create: Steam 'n' Rails comes from the community port,** Modrinth
  `create-steam-n-rails-1.21.1`. Official Steam 'n' Rails stops at 1.20.1. Same risk as the TaCZ
  port, which Logan already accepted.
- **Renderer: Sodium + Iris,** replacing the old Embeddium + Oculus. Oculus has no 1.21.1 build.
- **Ad Astra is in,** with the Giselle addon, without its Create integrations (they have no 1.21.1
  build). KubeJS can bridge recipes later.
- **The lists in Shape are the scope.** Anything on the old list that isn't in them is either
  left behind (with a reason, in the table at the end of Shape) or a library.

## Already checked

All 2026-10-19, against the Modrinth v2 API (`/project/<slug>/version?loaders=["neoforge"]&game_versions=["1.21.1"]`)
unless it says otherwise.

- **Every Modrinth slug in Shape** has at least one NeoForge 1.21.1 version. Slugs found by search
  rather than guessed were checked against the old pack's jars: the old jar's mod ID (from its
  `META-INF/mods.toml`, in `~/Documents/curseforge/minecraft/Instances/All Create Forge 1.20 (1)/mods/`)
  appears in the new jar's `neoforge.mods.toml`. Two search hits failed that and are not used:
  `createrecycled` (the old "Create Recycle" is mod ID `create_crush_everything`) and
  `traveler-tool-belt` (not gigaherz's Tool Belt).
- **Every CurseForge slug in Shape** resolved to a NeoForge 1.21.1 file through
  `packwiz -y curseforge add https://www.curseforge.com/minecraft/mc-mods/<slug>` in a scratch
  pack initialised like `pack/` (MC 1.21.1, NeoForge 21.1.264). The ATM10 instance on this
  machine (NeoForge 1.21.1) also ships the FTB mods, Building Gadgets 2, LaserIO, CTM, Tool Belt,
  Spice of Life and Ars Elemental. packwiz refused the mods it had no 1.21.1 NeoForge file for
  ("mod not available for the configured Minecraft version(s) … or loader"), so it won't pick a
  wrong-version file by accident.
- **packwiz mixes sources badly.** In the scratch pack, adding a CurseForge mod whose dependency
  was already in from Modrinth **overwrote** the Modrinth `.pw.toml` with a CurseForge one of the
  same name (`placebo`, `apothic-enchanting`, `ars-nouveau`). And CurseForge's Apotheosis Modern
  Ragnarok pulled in CurseForge's copy of the TaCZ port as `tacz-1-21-1.pw.toml`, beside the
  pack's Modrinth `tacz-1.21.1.pw.toml`: same jar filename
  (`tacz-neoforge-1.21.1-1.1.8-hotfix-r7.jar`), so two entries for one mod. It also pulled
  `gunsmith-lib` (CurseForge only, `gunsmithlib-neoforge-1.21.1-tacz1.1.8-6.4.5.jar`), which it
  needs. See Build order for how to handle this.
- **Apotheosis** `1.21.1-8.9.0` requires Placebo, Patchouli, Apothic Attributes, Apothic Spawners
  and Apothic Enchanting. packwiz adds them as dependencies. The old pack's enchanting and
  spawner modules are those two mods now.
- **TaCZ Tweaks** `3.0.0-alpha.10+1.21.1-neoforge` requires `tacz-1.21.1` (the pack's port),
  Kotlin for Forge and YACL.
- **Apotheosis Modern Ragnarok: Zero** (CurseForge `apotheosis-modern-ragnarok`) has
  `apotheosis_modern_ragnarok-neoforge-1.21.1-tacz1.1.8-7.0.1.jar`, built for TaCZ 1.1.8, which is
  what the port is.
- **Steam 'n' Rails port** `0.3.0-beta.2+neoforge-mc1.21.1` (2026-07-27) requires only `create`.
- **Sodium and Iris.** Sodium's 1.21.1 NeoForge line has `mc1.21.1-0.6.13-neoforge` (2025-04-04,
  version ID `Pb3OXVqC`) and then a 0.8 line (`mc1.21.1-0.8.13-neoforge`, 2026-08-28). Iris's
  newest 1.21.1 NeoForge release is `1.8.12+1.21.1-neoforge` (version ID `t3ruzodq`); its
  `neoforge.mods.toml` requires `sodium` `[0.6,)` with the reason "Please install Sodium 0.6",
  and declares Embeddium incompatible. The newer `1.8.14-beta.1` declares Minecraft
  `[1.21,1.21.1)` and no Sodium dependency at all. Pin the pair that was built together: Sodium
  0.6.13 and Iris 1.8.12. (Iris 1.8.12 also declares Minecraft `[1.21,1.21.1)`, yet ATM10 ships it
  on 1.21.1. Both are client-only, so the server check never loads them: Logan's hand check
  decides.)
- **Sodium add-ons** (Extras, Options API, Dynamic Lights, Options Mod Compat) last had 1.21.1
  NeoForge builds in early 2025, against Sodium 0.6. Sodium Options API's `neoforge.mods.toml`
  requires `reeses_sodium_options`, which Modrinth doesn't list as a dependency; Reese's newest
  1.21.1 build is from 2026-09, likely against Sodium 0.8. See Open questions.

## Open questions

Each with the default to use if Logan doesn't answer.

- **FTB Quests and FTB XMod Compat.** Both have 1.21.1 builds. A fresh pack has no quest book, so
  Quests would be empty, and XMod Compat is mostly Quests integration. Default: leave both out
  until there's a quest brief. FTB Library and Teams come in anyway as dependencies of Chunks and
  Ultimine.
- **The Sodium add-ons and Chloride.** Their builds predate the Sodium they'd run with, and one
  needs Reese's Sodium Options, whose current build likely targets a different Sodium. A crash
  here shows only on the client. Default: leave them out of this brief, list them as deferred on
  the guide page, and add them in a follow-up once Logan's first launch on plain Sodium + Iris
  works.

## Shape

### How to add

All from `pack/`. packwiz is in `$(go env GOPATH)/bin`.

- **Modrinth:** `packwiz -y modrinth add <slug>`, with the exact slug from the tables. If packwiz
  reports a project name that doesn't match the table, it fell back to a search and picked
  something else: remove it and stop to check.
- **CurseForge:** `packwiz -y curseforge add https://www.curseforge.com/minecraft/mc-mods/<slug>`,
  only for the mods marked CF, and only in the last batch (see Build order).
- **Pinned files:** `packwiz modrinth add sodium --version-id Pb3OXVqC` and
  `packwiz modrinth add iris --version-id t3ruzodq`, then `packwiz pin sodium` and
  `packwiz pin iris` so a later `packwiz update` doesn't move them.
- Accept required dependencies. Never add optional ones unless a table names them.

### The mods

By batch, in build order. CF means CurseForge; everything else is a Modrinth slug.

**1. Apotheosis and friends.** `apotheosis`, `gateways-to-eternity`, `attributefix`,
`max-health-fix`, `enchantment-descriptions`, `tacz-tweaks`. Apotheosis Modern Ragnarok (CF) waits
for batch 10.

**2. Create, the big addons.** `create-steam-n-rails-1.21.1`, `createaddition`,
`create-enchantment-industry`, `create-deco`, `create-big-cannons`, `create-new-age`,
`create-connected`, `copycats`, `create-diesel-generators`, `create-encased`, `create-qol`,
`bellsandwhistles`, `interiors`, `slice-and-dice`, `petrols-parts`, `create-pattern-schematics`,
`create-framed`, `create-goggles`, `create-filters-anywhere`, `create-contraption-terminals`,
`create-ender-link`, `create-ore-excavation`, `create-power-loader`, `create-trading-floor`.

**3. Create, the rest.** `create-central-kitchen`, `create-confectionery`,
`create-stuff-additions`, `create-compressed`, `create-deep-dark`, `create-easy-structures`,
`create-factory`, `create-ironworks`, `create-jetpack`, `create-curios-jetpack`, `createkart`,
`create-let-the-adventure-begin`, `create-mechanical-extruder`, `create-mechanical-spawner`,
`create-misc-and-things`, `create-ranged`, `create-structures-arise`, `create-ultimate-factory`,
`create-waystones-recipes`, `create-winery`, `create-wizardry`, `createaddoncompatibility`,
`create-teleporters`, `create-ultimine`, `create-molten-vents`, `dynamic-village`. Some of these
name other mods (Waystones, Iron's Spells, FTB Ultimine) as dependencies; let packwiz pull them,
or add them here early.

**4. Storage and tech.** `sophisticated-backpacks`, `sophisticated-storage`,
`sophisticated-backpacks-create-integration`, `sophisticated-storage-create-integration`,
`toms-storage`, `enderchests`, `trash-cans`, `cc-tweaked`, `kubejs`, `almostunified`.

**5. Magic and gear.** `ars-nouveau`, `irons-spells-n-spellbooks`, `artifacts`, `relics-mod`,
`reliquary-reincarnations`, `silent-gear`, `silents-gems`, `jewelry`, `time-in-a-bottle-universal`,
`dark-utilities`, `iron-furnaces`, `productivebees`, `aquaculture`, `small-ships`, `ad-astra`,
`ad-astra-giselle-addon`, `akashic-tome`, `morph-o-tool`, `comforts`.

**6. Worldgen.** `biomes-o-plenty`, `terralith`, `deeperdarker`, `when-dungeons-arise`,
`explorify`, `lootr`, and YUNG's: `yungs-better-desert-temples`, `yungs-better-dungeons`,
`yungs-better-end-island`, `yungs-better-jungle-temples`, `yungs-better-mineshafts`,
`yungs-better-nether-fortresses`, `yungs-better-ocean-monuments`, `yungs-better-strongholds`,
`yungs-better-witch-huts`, `yungs-extras`. Boot time grows here; raise `CHECK_TIMEOUT` for the run
rather than the default if it needs it, and say so in the report.

**7. Food.** `farmers-delight`, `cooking-for-blockheads`, `farming-for-blockheads`,
`aquaculture-delight`, `oceans-delight`.

**8. Building and decoration.** Macaw's: `macaws-bridges`, `macaws-doors`,
`macaws-fences-and-walls`, `macaws-furniture`, `macaws-lights-and-lamps`,
`macaws-paths-and-pavings`, `macaws-roofs`, `macaws-stairs`, `macaws-trapdoors`, `macaws-windows`.
And `chipped`, `rechiseled`, `rechiseled-chipped`, `rechiseled-create`, `supplementaries`,
`amendments`, `framedblocks`, `connected-glass`, `additional-lanterns`, `additional-placements`,
`torchmaster`.

**9. Quality of life, client and performance.** `waystones`, `carry-on`, `fallingtree`,
`explorers-compass`, `natures-compass`, `rightclickharvest`, `simple-magnets`, `elevatormod`,
`easy-villagers`, `corail-tombstone`, `inventory-essentials`, `crafting-tweaks`, `mouse-tweaks`,
`trashslot`, `controlling`, `appleskin`, `bridging-mod`, `animal_feeding_trough`,
`anvil-restoration`, `pylons`, `elytra-slot`, `mmmmmmmmmmmm`, `jrftl`, `measurements`,
`pig-pen-cipher`, `leaves-be-gone`, `jei`, `jade`, `jade-addons-forge`,
`just-enough-resources-jer`, `just-enough-professions-jep`, `justenoughbreeding`,
`just-enough-archaeology`, `journeymap`, `legendary-tooltips`, `equipment-compare`,
`durability-tooltip`, `more-overlays-updated`, `transmog`, `visual-workbench`, `ambientsounds`,
`freecam`, `no-chat-reports`, `modernfix`, `ferrite-core`, `immediatelyfast`, `entityculling`,
`badoptimizations`, `noisium`, `fastfurnace`, `fastworkbench`, `fastsuite`, `clumps`,
`servercore`, `spark`, and Sodium and Iris pinned (How to add). Many of these are client-only,
so the server check never installs them; that's expected.

**10. CurseForge.** `apotheosis-modern-ragnarok`, `ars-elemental`, `dank-storage`, `laserio`,
`building-gadgets`, `ctm`, `ftb-chunks-forge`, `ftb-teams-forge`, `ftb-ultimine-forge`,
`ftb-essentials`, `ultimine-addition`, `tool-belt`, `inventory-sorter`,
`clean-swing-through-grass`, `spice-of-life-carrot-edition`, `hyperbox`.

### Left behind

For the guide page. Checked 2026-10-19.

| Old mod | Why |
| --- | --- |
| MineColonies, Jade Colonies, Town Talk, Colony Curios | Logan's call. The addons also have no 1.21.1 build. |
| Alex's Mobs, Alex's Delight | No 1.21.1 build. |
| Create Ad Astra Compat, Create Ad Astra Recipes, Ad Astra: Rocketed | No 1.21.1 build. |
| Apotheotic Additions, Apothic Curios | No 1.21.1 build. |
| Nether's Delight, Delightful, Silent's Delight | No 1.21.1 build. |
| Construction Wand, Curious Lanterns, Spyglass of Curios | No 1.21.1 build. |
| Create TaCZ Automation | No 1.21.1 build. |
| Structure Essentials, Silent Compat, Create Recycle, Additional Lights | Not found for 1.21.1 on either site. |
| LesRaisinsAddon, Create Planetary Tweaks | Built for other modpacks. |
| Embeddium, Oculus | Replaced by Sodium and Iris. |
| AllTheLeaks, Better FPS Distance, Better Compatibility Checker | 1.20.1 fixes, or only useful when publishing a pack. |
| Sodium Extras, Options API, Dynamic Lights, Options Mod Compat, Chloride | Deferred (Open questions). |
| FTB Quests, FTB XMod Compat | Deferred until there's a quest book (Open questions). |
| TaCZ gun packs and addons: Fiber's, Elite X, Maxstuff, Gucci & Vuitton, Fallout, Endless Ammo, Gun Durability | Their own brief ([`FUTURE.md`](../FUTURE.md)). |
| Mods disabled in the old pack (`.jar.disabled`) | Logan had turned them off. |

### Docs

- **`docs/guide/mods.md`** (new): what's in the pack, grouped like the batches, a line per group
  on what it's for rather than a line per mod, then the Left behind table, updated with anything
  this brief dropped. `**Covers:** \`pack/mods/\``. Add it to `docs/guide/README.md`, and a line
  under Features in the root `README.md`.
- **`FUTURE.md`:** mark "Create addons and the rest of the mod list" scheduled for this brief, and
  add a section for the deferred Sodium add-ons if they stay out.
- **The server check page** only if the script changes (it shouldn't need to).

## Out of scope

- TaCZ gun packs, the 1.20.1 pack converter, and TaCZ addons other than TaCZ Tweaks and
  Apotheosis Modern Ragnarok.
- Configs, KubeJS scripts, recipe changes, quests.
- Mods not on the old list. Logan wants to compare first, then add.
- Changing the Create or NeoForge version. If an addon needs a different Create, drop it or take
  an older addon version (Build order), and say so.
- Launching a client.

## Build order

Commit after each batch that passes, staging `pack/` by name, with a message like
`Add batch 3: Create addons, the rest`. That gives a clean point to diff against for the
CurseForge batch, and a short list of suspects when one fails.

1. For each batch 1–9: add the mods, then `scripts/server-check.sh`.
   - **On a failure,** the summary names the mod and the missing or conflicting dependency. If it's
     a missing dependency, add it. If an addon wants a different Create or a mod that isn't on
     1.21.1, try its next-newest 1.21.1 NeoForge version
     (`packwiz modrinth add <slug> --version-id <id>`); if that fails too, `packwiz remove` it.
     A crash with no clear culprit: halve the batch until one mod is left.
   - Every dropped mod gets a line in the report and a row in the guide's Left behind table: what
     failed, and the log line.
2. Batch 10 (CurseForge), after committing batch 9. Add each CF mod one at a time, then run
   `git status --short pack/mods`:
   - Any **modified** `.pw.toml` is a Modrinth entry packwiz overwrote with a CurseForge one:
     `git checkout -- <file>`.
   - A **new** `tacz-1-21-1.pw.toml` is the duplicate TaCZ port: `packwiz remove tacz-1-21-1`
     (check `tacz-1.21.1.pw.toml` is untouched). Keep `gunsmith-lib`.
   - Any other new dependency that's also on Modrinth: remove it and add the Modrinth one.

   Then `packwiz refresh` and the server check.
3. Look for duplicates across the whole pack: no two `.pw.toml` files with the same `filename`.
4. Run the server check twice more on the final pack.
5. Write the guide page and update the docs, then `scripts/export.sh`.

Stop and ask Logan if more than about a fifth of a batch has to be dropped, or if a mod he named
in his request (Apotheosis, the big Create addons) won't load.

## Acceptance

- `scripts/server-check.sh` exits 0 on the final pack, twice in a row. Paste both summaries (mod
  count, boot time) into the report, and the ERROR-line warnings from one of them.
- No duplicates: `grep -h '^filename' pack/mods/*.pw.toml | sort | uniq -d` prints nothing.
- `tacz-1.21.1.pw.toml` still points at Modrinth (`[update.modrinth]`), and there's no
  `tacz-1-21-1.pw.toml`.
- `pack/mods/sodium.pw.toml` and `iris.pw.toml` name `mc1.21.1-0.6.13` and `1.8.12` and are
  pinned (`pin = true`).
- Every mod in Shape's batches is in `pack/mods/` or in the guide's Left behind table with a
  reason.
- `scripts/export.sh` writes the `.mrpack`.
- `python3 -I ~/.claude/skills/brief/scripts/checklinks.py .` reports 0 broken.

**Logan, by hand** (re-sync the Prism instance from `packwiz serve` first):

- The client launches, and the main menu shows the mod count.
- Video Settings show Sodium's menu, and a shader pack loads in Iris. A Create contraption (a
  moving bearing or a train) renders with and without shaders.
- In a new survival world: an Apotheosis affix item shows its tooltip; a gun from TaCZ fires; a
  Waystone works; JEI, Jade and JourneyMap show up.
- Controls: no keybind conflicts you care about (Controlling shows them).
- Compare `docs/guide/mods.md` against the old list and say what to add back or drop.

Then stop. Report, and leave merging to Logan.

## Report

*2026-10-19.*

### Built

- **`pack/`:** 251 entries in `pack/mods/` (from 2): every mod in Shape's batches except FTB
  Ultimine Addition, plus the libraries they pulled in. The server loads 261 mods from 232 jars;
  19 entries are client-only. 234 come from Modrinth, 17 from CurseForge (Shape's 15 kept, plus
  Gunsmith Lib and FTB Library, which aren't on Modrinth). Sodium 0.6.13 (`Pb3OXVqC`) and Iris
  1.8.12 (`t3ruzodq`) are pinned.
- **Commits,** one per batch, each after a passing server check: `af2a251` (1), `fc9fb02` (2),
  `6a4da89` (3), `7d9854e` (4), `f25c017` (5), `eb568d8` (6), `f7d2066` (7), `93c244f` (8),
  `033286f` (9), `020a648` (10). The brief itself went in first as `4adb90e`, since it was
  untracked when the session started.

Per batch, the server check's mod count and boot:

| Batch | Mods loaded | Done | Wall | Fixes |
| --- | --- | --- | --- | --- |
| 1 Apotheosis | 22 | 4.7s | 16s | none |
| 2 Create, big | 55 | 5.2s | 25s | Petrolpark's Library added: `Mod ID: 'petrolpark', Requested by: 'petrolsparts', Expected range: '[1.5.5,1.6.0)', Actual version: '[MISSING]'` |
| 3 Create, rest | 91 | 5.9s | 26s | Balm, Iron's Spells (from batch 5), Iron's Lib, playerAnimator added: Waystones and Create Wizardry need them and Modrinth doesn't list them. Create Ultimine moved to batch 10: `Mod ID: 'ftbultimine', Requested by: 'createultimine'` |
| 4 Storage | 105 | 6.2s | 28s | none |
| 5 Magic | 142 | 6.9s | 35s | none |
| 6 Worldgen | 161 | 14.9s | 47s | none; default timeout was enough |
| 7 Food | 166 | 15.7s | 45s | none |
| 8 Building | 189 | 16.5s | 111s | none |
| 9 QoL | 239 | 15.3s | 41s | none |
| 10 CurseForge | 261 | 15.9s | 43s | see below |

**Batch 10,** as the brief predicted: Apotheosis Modern Ragnarok overwrote six Modrinth entries
(`apotheosis`, `apothic-attributes`, `-enchanting`, `-spawners`, `patchouli`, `placebo`) and
added `tacz-1-21-1.pw.toml`; Ars Elemental overwrote `ars-nouveau`; FTB Chunks overwrote
`architectury-api`. All restored with `git checkout`, the duplicate TaCZ removed, Gunsmith Lib
kept. FTB Library and CoolCatLib came in new; neither is on Modrinth.

### Deviations

- **FTB Ultimine Addition dropped,** with CoolCatLib. Both are excluded from the CurseForge API,
  so packwiz-installer can't download them, for the server or for Prism's auto-sync. The sync log:
  `CoolCatLib: java.lang.Exception: This mod is excluded from the CurseForge API and must be
  downloaded manually.` and the same for `FTB Ultimine Addition`. A different version wouldn't
  help: the exclusion is per project. It's in the guide's Left behind table. One of 16 in the
  batch, under the brief's stop-and-ask line.
- **Create Ultimine** moved from batch 3 to batch 10, since it needs FTB Ultimine (CurseForge).
- **Iron's Spells** went in with batch 3 rather than 5, as the brief allowed.
- **Sodium and Iris pin syntax.** `packwiz modrinth add sodium --version-id Pb3OXVqC` fails with
  "--version-id cannot be used with a separately specified URL/slug/search term". The working
  form is `packwiz -y modrinth add --project-id sodium --version-id Pb3OXVqC`.
- **`CHECK_PORT=8091` for every run.** Logan's `packwiz serve` for Prism held 8080 (PID 60767),
  and the check refuses a busy port. It was left running.
- **`pack/pack.toml` missed from batches 2–9.** Its index hash wasn't staged until the batch 10
  commit, so those intermediate commits need a `packwiz refresh` if checked out. HEAD is
  consistent.
- **The playing guide** gained a paragraph the brief didn't name: the `.mrpack` now carries the
  CurseForge jars inside it (see Docs updated).

### Defaults taken

- **FTB Quests and FTB XMod Compat:** left out until there's a quest brief. In the Left behind
  table.
- **Sodium add-ons and Chloride:** left out, in the Left behind table, and a new `FUTURE.md`
  section.

### Acceptance

- **Server check twice in a row on the final pack:** both PASS.

  ```
  == server check: PASS ==
  NeoForge:  21.1.264 (Minecraft 1.21.1)
  Mods:      261 loaded (incl. minecraft and neoforge), 232 jar(s) in mods/
  Boot:      41s wall, server says Done (15.711s)!
  Warnings:  641 ERROR line(s) in the log (not failing on them):

  == server check: PASS ==
  NeoForge:  21.1.264 (Minecraft 1.21.1)
  Mods:      261 loaded (incl. minecraft and neoforge), 232 jar(s) in mods/
  Boot:      41s wall, server says Done (15.647s)!
  Warnings:  641 ERROR line(s) in the log (not failing on them):
  ```

  The 641 ERROR lines from the second run, grouped (the summary prints only the first 20, all
  `RuntimeDistCleaner` and loot tables):

  | Count | Source | What |
  | --- | --- | --- |
  | 526 | `LootDataType` | Loot tables for blocks of absent compat mods: 492 `railways` (tracks for BYG, TFC, Quark …), 32 `create_connected`, 2 `createdieselgenerators` |
  | 98 | `RecipeManager` | Compat recipes for absent mods (`create_ironworks`, `create_things_and_misc`, `tfmg`, `createdeco:placard` …) |
  | 6 | `RuntimeDistCleaner` | A mod touching a client class on the server; logged and skipped |
  | 4 | `SimpleJsonResourceReloadListener` | `create_ironworks` compat data for Create: Dreams & Desires |
  | 2 | `DataMapLoader` | `reliquary:xp_juice_still` in a fluid data map |
  | 2 | `AdvancementTree` | `dungeons_arise` advancements |
  | 3 | Small Ships | At shutdown, after `Stopping server`: `Cannot call getFullPath() on non-file config null at path smallships-server.toml`, ending in `Uncaught exception in server thread` |

  Also, as WARN: Apotheosis Modern Ragnarok's `brawlers` gem bonuses overlap
  (`Gem Bonus for class apotheosis_modern_ragnarok.all_gun conflicts with existing bonus …`).
- **No duplicates:** `grep -h '^filename' pack/mods/*.pw.toml | sort | uniq -d` prints nothing.
- **TaCZ:** `tacz-1.21.1.pw.toml` has `[update.modrinth]`; no `tacz-1-21-1.pw.toml`.
- **Sodium and Iris:** `sodium-neoforge-0.6.13+mc1.21.1.jar` (version `mc1.21.1-0.6.13`) and
  `iris-neoforge-1.8.12+mc1.21.1.jar`, both `pin = true`.
- **Every Shape mod in the pack or Left behind:** 198 slugs in Shape; 197 have a `.pw.toml`,
  and `ultimine-addition` is in the Left behind table.
- **`scripts/export.sh`:** wrote `dist/claude-modpack-0.1.0.mrpack`, 18 MB, the CurseForge jars
  inside it.
- **`checklinks.py`:** 12 files, 0 broken.

### Size

Sized L, this session M (22 active min, 22 wall, 0 compactions). The outside tools behaved as
the brief's checked facts said, and only two batches failed, each on a missing dependency the log
named.

### Spot checks for Logan

Re-sync the Prism instance from `packwiz serve` (yours is already running on 8080 and serves
`pack/` as it is now), then:

- The client launches, and the main menu shows the mod count.
- Video Settings show Sodium's menu, and a shader pack loads in Iris. A Create contraption (a
  moving bearing or a train) renders with and without shaders.
- In a new survival world: an Apotheosis affix item shows its tooltip; a gun from TaCZ fires; a
  Waystone works; JEI, Jade and JourneyMap show up.
- **Save and Quit to Title** from that world. Small Ships throws on config unload when the server
  stops; on a client that's this moment. If it crashes, Small Ships is the suspect.
- Controls: no keybind conflicts you care about (Controlling shows them).
- Compare `docs/guide/mods.md` against the old list and say what to add back or drop.

### Docs updated

- `docs/guide/mods.md` (new): the pack by group, the Left behind table with Ultimine Addition
  added, and the two rough edges above.
- `docs/guide/README.md` and the root `README.md`: a line for it.
- `docs/guide/playing.md`: the `.mrpack` bundles the CurseForge jars.
- `docs/briefs/FUTURE.md`: a Sodium add-ons section.
- `docs/briefs/README.md`: retagged, and a decision on CurseForge-excluded mods.
- The server check page: unchanged, the script didn't change.

### Follow-ups

- **Small Ships' shutdown exception.** If Save and Quit is fine, it's noise; if not, try an older
  Small Ships build or drop it.
- **`create_ironworks` and `railways` log hundreds of compat errors** on every boot. Harmless, but
  they bury real ERROR lines in the check's summary. A filter in the check for known-noise
  sources would make its warnings useful again.
- **Modrinth's dependency lists are incomplete.** Petrol's Parts, Waystones and Create Wizardry all
  need mods Modrinth doesn't declare. The server check catches it, so no change needed, but a
  future brief shouldn't assume `packwiz add` pulls everything in.
- **Ultimine Addition** could go in as a hand-placed jar if Logan wants it badly enough; packwiz
  can't manage it.

### After Logan's first launch

*2026-10-19.* The client stopped at the loading screen with two errors the server check can't
see, because both rules live only in client-side or client-only mods:

- `Mod petrolpark only supports jei 19.53.0.426 or above, and below 19.57.0.0. Currently, jei is
  19.64.0.455`. Petrolpark's JEI dependency is `side = "CLIENT"`, so the server ignores it. No
  Petrolpark build accepts JEI 19.57+. **Fix:** JEI pinned to `19.56.0.441` (`ZWGz5dZX`), the
  newest inside the range.
- `Mod supplementaries is incompatible with sodium 0 or above, and below 0.8.12-beta.1. Currently,
  sodium is 0.6.13+mc1.21.1`. Every Supplementaries build since 3.7.4 (2026-06-21) declares it.
  The brief's premise was wrong: Iris 1.8.14-beta.1 isn't unpaired, it's the Sodium 0.8 build
  (changelog "Updates to Sodium 0.8"; its 1.21.1 branch compiles against
  `sodium-neoforge-mod:0.8.12-beta.1` and has had no commits since 2026-06-13). **Fix, Logan's
  call:** Sodium `0.8.12` (`S3DUMfBo`) + Iris `1.8.14-beta.1` (`KduFYu4t`), both pinned. The
  decisions table's Renderer row is updated, with the old pair noted.

**Checked before handing back:** the full client mod set, synced with packwiz-installer
`-s client` into a scratch folder, run through a resolver that reads every `neoforge.mods.toml`
(nested jars too) and tests each rule with the same Maven range classes NeoForge uses. Before the
fix it reported exactly Logan's two errors; after, none. It also flags seven mods whose Minecraft
range is `[1.21,1.21.1)` (JEI, Iris, Productive Bees, When Dungeons Arise, both compasses, Clean
Swing). NeoForge loads those on 1.21.1 on both sides anyway, so it doesn't enforce that range as
written; why, I don't know. Server check after the fix: PASS, 261 mods, Done in 18.6s.

**Spot checks change:** the Video Settings check is now Sodium 0.8's menu, and shaders through
Iris 1.8.14-beta.1, a beta.

**Follow-up:** the resolver caught what the server check structurally can't. Folding it into
`scripts/server-check.sh` (a client-side sync plus the rule check) would have caught both errors
before Logan's launch. A brief, not a side change: it changes what the check means.
