# Brief 04: TaCZ gun packs, addons and Create Armorer

**Size:** M. A dozen entries that resolved in a dry run, pushed up a step because nobody here has
run TaCZ Pack Upgrader on a 1.20.1 gun pack.

Read `CLAUDE.md`, [`README.md`](README.md), [the server check page](../architecture/server-check.md),
[the mod list](../guide/mods.md) and [`FUTURE.md`](FUTURE.md)'s "TaCZ gun packs and addons" first.
[Brief 03](03-replacements-and-new-mods.md) is the pattern this one follows, the client-side rule
check included. Prerequisite: brief 03's commits (through `b634f39`) are in the branch, since
Create: Immersive TaCZ Integration came in with them. Its review doesn't need to be finished.

## Goal

The old 1.20.1 pack had eight TaCZ gun packs and addons, and none came over. Brief 03 added
Create: Immersive TaCZ Integration, which does nothing without the Create Armorer gun pack. This
brief brings back the four that have 1.21.1 builds. It gets Create Armorer loading through TaCZ
Pack Upgrader, so guns can be crafted through Create, and adds four addons Logan picked. Each
batch passes the server check. A new guide page says where guns come from.

## Decisions already made

Logan made these calls in a Parley round on 2026-10-19. Don't revisit silently.

- **Brought back:** Elite X Quality Guns, TaCZ Fallout (the unofficial port), Endless Ammo
  (Endless Ammo Refabricated) and Gun Durability (TaCZ Durability, the same mod `gundb` at 2.2.2).
- **Left out:** Maxstuff and Gucci & Vuitton Attachments. Both are 1.20.1 jar gun packs that
  would need converting. Fiber's Gunspack is also out: it isn't on Modrinth, and packwiz's
  CurseForge search doesn't find it.
- **Create gun crafting:** Create Armorer goes into `pack/tacz/`, and TaCZ Pack Upgrader converts
  it when the game loads. Immersive TaCZ stays. Automagic TACZ Automation (`tacz-automation`)
  was the alternative, and it isn't added.
- **The gunsmith table keeps its recipes.** Immersive TaCZ's install guide suggests deleting the
  table's recipes for Create Armorer's guns (or for every gun) so guns can only be made through
  Create. This pack doesn't: Create crafting is an extra route, not a gate.
- **New addons:** TaCZ Addon (`taczaddon`), TACZ Turrets (`tacz-turrets`), TaCZ Structure Loot
  (`tacz-structure-loot`) and Curios for Ammo Box (`curios-for-ammo-box`).
- **Turned down:** Shod's Create and TacZ Bridge and ArcaneMag.

## Already checked

All 2026-10-19, against the Modrinth v2 API, CurseForge's files page, and each jar's
`META-INF/neoforge.mods.toml`.

- **Dry run.** In a scratch copy of `pack/`, `packwiz -y modrinth add` for each slug in Shape
  gave 10 new entries in `mods/`: the 9 slugs and TacZ Mesh Loader, which Elite X pulls in. No
  existing `.pw.toml` changed. Create Armorer went in with the command in Shape, as
  `tacz/tacz-create-armorer-koei.pw.toml` (`mode = "metadata:curseforge"`). packwiz gave no
  warning about third-party downloads, but only a real sync proves that.
- **The port** is `tacz` version `1.1.8-hotfix-r7`. Official TaCZ (`timeless-and-classics-zero`)
  is still 1.20.1 Forge only, up to `1.1.8-hotfix2`.
- **TaCZ Pack Upgrader** (`tacz-pack-upgrader` 2.1.3, by MUKSC, who also maintains the port)
  converts 1.20.1 gun packs placed in the `tacz/` folder when the game loads, both zips and
  "`.jar` gun packs". It can't convert 1.20.1 mod addons. Modrinth marks it optional on both
  sides. packwiz sets `side = "both"` and warns about it. Keep `both`, because the server has to
  convert Create Armorer too.
