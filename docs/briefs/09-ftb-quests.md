# Brief 09: FTB Quests, and a quest book minecraft-mcp can write

**Size:** M. Bumped from S because nobody here has run FTB Quests yet, and its load behavior is only known from its source.

Read `CLAUDE.md`, [`README.md`](README.md), [the server check page](../architecture/server-check.md),
[the pack overrides page](../architecture/pack-overrides.md) and the guide's
[mods page](../guide/mods.md) first. This brief un-parks FTB Quests and FTB XMod Compat
([`FUTURE.md`](FUTURE.md#parked)). It needs nothing from briefs 07 or 08 and touches none of
their files except `scripts/server-check.sh`.

## Goal

Put FTB Quests in the pack, and make `pack/config/ftbquests/quests/` a place another tool can
write quests and get a hard yes or no back from the server check. The other tool is
[minecraft-mcp](../../../minecraft-mcp/), next to this repo: an MCP server over the pack's
resolved recipes whose next plan is drafting FTB Quests chapters
(its `docs/briefs/FUTURE.md`, Quest generation). That plan needs four things from this repo, and
this brief delivers them:

1. FTB Quests and XMod Compat in the pack, passing the server check.
2. A small sample chapter in `pack/config/ftbquests/quests/`, written by hand from FTB Quests'
   source, that loads on the server and opens in Logan's client. It's the format reference a
   generator copies.
3. `scripts/server-check.sh` failing when a quest file in `pack/` doesn't load as written.
4. `docs/architecture/quests.md`, which pins the file format, the ID rules and what the check
   does, so minecraft-mcp can be briefed from it without booting anything.

Also `scripts/pull-quests.sh`, so changes Logan makes in the in-game editor (dragging quests
around, mostly) can come back into `pack/` and be committed.

## Decisions already made

Logan, 2026-10-20, in this brief's Parley round. Don't revisit silently.

- **Scope:** the mods plus a working quest pipeline (sample, check, contract page, pull
  script). Not an empty book alone, and not mods alone.
- **The sample chapter is written from source,** checked by the server, then opened in Prism
  by Logan as a hand check. No stop mid-brief for Logan to build one in the editor.
- **The repo wins.** `pack/config/ftbquests/quests/` is the only source of truth for the
  quest book. In-game edits come back through `scripts/pull-quests.sh` and a commit, or they're
  lost.
- **A broken quest file fails the check.** Unlike recipe noise from mods (the known-errors
  baseline, which only reports), quest files are the pack's own, so a parse or load error fails
  the boot the way a missing dependency does.
- From before: CurseForge only when a mod isn't on Modrinth (`AGENTS.md`); FTB Quests is the
  quest system (minecraft-mcp's decisions table, Logan, 2026-10-20).

## Already checked

All on 2026-10-20.

- **Neither mod is on Modrinth.** A Modrinth search for 1.21.1 NeoForge finds only addons
  (FTB Quests Optimizer, ExtraQuests). Both are on CurseForge, like the pack's other FTB mods
  (`pack/mods/ftb-library-forge.pw.toml` is `mode = "metadata:curseforge"`). Add them with
  `packwiz curseforge add`.
  - FTB Quests (NeoForge): project 289412, slug `ftb-quests-forge`. Newest 1.21.1 NeoForge file
    `ftb-quests-neoforge-2101.1.36.jar`, file ID 8885017, 2026-09-15, release.
  - FTB XMod Compat: project 889915, slug `ftb-xmod-compat`. Newest file
    `ftb-xmod-compat-neoforge-21.1.13.jar`, file ID 9267870, 2026-10-20, release.
  - Source: CFWidget (`api.cfwidget.com/289412`, `/minecraft/mc-mods/ftb-xmod-compat`).
- **Their dependency ranges are met** (from each jar's `META-INF/neoforge.mods.toml`):
  - FTB Quests needs `architectury` `[13.0.8,)` (the pack has 13.0.11), `ftblibrary`
    `[2101.1.36,)` (2101.1.37), `ftbteams` `[2101.1.9,)` (2101.1.11), all `side = "BOTH"`.
    XMod Compat is optional for it.
  - XMod Compat needs `architectury` and `ftblibrary` `[2101.1.34,)`. Optional, all met:
    `ftbquests` `[2101.1.28,)`, `ftbchunks` `[2101.1.13,)` (2101.1.22), `jei`
    `[19.53.0.425,)` (pinned 19.56.0.441), `kubejs` `[2100.7.0,)` (2101.7.2).
    `ftbranks`, `luckperms` and `waystones` are optional and not in the pack.
- **The 1.21.1 build reads SNBT, not JSON5.** Context7's FTB Quests docs (`/ftbteam/ftb-quests`)
  describe GitHub `main`, which has moved to `data.json5` and `lang/<locale>/<chapter>.json5`.
  **Don't follow them.** The source that matches the jar is the tag `v2101.1.36` of
  `FTBTeam/FTB-Quests`. Its `BaseQuestFile.java` and `ServerQuestFile.java`:
  - The book is `config/ftbquests/quests/` (`Platform.getConfigFolder()`), read on the server only
    if the folder exists (`ServerQuestFile.load`, which logs `Loading quests from {}`).
  - `data.snbt` holds the file settings and `version`. `VERSION = 13`; a file at any other version
    is marked dirty, which means FTB Quests writes it back.
  - `chapter_groups.snbt`, `chapters/<name>.snbt` (one per chapter; the file name becomes the
    chapter's filename), `reward_tables/<name>.snbt`, and `lang/<locale>.snbt`, such as
    `lang/en_us.snbt`. The lang folder is created if it's missing.
  - The writer sorts keys "since questbook data is commonly stored under version control"
    (`BaseQuestFile.writeDataFull`, around line 519).
  - The load ends with an INFO line:
    `Loaded {} chapter groups, {} chapters, {} quests, {} reward tables`.
- **A broken file doesn't stop the boot.** FTB Library's `SNBT.read` (tag `v2101.1.37`) logs
  `Failed to read <path>: <message>` at ERROR and returns null, and `BaseQuestFile` then skips
  that chapter. Other ERROR lines on the load path: `failed to read data for {} {}: {}`,
  `can't read lang file {}`, `failed to load reward table data: {}`,
  `failed to load quest data from {}: {}`. The server still reaches Done, so the check as it
  stands would pass.
- **IDs** are written as 16 uppercase hex digits (`QuestObjectBase.getCodeString`, `%016X`) and
  read with `Long.parseLong(id, 16)`, so an ID over `7FFFFFFFFFFFFFFF` fails to parse and counts
  as 0. `BaseQuestFile.readID` replaces 0, 1 (the file's own ID) and any duplicate with a random
  ID and marks the file dirty. A bad ID is quietly renumbered, not rejected.
- **Text lives in the lang file,** keyed `<object type>.<ID>.<key>`
  (`TranslationManager.makeKey`), where the key is `title`, `quest_subtitle`, `quest_desc` (a
  list of strings) or `chapter_subtitle` (a list) (`TranslationKey`). Whether the object type
  is written `quest` and `chapter` exactly is unconfirmed; check `QuestObjectType`.
- **Other facts in the repo:** the Prism auto-sync instance is
  `~/Library/Application Support/PrismLauncher/instances/Claude Modpack/minecraft/` (its
  `instance.cfg` runs packwiz-installer from `localhost:8080`), and it has no
  `config/ftbquests/` yet. The server check keeps `run/server/config/` between runs
  ([server check page](../architecture/server-check.md#rules-worth-keeping)), and packwiz gives a
  file with no `.pw.toml` no side, so quest files reach both the server and the client
  ([pack overrides page](../architecture/pack-overrides.md#what-lives-where)).

## Open questions

Each has a default to use if Logan doesn't answer.

- **Should the check fail when FTB Quests rewrites a file?** FTB Quests rewrites a file after a
  renumbered ID, an old `version` or anything else it fixed on load. That means the file in
  `pack/` isn't what loaded. Default: **fail**, naming the files, because a generator that
  writes a duplicate ID would otherwise pass with its dependencies silently pointing at a random
  ID. If FTB Quests turns out to rewrite clean files too (formatting, say), report the rewrite
  instead of failing, and write down why.
- **What is the sample chapter?** Default: `chapters/getting_started.snbt`, "Getting Started",
  three quests in a chain: make a crafting table, then a Create andesite alloy, then a Create
  shaft. One item task each, a dependency on the one before, positions laid out left to right,
  and an XP reward on the last one. Plus a title and a description for each in
  `lang/en_us.snbt`. It covers the surface a generator needs (item tasks, dependencies, a
  reward, text, layout) and stays small enough that Logan can replace it later.
- **Unknown item IDs.** What FTB Quests does with an item task naming an item that doesn't
  exist (a log line, an empty stack, a barrier icon) isn't known. Default: find out with a
  deliberate one. If it logs, the check fails on that line. If it's silent, record it on the
  quests page as the generator's job, since minecraft-mcp can check IDs against its export.

## Shape

### The mods

`packwiz curseforge add` in `pack/` for `ftb-quests-forge` and `ftb-xmod-compat`, at the files
above or newer 1.21.1 NeoForge releases. Both `side = "both"`. Check that the added `.pw.toml`
names the NeoForge file, not a Forge or Fabric one.

### The quest book in `pack/config/ftbquests/quests/`

1. Boot the server check once with the mods and no quest folder in `pack/`. Note what FTB
   Quests writes in `run/server/config/ftbquests/` (`ServerQuestFile.load` only reads the
   folder if it exists, so it may write nothing until it's saved). Use the files it writes as
   the starting `data.snbt` and `chapter_groups.snbt` if there are any. Otherwise write them
   from `BaseQuestFile.writeDataFull` and `readData` at `v2101.1.36`.
2. Write the sample chapter and `lang/en_us.snbt` by hand from the source:
   `quest/Chapter.java`, `quest/Quest.java`, `quest/task/ItemTask.java`,
   `quest/reward/XPReward.java` (each one's `writeData` is the format), and how an item stack is
   written in SNBT on 1.21.1. Use the writer's layout (sorted keys, its indentation from FTB
   Library's `SNBTBuilder`) so the first in-game save doesn't reformat the whole file. IDs are
   fixed 16-digit hex strings with a first digit from 0 to 7, unique across the book.
3. **Pinned:** the folder, the file names, `version = 13`, the ID rule and the lang key format.
   minecraft-mcp will generate against them; changing one needs Logan.

### `scripts/server-check.sh`

Read [its page](../architecture/server-check.md) first, and keep to its rules (bash 3.2, failure
strings copied from a real run).

- **A clean quest folder each run.** Before the sync, delete `run/server/config/ftbquests/quests/`,
  so the server reads exactly the pack's files: configs persist between runs, and the server can
  write files there that packwiz-installer didn't install. Confirm that the sync then puts the
  pack's files back. packwiz-installer tracks what it installed in `packwiz.json`, and whether
  it re-fetches a tracked file that's missing on disk is unchecked.
- **Fail on a quest load error,** after Done, when `pack/config/ftbquests/quests/` exists:
  - on any of the FTB Library and FTB Quests ERROR lines in Already checked whose path or
    message is about the quest book, copied from a real run (break the sample to get them);
  - when the `Loaded … chapters, … reward tables` line is missing, or its chapter count is lower
    than the number of `chapters/*.snbt` in `pack/`, or its reward table count lower than
    `reward_tables/*.snbt`;
  - on a rewritten file, by the open question's default. After `stop`, once the server has
    exited, compare `run/server/config/ftbquests/quests/` with `pack/`'s copy. The check has to
    wait for the exit here; read how `cleanup` and `kill_tree` end the run now.
  - The load may log after Done. If so, wait for the `Loaded` line, up to a few seconds, before
    deciding.
- **On a pass,** print `Quests: <groups> chapter groups, <chapters> chapters, <quests> quests,
  <tables> reward tables` from that line. Print nothing about quests when `pack/` has no quest
  folder.
- **Keep the existing outcomes as they are.** The known-errors baseline stays report-only; quest
  errors aren't baseline keys. If FTB Quests' own lines show up as new keys in the baseline
  summary, leave `load_error_keys` alone and say so.

### `scripts/pull-quests.sh`

Copies the in-game editor's changes back into the pack. `#!/bin/bash`, the same style as the
other scripts.

- **Source:** the first argument, a Prism instance's Minecraft folder. Default:
  `$HOME/Library/Application Support/PrismLauncher/instances/Claude Modpack/minecraft`.
  It refuses with a clear message if `<source>/config/ftbquests/quests/` isn't there.
- **It refuses to run when `pack/config/ftbquests/quests/` has uncommitted changes,** unless
  `FORCE=1`. Those could be quests minecraft-mcp just wrote, and the copy would wipe them.
- **Then** `rsync -a --delete` the instance's `config/ftbquests/quests/` over the pack's, run
  `packwiz refresh` in `pack/`, and print `git status --short` and `git diff --stat` for
  `pack/config/ftbquests/` and `pack/index.toml`. It doesn't commit.
- **It says to quit the world first.** FTB Quests writes editor changes when it saves, so a
  running game may not have written them yet. Print that line every run; don't try to detect the
  game.

### What sync does to edited quest files

Find out headlessly whether packwiz-installer overwrites a quest file that was changed after it
installed it, both when the pack's copy is unchanged and when it changed. Sync into a scratch
folder (or `run/server/`) with `-g -s server`, edit a synced quest file, sync again. Put the
answer on the quests page and the guide page. It decides whether Logan must pull before his next
launch or only before the next pack change.

### Docs

- **`docs/architecture/quests.md`**, a new area: the book's layout, the pinned format, the ID
  and lang rules, what the check does and why, what sync does to edited files, the pull
  script, and a **"Writing quests from another tool"** section: what a generator must write,
  what the check proves and what it doesn't (an item task can name an item that can't be made
  yet; that's the generator's job). Sources: `pack/config/ftbquests/`, `scripts/pull-quests.sh`.
  Add the Areas row in `AGENTS.md` and the `.claude/rules/` pointer, by hand or with
  `scripts/areas.py` (LAYOUT.md, Checks), and add `scripts/pull-quests.sh` to `AGENTS.md`'s
  Commands table.
- **`docs/architecture/server-check.md`:** the quest outcomes under "What counts as a failure",
  the clean quest folder in How it works, and the failure run that proves it under Decisions.
- **`docs/architecture/pack-overrides.md`:** a line under What lives where pointing at the
  quests page for `pack/config/ftbquests/`.
- **`docs/architecture/server-pack.md`:** one sentence on quest files in the zip. A newer zip
  unzipped over an old server replaces chapters but doesn't delete one the pack dropped.
- **`docs/guide/quests.md`**, new, plus its line in `docs/guide/README.md`: opening the quest
  book, what's in it, editing in the editor and bringing changes back with the pull script,
  what happens at the next launch if you don't, and that a server built from the zip gets the
  book too. **`docs/guide/mods.md`:** move FTB Quests and XMod Compat from the left-out table
  into the list.
- **`docs/briefs/README.md`:** take Quests out of Not built. Delete FUTURE.md's Parked bullet for
  FTB Quests, which now just points here.

## Out of scope

- **Writing real quests.** The sample is a format reference. Chapters for the pack are
  minecraft-mcp's plan.
- **`../minecraft-mcp/`.** Don't edit it. Say in the report what its quest plan can now lean
  on, so its next session can update its `FUTURE.md`.
- **FTB Quests addons** (ExtraQuests, Quests Optimizer, Entity Visualization) and FTB Ranks.
- **FTB Quests' client config,** keybinds, and whether the book shows in the inventory. Those
  are its defaults.
- **Deleting dropped chapters on an updated server zip.** Note it on the server build page.
  Fixing it is a change to brief 08's update story.

## Build order

1. Add the mods; `scripts/server-check.sh` passes. Note what FTB Quests wrote in
   `run/server/config/ftbquests/`.
2. Write `data.snbt`, `chapter_groups.snbt`, the sample chapter and `lang/en_us.snbt`; boot and
   read the `Loaded` line by hand (it should count 1 chapter and 3 quests).
3. The check changes. Prove each failure by causing it, as brief 01 did: a chapter with an SNBT
   syntax error, a duplicate ID, an ID over `7FFFFFFFFFFFFFFF`, an unknown item ID (record what
   happens). Restore the sample and pass again. Keep each failing summary for the report.
4. The sync experiment, then `scripts/pull-quests.sh`. Test it against a scratch folder shaped
   like an instance, not Logan's real instance.
5. Docs. Commit once at the end.

## Acceptance

- `scripts/server-check.sh` exits 0 and its summary includes
  `Quests: 1 chapter groups, 1 chapters, 3 quests, 0 reward tables` (or whatever the default
  group and sample actually count; paste it), and the mod count is up by two.
- With each of the step 3 breakages in place, the check exits 1 and names the quest problem in
  its FAIL line. Paste each summary into the report.
- `git status` after a passing run shows no change under `pack/config/ftbquests/`.
- `scripts/pull-quests.sh <scratch>` with a scratch instance whose chapter differs from the
  pack's copies it over, refreshes the index and prints the diff stat. With an uncommitted
  change in `pack/config/ftbquests/quests/` it refuses without `FORCE=1`. With a missing source
  it refuses.
- `scripts/server-pack.sh` builds, and the zip has `config/ftbquests/quests/` in it
  (`unzip -l dist/*-server.zip | grep ftbquests`).
- `python3 -I ~/.claude/skills/brief/scripts/checklinks.py .` passes.

**Logan's hand checks,** in the `Claude Modpack` Prism instance after a `packwiz serve` sync.
The implementer doesn't launch Prism.

1. The quest book opens and shows Getting Started with three quests, their titles and
   descriptions, laid out left to right, with the later two locked until the one before is done.
2. Crafting a crafting table completes the first quest. The last quest's XP reward can be
   claimed.
3. Drag one quest in the editor, quit to the title screen, run `scripts/pull-quests.sh`. The diff
   should touch only that quest's `x`/`y` in the chapter file. If it reformats the whole file,
   say so; the sample's layout should then be redone from what the editor wrote.
4. JEI still opens on an item from a quest (XMod Compat's link), if the book offers it.

Then stop. Report the check summaries, the sync finding and the hand checks for Logan. Don't
merge anything.
