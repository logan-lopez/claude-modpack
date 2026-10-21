# The quest book

FTB Quests' quest book, which the pack ships in `pack/config/ftbquests/quests/`. It's the pack's
own content: the server check fails when it doesn't load as written, and minecraft-mcp generates
chapters against the format pinned here.

**Sources:** `pack/config/ftbquests/`, `scripts/pull-quests.sh`

Everything below is for FTB Quests 2101.1.36 and FTB Library 2101.1.37 on NeoForge 1.21.1, read
from their source at tags `v2101.1.36` of `FTBTeam/FTB-Quests` and `v2101.1.37` of
`FTBTeam/FTB-Library` (`BaseQuestFile.java`, `ServerQuestFile.java`, `SNBT.java`), and checked
against real boots on 2026-10-20. **Don't follow FTB Quests' GitHub `main` or Context7's docs
for it:** `main` has moved to JSON5 (`data.json5`, `lang/<locale>/<chapter>.json5`), and this
build reads none of that.

## Layout

```
pack/config/ftbquests/quests/
  data.snbt                  the book's settings, and version: 13
  chapter_groups.snbt        chapter groups in display order; chapter_groups: [ ] when there are none
  chapters/<filename>.snbt   one per chapter
  reward_tables/<name>.snbt  one per reward table (none yet)
  lang/en_us.snbt            every title and description, keyed by object ID
```

