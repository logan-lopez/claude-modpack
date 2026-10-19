# Brief 05: World backups, pregeneration and sound physics

**Size:** S. Three mods that resolved in a dry run and booted together in a scratch copy of the pack.

Read `CLAUDE.md`, [`README.md`](README.md), [the server check page](../architecture/server-check.md),
[the mod list](../guide/mods.md) and [the playing guide](../guide/playing.md) first.
[Brief 03](03-replacements-and-new-mods.md) is the pattern this one follows, including the
client-side rule check. Prerequisite: brief 04's commits (through `d2ddd96`) are in the branch. Its
review doesn't need to be finished.

## Goal

These are the last mods before the main list freezes. Once it does, a world Logan means to keep
comes next, and that world runs on two community forks (the TaCZ port, Steam 'n' Rails) and two
beta mods (Dreams & Desires, End's Delight). packwiz's pins protect the mod list, not the saves.
Simple Backups takes timed backups of the world. Chunky pregenerates terrain, because Terralith,
Biomes O' Plenty and the structure mods make new chunks slow, and flying or riding a train into
fresh ground stutters. Sound Physics Remastered adds echo and muffling from the space around a
sound. It's the one feature gap from the ideate run that's about the guns: a rifle in a mineshaft
should sound like it's in one.

The three mods add no blocks or items, so any of them can come out of a world later without harm.

## Decisions already made

Logan made these calls on 2026-10-19 (an ideate run, then a Parley round). Don't revisit silently.

- **The three mods:** Simple Backups (`simple-backups`), Chunky (`chunky`), Sound Physics
  Remastered (`sound-physics-remastered`).
- **Before the combat trial.** This is brief 05 and the Better Combat trial is
  [brief 06](06-better-combat-trial.md), because these mods are the last content before the freeze.
  Better Combat adds no blocks, so it can be decided afterwards.
- **Simple Backups runs on its defaults.** Don't ship a config. Read the defaults from the
  generated config and put them in the guide and the report. Changing them is the integrations
  brief's job ([`FUTURE.md`](FUTURE.md), Integrations and default settings).
- **Sound Physics is accepted as an alpha.** Its only NeoForge 1.21.1 build is tagged alpha. If
  it costs too much frame time, it comes out (Logan's hand check).

## Already checked

All 2026-10-19, against the Modrinth v2 API and each jar's `META-INF/neoforge.mods.toml`.

- **Dry run.** In a scratch copy of `pack/`, `packwiz -y modrinth add` with each slug gave three
  new entries and pulled no dependencies:
  - `simple-backups` 1.21-4.0.30 (`SimpleBackups-1.21-4.0.30.jar`, tagged beta, 2026-04-22)
  - `chunky` 1.4.23 (`Chunky-NeoForge-1.4.23.jar`, 2025-04-04)
  - `sound-physics-remastered` neoforge-1.21.1-1.5.1
    (`sound-physics-remastered-neoforge-1.21.1-1.5.1.jar`, tagged alpha, 2025-09-25)

  packwiz set `side = "both"` on all three. For Sound Physics it warned that Modrinth's
  environment value `client_only_server_optional` is one it doesn't know.
- **Dependencies:**
  - Simple Backups needs NeoForge `[21.1.115,)` and Minecraft `[1.21.1,)`.
  - Chunky needs NeoForge `[21.0-beta,)` and Minecraft `[1.21,1.22)`.
  - Sound Physics needs NeoForge `[21.0.0-beta,)` and Minecraft `[1.21,1.21.1]`. Cloth Config
    (`[15.0.127,)`) and Simple Voice Chat are optional. Neither is in the pack, so it has no
    settings screen in game, only its config file.
  - None of the three names JEI, Sodium or Iris, so the pins are safe.
- **The scratch boot.** `scripts/server-check.sh`, copied into a scratch root, was run against
  that scratch copy with these three and brief 06's four, all `side = "both"`. It **passed**: 271
  jars, 299 mods loaded, Done in 21 s, 678 ERROR lines against brief 04's 675. The three new lines:
  - `Attempted to load class net/minecraft/client/sounds/SoundEngine for invalid dist
    DEDICATED_SERVER`. That's TaCZ Tweaks' `feature.sound_physics_evaluate.SoundEngineMixin`
    (logged as a WARN just before it) reaching for a client class because Sound Physics was on the
    server. With `side = "client"` it should go away.
  - A pair from Create Jetpack: `Cannot send clientbound payloads on the client` during a
    `ModConfigEvent$Reloading`, fired from the config file watcher. It's probably the fresh server
    folder writing its configs, not one of the new mods. Check whether it comes back on the real
    `run/server/`.
- **TaCZ Tweaks knows about Sound Physics.** It ships a mixin package named
  `feature.sound_physics_evaluate`, so gun sounds likely go through Sound Physics on purpose. That's
  inferred from the mixin's name: what it does wasn't read.
- **Simple Backups' defaults,** from the `config/simplebackups-common.toml` the scratch boot
  generated: enabled, a full backup every 120 minutes (`timer = 120`), keep 10, at most 25 GB,
  written to `simplebackups/` beside the world, with a chat message each time. `noPlayerBackups =
  false` means it doesn't back up while nobody is online, which single-player never hits. The real
  run regenerates the file, so read it again and report what it says.

## Open questions

- **Sound Physics' side.** Default: set `side = "client"` in its `.pw.toml`. Modrinth calls it
  client-only, with an optional server part. Logan plays single-player, where the game's built-in
  server loads every client mod anyway. Setting it to `client` keeps it off the headless server
  and keeps the guide's client-only count honest. On the server it does harm in a small way: the
  scratch boot's one new dist error came from it (Already checked).

## Shape

### How to add

From `pack/`: `packwiz -y modrinth add simple-backups`, then `chunky`, then
`sound-physics-remastered`. If the project name packwiz prints doesn't match, it fell back to a
search: remove it and stop. Then set `side = "client"` in `sound-physics-remastered.pw.toml` and
run `packwiz refresh`. If packwiz picks a newer version than Already checked lists, read that jar's
`neoforge.mods.toml` against the pack before keeping it.

One batch, one commit: `Add backups, pregeneration and sound physics`.

### The checks

- **Simple Backups' defaults.** After the server check, read the config Simple Backups generated
  under `run/server/config/` (or `run/server/world/serverconfig/` if it's a server config).
  Report the backup interval, how many backups it keeps, where it writes them, and whether it
  skips backups when nobody is online.
- **The client-side rule check,** as brief 03 did it (its Shape, "The client-side rule check", with
  the two fixes from its Deviations). Sound Physics is the new client-only mod. Expect the seven
  known `[1.21,1.21.1)` Minecraft ranges and nothing else.

### Docs

- **`docs/guide/playing.md`:** a new section, "Looking after a world," with:
  - **Backups:** what Simple Backups does on its defaults (interval, how many it keeps, the
    folder), and how to restore one (unzip it over the world folder with the game closed).
  - **Pregenerating:** Chunky's commands for a single-player world. They need cheats on (or Open
    to LAN with cheats), so say so. Give a starting point: `/chunky radius 1000`, then
    `/chunky start`, plus `/chunky pause` and `/chunky continue`. Say the radius is in blocks
    around the world center, and that generating takes a while and runs while you play.
- **`docs/guide/mods.md`:**
  - Update the counts (the entries, and the server and client jar split).
  - Simple Backups and Chunky go under Quality of life. Sound Physics goes under "Seeing what's
    going on," and that group's name can become "Seeing and hearing what's going on."
  - Known rough edges: Sound Physics is an alpha build, and has no settings screen because Cloth
    Config isn't in the pack. (If brief 06's trial goes, Cloth Config arrives with Better Combat
    and the screen appears. Don't mention that here.)
- **`docs/guide/README.md`:** the playing page's line gains "and looking after a world."

## Out of scope

- A Simple Backups config, a Chunky config, a Sound Physics config: the integrations brief.
- Pregenerating on the headless server or in `scripts/server-check.sh`.
- Better Combat, Combat Roll and Apothic Combat: [brief 06](06-better-combat-trial.md).
- Moving Sodium, Iris or JEI off their pins.

## Build order

1. Add the three mods, set Sound Physics' side, then run `scripts/server-check.sh`, then
   `git status --short pack/`. Only new files should show, plus `index.toml` and `pack.toml`. On a
   failure, follow brief 02's Build order step 1.
2. Simple Backups' defaults, then the client-side rule check.
3. No duplicate filenames. Run the server check twice more on the final pack.
4. The docs, then `scripts/export.sh`. Commit, staging `pack/` and the docs by name.

`packwiz serve` for Prism may be holding 8080: use `CHECK_PORT=8081`.

## Acceptance

- `scripts/server-check.sh` exits 0 on the final pack, twice in a row. Paste both summaries and the
  ERROR-line count, and account for any change from brief 04's count by source.
- `simple-backups.pw.toml`, `chunky.pw.toml` and `sound-physics-remastered.pw.toml` exist. The
  first two have `side = "both"` and Sound Physics has `side = "client"`.
- `grep -h '^filename' pack/mods/*.pw.toml pack/tacz/*.pw.toml | sort | uniq -d` prints nothing.
- No `cloth-config.pw.toml` (it isn't needed here, and arrives with brief 06 if that goes ahead).
- The report lists Simple Backups' defaults.
- The client-side rule check flags nothing beyond the seven known Minecraft ranges.
- `scripts/export.sh` writes the `.mrpack`.
- `python3 -I ~/.claude/skills/brief/scripts/checklinks.py .` reports 0 broken.

**Logan, by hand.** Re-sync the Prism instance from `packwiz serve` first.

- The client launches at 8192 MB.
- In a new world with cheats on, `/chunky radius 500` then `/chunky start` runs to completion, and
  the world still plays while it runs.
- After the interval in the guide, a backup appears in the folder the guide names. Or force one
  with the command the report gives, if Simple Backups has one.
- Fire a gun in a cave or mineshaft, then in the open: the cave shot echoes. A sound behind a wall
  is muffled.
- Frame time in a cave with a gunfight is no worse than without Sound Physics. If it is, say so:
  it comes out.

Then stop. Report, and leave merging to Logan.

## Report

### Built

- **The pack** (`828d2b2`, `Add backups, pregeneration and sound physics`): Simple Backups
  1.21-4.0.30, Chunky 1.4.23 and Sound Physics Remastered neoforge-1.21.1-1.5.1, the versions
  Already checked lists. packwiz printed the right project name for each and pulled no
  dependencies. `sound-physics-remastered.pw.toml` is `side = "client"`; the other two are
  `both`. `git status --short pack/` showed the three new files plus `index.toml` and
  `pack.toml`, nothing else.
- **Docs:** a "Looking after a world" section on the playing page (backups, restoring one,
  pregenerating), the mod list's counts, groups and two rough edges, and the guide index and root
  README lines.

### Deviations

- **The briefs were uncommitted** (05, 06, and their README and `FUTURE.md` edits) when the
  session started. They went in first as their own commit, `341ee03` (`Briefs 05 and 06:
  backups, pregeneration and sound; the Better Combat trial`), as brief 03 did, so the batch and
  this report sit on top of them.
- **Where backups go isn't "beside the world".** `outputPath = "simplebackups"` is resolved
  against the game's working directory, and `createSubDirs = true` adds a folder per world. In
  Prism that's the instance's `minecraft/simplebackups/<save folder>/`, next to `saves/`, not
  inside it (read from `CommonConfig.getOutputPath` and `BackupThread` in the jar). The guide
  says that.
- **The restore steps move the old world out first,** rather than unzipping over it. The zip's
  entries start with the save folder's name, so it unpacks into `saves/` under the old name.
  Unzipping over a live folder would leave files written after the backup (newer region files,
  say) mixed in with the restored ones.
- **The guide names Sound Physics' config folder,** `config/sound_physics_remastered/` with
  `soundphysics.properties`, read from the jar, since there's no settings screen to point at.

### Defaults taken

- **Sound Physics' side:** `client`, as the open question's default said. The scratch boot's
  `SoundEngine for invalid dist DEDICATED_SERVER` line is gone with it: none in any of the three
  runs below.

### Simple Backups' defaults

From `run/server/config/simplebackups-common.toml` and `simplebackups-server.toml`, as the real
run generated them:

- **Enabled,** `backupType = "FULL_BACKUPS"`: a full zip each time, with a save-all first.
- **Interval:** `timer = 120` minutes, on the real clock (`useTickCounter = false`).
- **Keeps** `backupsToKeep = 10`, and deletes the oldest past `maxDiskSize = "25 GB"`.
- **Where:** `outputPath = "simplebackups"`, `createSubDirs = true` (see Deviations).
- **Nobody online:** `noPlayerBackups = false`, so it skips backups while nobody's on. A
  single-player world is never in that state while it's running.
- **Messages:** `sendMessages = true`, to everyone (`messagesForEveryone = true`).
- **Forcing one:** `/simplebackups backup start` (also `backup pause` and `backup unpause`).
  `commandsCheatsDisabled = false`, so it needs permission level 2, which in single-player means
  cheats on. Read from `EventListener` and `BackupCommand` in the jar.
- The experimental incremental system is off (`simplebackups-common-experimental.toml`).

### Acceptance

- **`scripts/server-check.sh`, three passes** (`CHECK_PORT=8081`, since `packwiz serve` holds
  8080). The first is step 1's; the other two are step 3's back-to-back runs on the final pack:

  ```
  == server check: PASS ==
  NeoForge:  21.1.264 (Minecraft 1.21.1)
  Mods:      294 loaded (incl. minecraft and neoforge), 266 jar(s) in mods/
  Boot:      53s wall, server says Done (18.665s)!
  Warnings:  675 ERROR line(s) in the log (not failing on them):

  == server check: PASS ==
  NeoForge:  21.1.264 (Minecraft 1.21.1)
  Mods:      294 loaded (incl. minecraft and neoforge), 266 jar(s) in mods/
  Boot:      50s wall, server says Done (17.675s)!
  Warnings:  675 ERROR line(s) in the log (not failing on them):

  == server check: PASS ==
  NeoForge:  21.1.264 (Minecraft 1.21.1)
  Mods:      294 loaded (incl. minecraft and neoforge), 266 jar(s) in mods/
  Boot:      52s wall, server says Done (18.794s)!
  Warnings:  675 ERROR line(s) in the log (not failing on them):
  ```

  **675 ERROR lines, the same as brief 04,** with two more jars and two more mods (264 → 266,
  292 → 294). The scratch boot's three extra lines didn't come back: no `SoundEngine` dist error
  (Sound Physics is off the server), and no Create Jetpack `Cannot send clientbound payloads`
  pair on the real `run/server/`, which fits the brief's guess that a fresh server folder
  writing its configs caused it.
- **The three `.pw.toml` files** exist: `simple-backups` and `chunky` are `side = "both"`,
  `sound-physics-remastered` is `side = "client"`.
- **Duplicate filenames:** `grep -h '^filename' pack/mods/*.pw.toml pack/tacz/*.pw.toml | sort |
  uniq -d` prints nothing.
- **No `cloth-config.pw.toml`:** none.
- **Simple Backups' defaults:** listed above.
- **The client-side rule check:** the client set (291 jars) synced with packwiz-installer `-s
  client` into the scratchpad, brief 03's script reused unchanged. 1007 rules over 356 mod
  entries, 7 flagged, all the known Minecraft ranges: When Dungeons Arise, both compasses, Clean
  Swing (`[1.21,1.21z)`), Iris, JEI, Productive Bees. Sound Physics' own `[1.21,1.21.1]`
  includes 1.21.1.
- **`scripts/export.sh`:** wrote `dist/claude-modpack-0.1.0.mrpack` (25 MB, unchanged: all three
  mods are Modrinth downloads, so none is bundled).
- **`checklinks.py`:** 17 files, 0 broken.

### Size

Sized S, this session S (10 active min, 10 wall, 0 compactions). Everything went as the dry run
said; the reading time went on Simple Backups' bytecode, for the backup folder and the force
command.

### Spot checks for Logan

Re-sync the Prism instance from `packwiz serve` first (it's up on 8080).

- **Memory:** the client launches at 8192 MB.
- **Chunky:** in a new world with cheats on, `/chunky radius 500` then `/chunky start` runs to
  completion, and the world still plays while it runs.
- **Simple Backups:** `/simplebackups backup start` (cheats on) says Backup started, then
  completed, in chat, and a zip appears in the instance's `minecraft/simplebackups/<save
  folder>/`. Opening it shows the world's folder at the top.
- **Sound Physics:** fire a gun in a cave or mineshaft, then in the open: the cave shot echoes. A
  sound behind a wall is muffled.
- **Frame time** in a cave with a gunfight is no worse than without Sound Physics. If it is, say
  so: it comes out.

### Docs updated

- `docs/guide/playing.md`: "Looking after a world", with Backups and Pregenerating.
- `docs/guide/mods.md`: 291 entries, 266 server jars, 25 client-only; Simple Backups and Chunky
  under Quality of life; "Seeing and hearing what's going on" with Sound Physics; two Known
  rough edges (an alpha; no settings screen, and where its config files are).
- `docs/guide/README.md` and the root `README.md`: the playing page's line.
- No architecture page changed: `scripts/server-check.sh` wasn't touched.

### Follow-ups

- **The playing page says the `.mrpack` is about 18 MB.** It's been 25 MB since brief 04 (its
  report says so). Not this brief's change, so left for `wrap`.
- **Status page:** "Where things stand" in `docs/briefs/README.md` still says about 200 mods and
  lists brief 05 as next. `wrap` refreshes it.
- **For the integrations brief:** whether 120 minutes and 10 backups suit a world Logan means to
  keep, and whether `commandsCheatsDisabled = true` is worth it so a survival world without
  cheats can force a backup before something risky. Chunky's `continueOnRestart = false` is the
  other default worth a look.