- **Create Armorer** is CurseForge project 1092101 (`tacz-create-armorer-koei`, by Koei). It has
  only 1.20.1 files. The newest is file 7598625, `Create Armorer-v1.2.0.1-for117.zip`
  (2026-02-09), and the next-older is 6849855, `Create Armorer-v1.2.0hotfix-for115.zip`. Without
  `--file-id`, packwiz refuses it on version and loader, which is why brief 03 found "no file".
  Immersive TaCZ 1.6 logs `Create Armorer is not installed, please download it and place it in
  the /tacz folder` when it's missing (brief 03's report).
- **Each pick against the pack:**
  - Elite X Quality Guns 6.0 (`elitex`): NeoForge `[21.1.259,)`, the pack has 21.1.264. Its gun
    pack is inside the jar (`assets/elitex/custom/`). On Modrinth it requires TacZ Mesh Loader,
    which packwiz pulls.
  - TacZ Mesh Loader 0.1.8: client-only (Modrinth `server_side: unsupported`, so packwiz sets
    `side = "client"`). Its `tacz` dependency is `side="CLIENT"`, so only the client-side rule
    check can see it.
  - TaCZ Fallout 0.1.1 (`tacz_fallout`): `tacz [1.1.4,)`. Modrinth's environment value
    `server_only_client_optional` is one packwiz doesn't know, so it sets `both`. That's right
    for a gun pack.
  - Endless Ammo Refabricated 2.0.0 (`endlessammo`): `tacz *`. Take the NeoForge file. Its
    Fabric build has the same version number.
  - TaCZ Durability 2.2.2 (`gundb`): needs only NeoForge and Minecraft.
  - TaCZ Addon 1.1.8.3 (`taczaddon`): `tacz` with no range, NeoForge `[21.1.238,)`. Its JEI,
    Sophisticated Backpacks and Curios hooks are optional, and all three are in the pack.
  - TACZ Turrets 3.0.0 (`tacz_turrets`): `tacz [1.1.8-hotfix-r6,)`, GeckoLib `[4.9.3,)` (the pack
    has 4.9.3), and **SmartBrainLib `[1.16.11,)`, which isn't in the pack**. Modrinth lists only
    `tacz` and Architectury as its dependencies, so packwiz won't pull SmartBrainLib. Add
    `smartbrainlib` yourself: 1.16.11 is on Modrinth for NeoForge 1.21.1.
  - Curios for Ammo Box 1.2.0: needs only NeoForge and Minecraft. The pack has Curios 9.5.1.
  - TaCZ Structure Loot `2.0.0+mod`: a datapack in a jar that Modrinth generated
    (`mr_tacz_structureloot`). It **replaces 62 vanilla chest loot tables outright**
    (`data/minecraft/loot_table/chests/*.json`, each a full table with TaCZ pools added) and two
    Lost Cities tables. Every gun, ammo and attachment it names is from the default `tacz` pack.
- **Not taken, for the record:** Automagic TACZ Automation 1.0.0 (Create `[6.0.8,)`, `tacz
  [1.1.8,)`, 181 downloads). Create: Immersive Armorer Integration needs Immersive Engineering,
  which isn't in the pack. TaCZ:Accel (`tacza`) requires official TaCZ.

## Open questions