It holds twenty-eight chapters in eight groups, Getting Started, Create, Industry, Space, Combat
and Gear, Food and Farming, Magic and Storage and Travel, and nothing in the default group. `chapters/getting_started.snbt` is the sample, alone in Getting Started:
three quests in a chain (a crafting table, Create's andesite alloy, a Create shaft), one item task
each, a dependency on the one before, laid out left to right at `x` 0, 2 and 4, and a 100 XP
reward on the last. It's the format reference, not content. `chapters/create_basics.snbt`
("Create: Andesite to Precision", `order_index` 0 in Create) is the first real chapter: 19 quests
from andesite alloy to the precision mechanism. `chapters/create_crafting.snbt` ("Create:
Mechanical Crafting", `order_index` 1) follows it with 11 quests, and its first quest depends on
`create_basics`' precision mechanism: the book's first dependency across chapters. Four more
follow in Create, `order_index` 2 to 5: `create_contraptions` (16 quests) and `create_logistics`
(17), entered from `create_basics`' andesite casing, `create_fluids` (12), from its mechanical
press, and `create_trains` (12), from `create_crafting`'s crushing wheels. Each first quest
depends on that one quest in another chapter, and no other quest leaves its chapter. Industry
holds six, `order_index` 0 to 5: `create_electricity` (14 quests) and `create_more_machines`
(13), entered from `create_crafting`'s mechanical crafters, `tfmg_steel` (13), from
`create_fluids`' mechanical pump, `create_enchantment_industry` (8), from its spout, `tfmg_oil`
(12), from `tfmg_steel`'s steel ingot, and `create_new_age` (17), from the mechanical crafters.
Space holds `ad_astra_liftoff` (13), from the steel ingot, and Combat and Gear holds
`create_big_cannons` (14), from `create_fluids`' fluid tank, and `silent_gear` (13), open from the
start. Food and Farming holds five,
`order_index` 0 to 4: `farmers_delight` (18 quests), `aquaculture` (13) and `productive_bees`
(12), open from the start, `more_delights` (14), from `farmers_delight`'s cooking pot, and
`create_kitchen` (13), from `create_basics`' mechanical mixer. Magic holds five, `order_index` 0
to 4: `ars_nouveau_source` (11 quests), `irons_spellbooks` (11) and `enchanting` (12), open from
the start, `ars_nouveau_rituals` (11), from `ars_nouveau_source`'s enchanting apparatus, and
`create_wizardry` (7), from `irons_spellbooks`' arcane essence. Storage and Travel holds two:
`storage` (18 quests), open from the start, and `getting_around` (16), from `create_crafting`'s
mechanical crafters. The same rule holds; the chapters with no entry, Rituals and Getting Around
have more than one quest with no dependencies. Every chapter but the sample was drafted and written by minecraft-mcp, which is where real chapters come from, against its
[outline of the whole book](../../../minecraft-mcp/docs/design/quest-book.md).

`data.snbt` is the file FTB Quests wrote itself for a book with no `data.snbt`, so it holds its
defaults (linear progression, circle quests, `grid_scale: 0.5d`). The pack doesn't tune it yet.
`chapter_groups.snbt` started the same way, empty; minecraft-mcp appends a group to it when a
chapter names one the book lacks.

packwiz gives these files no side, so they reach the server check, the server zip and Prism
instances alike ([pack overrides](pack-overrides.md#what-lives-where)).

## The format

**Pinned:** the folder, the file names, `version: 13`, the ID rule, the lang key format and the
writer's layout. minecraft-mcp generates against them; changing one needs Logan.

### SNBT, as FTB Library writes it

FTB Quests reads and writes FTB Library's SNBT, and the check fails when what it writes back
differs from `pack/` (below), so a file must be byte for byte what the writer would produce:

- A tab per level, one key per line, no commas between keys, keys sorted (the writer sorts them
  "since questbook data is commonly stored under version control"), and a newline at the end.
- Lists of compounds open on the key's line: `tasks: [{` ... `}]` for one entry; for several,
  `quests: [` on its own line, each `{` ... `}` indented a level, and `]`.
- An empty list or compound is `[ ]` or `{ }`. Strings are double-quoted. Doubles carry `d`
  (`0.0d`); ints and booleans are bare. An item task's `count` above 1 is a long, which SNBT
  marks with `L`: `count: 8L` in the Create chapter.
- Item stacks are one line, as Minecraft 1.21.1 saves them: `{ count: 1, id: "create:shaft" }`.
- Only the keys the writer writes. It leaves out defaults (`count` on an item task when it's 1,
  `size` when it's 0, `optional_task` when false), so writing one in counts as a rewrite.

The sample is the reference. A quest with a dependency, a reward and a task:

```
		{
			dependencies: ["00ED0347E5F2AE0A"]
			id: "4F87995FA90727E9"
			rewards: [{
				id: "2671DE60492A0247"
				type: "xp"
				xp: 100
			}]
			tasks: [{
				id: "233FCD7815BE9E2D"
				item: { count: 1, id: "create:shaft" }
				type: "item"
			}]
			x: 4.0d
			y: 0.0d
		}
```

A chapter file has `default_hide_dependency_lines`, `default_quest_shape` (`""` for the book's
default), `filename` (its file name without `.snbt`), `group` (`""` for the default group, or a
group's ID), `id`, `images`, `order_index` (its place in the group, from 0), `quest_links` and
`quests`. Task and reward `type`s from FTB Quests itself are bare (`item`, `xp`); other mods'
are full IDs. The `writeData` methods of `Chapter`, `Quest`, `task/ItemTask`, `reward/XPReward`
and `reward/ItemReward` at the tag list every key.

`chapter_groups.snbt` lists every group but the default one, in display order, each on one line:
`{ icon: { id: "create:cogwheel" }, id: "7DF81F61BC6148EF" }` (`icon` only when set). A group's
title is the lang key `chapter_group.<ID>.title`. A chapter's `icon` is the same `{ id: ... }`
compound, on several lines. An item reward's stack is on several lines too (`count: 1`, `id`),
unlike an item task's single-line one, with the reward's own `count` only above 1. FTB Quests
saves `order_index` as 0..n-1 in each group, so a gap is rewritten on the next save.

### IDs

Every object (chapter, quest, task, reward, group, reward table) has an ID: 16 uppercase hex
digits as a string, `"2A372F82EF67248E"`. **The first digit is 0 to 7,** because FTB Quests
parses it with `Long.parseLong(id, 16)`, which fails above `7FFFFFFFFFFFFFFF`. Unique across the
whole book, not per file. `0000000000000000` and `0000000000000001` are taken (none, and the book
itself). A generator should pick them at random, as FTB Quests does.

### Text

Titles and descriptions live only in `lang/<locale>.snbt`, keyed `<type>.<ID>.<key>`:

- `<type>` is `chapter`, `quest`, `task`, `reward`, `chapter_group`, `reward_table`, `file`, ...
  (`QuestObjectType`).
- `<key>` is `title` (a string), `quest_subtitle` (a string), `quest_desc` (a list of strings, one
  per paragraph) or `chapter_subtitle` (a list).
- `en_us` is the fallback locale (`data.snbt`'s `fallback_locale`). Empty strings and lists
  aren't written.

`chapter.2A372F82EF67248E.title: "Getting Started"` titles the sample chapter. A `title` or
`description` key in a chapter file is the pre-1.21 format: FTB Quests moves it to the lang file
and writes the book back, so it fails the check. A missing lang key isn't an error on the server;
what the client shows instead hasn't been looked at.

## How FTB Quests loads and saves it

- **It loads after Done,** on server start, and only if `config/ftbquests/quests/` exists. It
  logs `Loading quests from <folder>`, any problems, then `Loaded <n> chapter groups, <n>
  chapters, <n> quests, <n> reward tables`, all on the `Server thread`, about 0.2 seconds after
  Done. The group count includes the default group, so the sample book is `1 chapter groups, 1
  chapters, 3 quests, 0 reward tables`.
- **A file it can't parse is skipped,** with an ERROR from FTB Library:
  `Failed to read <path>: Unexpected end of file!`. A broken lang file adds FTB Quests'
  `can't read lang file <path>`. The server still reaches Done.
- **It repairs some mistakes quietly,** with no log line, and writes the repair back:
  - an ID over `7FFFFFFFFFFFFFFF`, or one already used, gets a new random ID. **Which duplicate
    gets renumbered depends on the order the files are listed in,** so it can be the one that was
    there first: in the test run below, the sample's quest lost its ID to a stray chapter's, and
    the sample's dependency and title then belonged to the stray quest.
  - a dependency on an ID that doesn't exist is dropped (from the source; not caused on purpose).
  - a file name with capitals is renamed to lowercase (from the source).
- **An unknown item** logs Minecraft's `Tried to load invalid item: 'Unknown registry key in
  ResourceKey[minecraft:root / minecraft:item]: create:not_a_real_item'` at ERROR, and the task
  becomes `ftbquests:missing_item`, which is how it's written back.
- **An item that adds components to its own stack** is written back with them. Iron's Spells'
  spell books gain an `irons_spellbooks:spell_container` (their slots) when the stack loads, so a
  task or icon written as `{ count: 1, id: "irons_spellbooks:gold_spell_book" }` comes back with
  `components: { ... }` and fails the server check (2026-10-21).
- **Every load marks the book dirty** (`Chapter.addQuest` and `ChapterGroup.addChapter` call
  `markDirty`), so the next world save writes the whole book back: an autosave, `save-all` or
  the server stopping. For a clean book the bytes are the same; only the files' times change.
  `data.snbt` with a `version` other than 13, or no `data.snbt` at all, is written back with
  FTB Quests' defaults.
- **The lang file** is written only when its text changed (an edit, or a legacy key moved in).

## What the server check does

`scripts/server-check.sh` ([its page](server-check.md#what-counts-as-a-failure)), when
`pack/config/ftbquests/quests/` exists:

1. Deletes `run/server/config/ftbquests/quests/` before the sync, so the server reads only
   `pack/`'s files (configs persist between runs, and the server writes this folder).
   packwiz-installer puts a file back when it's missing on disk, and the script dies before the
   boot if the synced folder differs from `pack/`'s.
2. After Done, waits up to 10 seconds for the `Loaded ... reward tables` line, then stops the
   server, which saves the book.
3. Fails when:
   - the `Loaded` line never comes;
   - it counts fewer chapters than `chapters/*.snbt` in `pack/`, or fewer reward tables than
     `reward_tables/*.snbt`;
   - any `Server thread` ERROR line falls between `Loading quests from` and `Loaded`. That
     covers a file that doesn't parse, a lang file that doesn't, an unknown item, and FTB Quests'
     other load errors, without listing them;
   - after the server has exited, any file in `run/server/config/ftbquests/quests/` differs from
     `pack/`'s, or is only on one side. That's FTB Quests repairing something: an ID, a dropped
     dependency, a legacy key, a layout the writer wouldn't produce. The summary prints the diff,
     which is what FTB Quests wanted instead.
4. On a pass, prints `Quests: <the Loaded line's counts>`.

It proves the book parses, every ID is valid and unique, every item exists in the registry, and
the files are exactly what FTB Quests would write. It doesn't prove a quest makes sense: that an
item can be made yet at that point, that the dependencies are the intended ones, that quests don't
overlap on screen, or that every quest has a title. Those are the generator's job, and Logan's
hand checks in the client.

## What sync does to edited files

Checked headlessly on 2026-10-20 with packwiz-installer synced into a scratch folder, a quest file
edited there, then synced again:

- **The pack unchanged:** the edit stays ("Modpack is already up to date!").
- **Another file in the pack changed:** the edit stays. packwiz-installer compares its cached
  hashes, not the files on disk.
- **That same file changed in the pack:** the pack's copy replaces it, and the edit is gone.

So an editor change in Prism survives launches until a pack change touches the same file. Most
editor changes touch the chapter's file, and any title edit touches `lang/en_us.snbt`.

## Pulling editor changes

`scripts/pull-quests.sh [instance's minecraft folder]` (default: the `Claude Modpack` Prism
instance) copies `config/ftbquests/quests/` from the instance over `pack/`'s with
`rsync -a --delete`, leaving out `*.tmp` (FTB Library writes each file to `<name>.tmp` and renames
it, so one is only left by a crash). Then it runs `packwiz refresh` and prints `git status` and
`git diff --stat` for the book and `pack/index.toml`. It never commits.

- It refuses when the source has no `config/ftbquests/quests/`.
- It refuses when `pack/config/ftbquests/quests/` has uncommitted changes, unless `FORCE=1`:
  they could be quests another tool just wrote.
- It prints "quit the world first" every run and doesn't look for a running game. FTB Quests
  writes the editor's changes at the next world save.

The instance's copy has been rewritten by every save since it loaded (above), so a pull of an
unchanged book changes no bytes. Whether the editor's save of a moved quest touches only that
quest's `x` and `y` is Logan's hand check.

## Writing quests from another tool

What a generator such as minecraft-mcp writes, into `pack/config/ftbquests/quests/`:

- One `chapters/<filename>.snbt` per chapter, lowercase, with `filename` matching, its
  `order_index` in its group (0..n-1, no gaps), and `group: ""` or a group from
  `chapter_groups.snbt`.
- New IDs by the rule above, unique across every file in the book, including the ones it didn't
  write. Dependencies by ID, to quests that exist.
- Titles and descriptions in `lang/en_us.snbt`, keys sorted with the rest of the file.
- Exactly the writer's layout (sorted keys, tabs, defaults left out). Copy the sample.
- Item IDs that exist in the pack: minecraft-mcp can check them against its export before the
  boot, which is faster than the check finding them.

Then `scripts/server-check.sh`. A pass means FTB Quests loaded every file and would write it back
unchanged. A fail names the problem: the ERROR lines, the counts, or the diff of what FTB Quests
rewrote. A generator may append a group to `chapter_groups.snbt`, never delete, rename or reorder
one (minecraft-mcp's call, Logan, 2026-10-21); groups are ordered by dragging them in the editor.
Don't hand-edit `data.snbt` from a generator without Logan.

The server zip carries the book. A newer zip unzipped over an old server replaces chapters but
doesn't delete one the pack dropped ([the server build](server-pack.md#the-zip)).

## Decisions

The failure runs that proved the check, on 2026-10-20, each a change to the sample alone:

| Breakage | Check's reason |
| --- | --- |
| The chapter's last `}` deleted | `quests: loaded 0 of 1 chapters; 1 ERROR line(s) while loading the book` |
| A task's ID set to another task's | `quests: FTB Quests rewrote the book on save (1 file(s))`; the diff shows the new ID |
| The chapter's ID set to `8000000000000000` | the same, with the chapter's new ID |
| `create:shaft` changed to `create:not_a_real_item` | `quests: 1 ERROR line(s) while loading the book; FTB Quests rewrote the book on save (1 file(s))` |

A rewrite fails the check rather than being reported (the brief's default, kept): a generator
that writes a duplicate ID would otherwise pass with a dependency quietly pointing at a random
ID. FTB Quests rewrites clean files too, but byte for byte, so comparing content keeps the
failure meaningful.