- **Structure Loot against other loot tables.** Its full-table replacements win or lose against
  any other mod that ships the same `data/minecraft/loot_table/chests/` paths, depending on load
  order. Default: list the clashes (Shape, The checks). Keep the mod unless a clash drops loot
  from a mod Logan cares about (Apotheosis, Lootr's own behavior). Otherwise report it and leave
  it in for Logan to decide.
- **Endless Ammo Refabricated** describes itself as an "ammo library for TACZ" that adds ammo
  types. The old mod's job may have been different. Default: add it, and in the report say what
  it adds (its items in JEI), so Logan can judge whether it's the same thing.

## Shape

### How to add

From `pack/`, as in brief 03: `packwiz -y modrinth add <slug>`. If the project name packwiz
prints doesn't match, it fell back to a search: remove it and stop. Accept required dependencies
only. Create Armorer comes from CurseForge, into `tacz/`:

```sh
packwiz -y curseforge add --addon-id 1092101 --file-id 7598625 --meta-folder tacz
```

If packwiz picks a newer version than Already checked lists for any mod, read that jar's
`neoforge.mods.toml` against the pack before keeping it.

### The mods

By batch, in build order.

1. **Gun packs.** `tacz-pack-upgrader` (2.1.3), `elite-x-quality-guns` (6.0, which brings
   `tacz-mesh-loader` 0.1.8), `unofficial-tacz-fallout-gunpack` (0.1.1).
2. **Create Armorer.** The CurseForge command above. **Pinned:** the file lives at
   `pack/tacz/`, which packwiz-installer writes to `<instance>/tacz/`, the folder TaCZ and the
   Upgrader read. Don't move it to `mods/` or `resourcepacks/`.
3. **Addons.** `tacz-endless-ammo-refabricated` (2.0.0), `tacz-durability` (2.2.2), `taczaddon`
   (1.1.8.3), `tacz-turrets` (3.0.0) with `smartbrainlib` (1.16.11), `tacz-structure-loot`
   (2.0.0+mod), `curios-for-ammo-box` (1.2.0).

### The checks

- **Create Armorer loads on the server.** After batch 2, `run/server/tacz/` has the zip, and
  `run/server/logs/latest.log` no longer has `Create Armorer is not installed`. Find the log
  lines where the Upgrader converts the zip and where TaCZ loads its packs, and quote them in the
  report. If the line is still there:
  1. Look at what the Upgrader wrote, and whether `tacz/` is where the server looks.
  2. Try the next-older file, 6849855.
  3. If it still won't load, stop and ask Logan before going on.
- **Structure Loot clashes.** For each server jar in `run/server/mods/`, list the files under
  `data/minecraft/loot_table/chests/` it shares with Structure Loot. A throwaway script in the
  scratchpad is fine. Report the jars and paths. Then apply the default in Open questions.
- **The client-side rule check,** after batch 3, as brief 03 did it (its Shape, "The client-side
  rule check", with the two fixes from its Deviations: nested jars in `META-INF/jars/` per
  `META-INF/jarjar/metadata.json`, and Maven's `-` sublist ordering). TacZ Mesh Loader is the new
  client-only mod. Expect the seven known `[1.21,1.21.1)` Minecraft ranges and nothing else.

### Docs

- **`docs/guide/guns.md`, new:** where guns come from in this pack, for Logan in game. Cover:
  - the gun packs (the port's default pack, Elite X, Fallout, Create Armorer);
  - the gunsmith table and TaCZ Addon's changes to it;
  - Create crafting through Immersive TaCZ, for Create Armorer's guns only;
  - chest loot (Structure Loot), turrets, and durability and repair (TaCZ Durability);
  - the ammo box in its Curios slot;
  - Apotheosis affixes on guns (Modern Ragnarok, already in);
  - what isn't here: Maxstuff, Gucci & Vuitton, Fiber's.

  Add a line for it in `docs/guide/README.md`.
- **`docs/guide/mods.md`:**
  - Update the counts.
  - Rename "Create and the guns" to name the gun packs and TaCZ addons, or give TaCZ its own
    group.
  - Add SmartBrainLib to the libraries.
  - In Replaced: Create TaCZ Automation's row loses "(Known rough edges)". Add Endless Ammo →
    Endless Ammo Refabricated and Gun Durability → TaCZ Durability 2.2.2.
  - In Left behind: the TaCZ row becomes Fiber's (not found), Maxstuff and Gucci & Vuitton
    (1.20.1, not converted: Logan's call). It also says that Elite X and Fallout came back.
  - In Known rough edges: take out the Immersive TaCZ entry if Create Armorer loads. Add the
    Structure Loot clashes if any were found.
- **`docs/architecture/server-check.md`:** step 4 says the sync installs "the mods". It now
  installs `tacz/` too. Fix the sentence. `scripts/server-check.sh` itself doesn't change.
- **`docs/briefs/FUTURE.md`:** take out "TaCZ gun packs and addons". Leave Better Combat's mention
  of Don't Punch My TACZ as it is.

## Out of scope

- Maxstuff, Gucci & Vuitton, Fiber's, and any converted 1.20.1 gun pack other than Create
  Armorer.
- Removing or gating gunsmith table recipes, and any KubeJS or config change. TaCZ configs stay
  at their defaults. That's the integrations brief.
- Any TaCZ addon not listed above, including Shod's Bridge, ArcaneMag and Better Combat.
- Moving the TaCZ port, Sodium, Iris or JEI off their versions or pins.
- Changing `scripts/server-check.sh`.

## Build order

Commit after each batch that passes. Stage `pack/` by name, including `pack/pack.toml`,
`pack/index.toml` and `pack/tacz/`. Use messages like `Add TaCZ batch 1: gun packs`.

1. For each batch: add the entries, run `scripts/server-check.sh`, then
   `git status --short pack/`. Only new files should show. A modified `.pw.toml` means an
   overwrite: restore it. On a failure, follow brief 02's Build order step 1:
   - add a missing dependency, or
   - try the next-older 1.21.1 NeoForge version, or
   - `packwiz remove` the mod and record why.
2. After batch 2, the Create Armorer check. After batch 3, the Structure Loot clash list and the
   client-side rule check.
3. No duplicates: no second TaCZ port entry (`tacz-1-21-1.pw.toml`, as in brief 02), and no
   `timeless-and-classics-zero.pw.toml`. Run the server check twice more on the final pack.
4. The docs, then `scripts/export.sh`.

`packwiz serve` for Prism may be holding 8080. Use `CHECK_PORT` as briefs 02 and 03 did.

Stop and ask Logan in two cases: Create Armorer won't load (The checks), or more than two picks
have to be dropped.

## Acceptance

- `scripts/server-check.sh` exits 0 on the final pack, twice in a row. Paste both summaries and
  the ERROR-line count. Brief 03's pack logged 675, and Create Armorer's arrival should remove the
  `CreateImmersiveTaCZ` line. Account for the change by source, as brief 03's report did.
- `rg -c 'Create Armorer is not installed' run/server/logs/latest.log` finds nothing.
- `ls run/server/tacz/` shows the Create Armorer zip. The report quotes the log lines showing the
  Upgrader and TaCZ loading it.
- Every slug in Shape has a `.pw.toml` (Create Armorer's in `pack/tacz/`). Any slug without one
  has a line in the report and a row in the guide saying why it was dropped.
- `grep -h '^filename' pack/mods/*.pw.toml pack/tacz/*.pw.toml | sort | uniq -d` prints nothing.
- No `tacz-1-21-1.pw.toml`, `timeless-and-classics-zero.pw.toml` or `fabric-api.pw.toml`
  anywhere under `pack/`.
- `tacz-mesh-loader.pw.toml` has `side = "client"`. `tacz-pack-upgrader.pw.toml` has
  `side = "both"`.
- The client-side rule check flags nothing beyond the seven known Minecraft ranges.
- The report lists the Structure Loot clashes, or says there are none.
- `scripts/export.sh` writes the `.mrpack`.
- `python3 -I ~/.claude/skills/brief/scripts/checklinks.py .` reports 0 broken.

**Logan, by hand.** Re-sync the Prism instance from `packwiz serve` first, and check that
`<instance>/tacz/` has the Create Armorer zip.

- The client launches at 8192 MB. If it doesn't, try more and say what it took.
- At the gunsmith table, Elite X, Fallout and Create Armorer guns all show, and the default pack's
  guns do too. With a gun in hand, the table shows only its attachments and ammo (TaCZ Addon).
- An Elite X gun renders properly in first person. Its models use TacZ Mesh Loader.
- JEI shows Immersive TaCZ's Create recipes for Create Armorer guns (barrel, trigger and firing
  mechanism parts, mechanical crafting).
- A gun loses durability as it fires, and its tooltip shows it (TaCZ Durability).
- An ammo box goes in its Curios slot, and the gun reloads from it.
- A turret can be placed, takes a gun, and fires at a hostile mob.
- In a new world, a vanilla structure chest (a dungeon, a desert pyramid) can hold TaCZ guns,
  ammo or attachments.
- Controlling shows no new keybind conflicts from the TaCZ addons.

Then stop. Report, and leave merging to Logan.
