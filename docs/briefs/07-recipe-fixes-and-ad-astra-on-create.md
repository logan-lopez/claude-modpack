# Brief 07: Recipe fixes, Ad Astra on Create, and a known-errors baseline

**Size:** M. Four small pieces: the baseline is the biggest, and the rest are JSON files.

Read `CLAUDE.md`, [`README.md`](README.md), [the server check page](../architecture/server-check.md)
and [the mod list](../guide/mods.md) first. This is the first part of
[`FUTURE.md`](FUTURE.md#integrations-and-default-settings)'s Integrations and default settings,
and it takes the known-noise half of
[the server check's section](FUTURE.md#the-server-check-client-side-rules-and-log-noise) there.
No prerequisites: everything through `05f2258` is on `main`.

## Goal

Until now the pack has shipped mods and nothing else. Every mod runs on its own defaults, and no
file under `pack/` sets a config or a recipe. This brief ships the pack's first files of its own,
and fixes what is already broken before adding anything new:

1. **A known-errors baseline in the server check.** Every boot logs about 675 ERROR lines, and the
   summary prints the first 20. A recipe this brief breaks, or fails to fix, would get past a
   passing check unnoticed. The check learns which load errors are known, and on a pass prints
   only the ones that are new or gone.
2. **Repairs for recipes that fail to load,** from mods that are in the pack:
   - Almost Unified breaks 12 of Create's Silent Gems ore-crushing recipes and one Create Misc and
     Things recipe. So ruby, sapphire and peridot ore can't be crushed.
   - Create Compressed's pile washing, dough block mixing and rose quartz block polishing use the
     result format from before Create 6 and don't load.
   - Create Deco's placard recipe doesn't load either.
3. **Ad Astra's desh, ostrum and calorite on Create's machines.** Almost Unified already turns
   Ad Astra's iron and steel plates into Create's sheets, but no mod in the pack gives Create a
   recipe for Ad Astra's own three metals. The Create Ad Astra mods have no 1.21.1 build
   (decisions table), and this covers their most-used half.
4. **Rocket fuel.** Ad Astra's fuel tag takes all of `#c:fuel`. Through it, TFMG's byproduct gases
   and creosote can probably fill a rocket, and getting to space depends on a coke oven rather
   than oil and a refinery. Logan picked a shorter list.

## Decisions already made

Logan, 2026-10-19 (an ideate run, then a Parley round). Don't revisit silently.

- **Scope:** the four pieces above. Keybinds are out: Logan is finding those conflicts in play.
- **Step 0 is the list of failing recipe IDs.** It's this brief's to-do list and the baseline's
  seed, so it comes first (Build order).
- **The baseline only reports.** A new error ID doesn't fail the check. A pass still means "it
  booted with no mod-loading failure", as the server check page says.
- **The rocket fuel list:** `ad_astra:fuel` becomes Ad Astra's fuel and cryo fuel, plus
  `#c:diesel` and `#c:biodiesel` (Ad Astra's author already listed those two), plus `#c:gasoline`
  and `#c:kerosene`. `#c:fuel` comes out. Any mod's crude oil still feeds Ad Astra's refinery
  through `#ad_astra:oil`, which isn't touched.
- **Ad Astra's own machines stay.** The compressor and its recipes remain. Create's press is a
  second route, as with steel plates now.

## Already checked

All 2026-10-19, from `run/server/` after the last server check (`logs/latest.log`,
`logs/debug.log`, `logs/almostunified/almostunified.log`) and from the jars in
`run/server/mods/`.

- **The ERROR lines.** 675 in `latest.log`. By source: 526 from `LootDataType` (`Couldn't parse
  element ResourceKey[minecraft:root / minecraft:loot_table]:<id> - ...`), 104 from
  `RecipeManager` (`Parsing error loading recipe <id>: ...`), 28 from `DataMapLoader` (`Object
  with ID <id> ...`), 8 from `RuntimeDistCleaner`, 4 from `SimpleJsonResourceReloadListener`
  (`Couldn't parse data file <id> from ...`, Create Ironworks' tin decompacting), 2 from
  `AdvancementTree` (`Couldn't load advancements: [<ids>]`), and Small Ships' config unload
  exception at shutdown. Data loads twice per boot (on the `main` thread, then on the `Server
  thread` when the world loads), so most IDs appear twice. Key the baseline on IDs, deduplicated.
- **Recipe failures from mods in the pack** (from the `main/ERROR` lines in `debug.log`):
  - 12 `create:crushing/compat/silentgems/*_ore` (ruby, sapphire and peridot; plain, deepslate,
    nether and end): `Recipe has more fluid inputs (1) than supported (0)`.
  - `create_things_and_misc:copper_scaffolding_craft`.
  - Almost Unified's own log names those 13 as recipes it unified that then threw: `The following
    recipes were unified and threw exceptions when being loaded`, followed by `Try to add them
    to the ignore list`.
  - Create Compressed 2.2.0, 7 recipes: `splashing/crushed_raw_{iron,copper,gold,zinc}_pile`,
    `splashing/wheat_flour_pile`, `mixing/dough_block` and
    `sandpaper_polishing/polished_rose_quartz_block`. Their results use `"item"` where Create
    6.0.10 reads `"id"`. `dough_block`'s water is `{"amount":1000,"fluid":"minecraft:water",
    "nbt":{}}`, where Create's own `mixing/dough_by_mixing.json` has `{"type":"neoforge:single",
    "amount":1000,"fluid":"minecraft:water"}`.
  - Create Deco 2.1.3's `createdeco:placard`: its second ingredient is `{"id":
    "minecraft:white_dye"}`, where an ingredient needs `"item"`.
  - The rest are compat recipes for absent mods (Silent Gear's woodcutter and bonsai recipes,
    Create Misc and Things' sails for absent woods, Create Ironworks' Better Smithing Upgrades,
    Productive Bees' modular bees, Just Enough Breeding's Alex's Mobs entries). Leave them alone;
    the baseline makes them quiet.
  - One more for the report, not this brief: Farmer's Delight's
    `integration/silentgear/cutting/netherwood` fails on its sound field.
- **Create 6.0.10's recipe format,** copied from the jar:
  - Pressing: `{"type":"create:pressing","ingredients":[{"tag":"c:ingots/iron"}],"results":[{"id":"create:iron_sheet"}]}`
  - Ore crushing: `{"type":"create:crushing","ingredients":[{"item":"minecraft:iron_ore"}],"processing_time":250,"results":[{"id":"create:crushed_raw_iron"},{"chance":0.75,"id":"create:crushed_raw_iron"},{"chance":0.75,"id":"create:experience_nugget"},{"chance":0.125,"id":"minecraft:cobblestone"}]}`
  - Splashing: results as `{"count":9,"id":"minecraft:iron_nugget"}`, chance as `"chance":0.75`.
- **Almost Unified 1.4.2** is running on a config the pack doesn't ship. Its generated
  `config/almostunified/unification/materials.json` has `mod_priorities` `minecraft, create,
  pneumaticcraft, copycats, create_connected, create_dd, tfmg`, and its log warns that
  `pneumaticcraft` and `create_dd` aren't loaded. Which mod wrote that list wasn't found. Create
  Addon Compatibility 1.0.0 has a mixin into Almost Unified's serializer
  (`MixinUnifySerializer`) and is the likeliest source. `ignored_recipe_ids` is a JSON array of
  recipe ID strings, empty now. `recipe_viewer_hiding` is true and `loot_unification` false.
- **What Almost Unified merges today:** steel (ingot, nugget, block, plate, rod) from Ad Astra,
  Create Ironworks and Create Big Cannons into TFMG's, Ad Astra's iron plate into Create's iron
  sheet, Create Crafts & Additions' copper wire, and ore variants from Ad Astra's planets and
  Deeper and Darker hidden in JEI. That's from the `[AutoHiding]` lines in its log.
- **Ad Astra 1.16.26's three metals:**
  - Ores: `c:ores/desh` is `ad_astra:moon_desh_ore` and `ad_astra:deepslate_desh_ore`.
    `c:ores/ostrum` is `ad_astra:mars_ostrum_ore` and `ad_astra:deepslate_ostrum_ore`.
    `c:ores/calorite` is `ad_astra:venus_calorite_ore` and `ad_astra:deepslate_calorite_ore`.
  - Raw, ingot and plate items are `ad_astra:raw_<metal>`, `ad_astra:<metal>_ingot` and
    `ad_astra:<metal>_plate`, tagged `c:raw_materials/<metal>`, `c:ingots/<metal>` and
    `c:plates/<metal>`.
  - Its compressor makes one plate from one ingot
    (`compressing/desh_plate_from_compressing_desh_ingots.json`).
  - No other jar in `run/server/mods/` has a Create recipe for any of them. Only the Giselle addon,
    Chipped, Deeper and Darker and Productive Bees mention `ad_astra` at all.
- **Fuel tags:**
  - `data/ad_astra/tags/fluid/fuel.json` is `ad_astra:fuel`, `#c:fuel` (optional),
    `ad_astra:cryo_fuel`, `#c:diesel` (optional), `#c:biodiesel` (optional).
  - `tier_1_rocket_fuel` through `tier_4_rocket_fuel` and `tier_1_rover_fuel` are each
    `#ad_astra:fuel`.
  - `#c:fuel` from TFMG 1.2.0 holds LPG, butane, propane, hydrogen, furnace gas, gasoline, diesel,
    naphtha, kerosene and creosote. Diesel Generators adds diesel and biodiesel.
  - `#c:gasoline` and `#c:kerosene` exist (TFMG; Diesel Generators adds its gasoline).
  - That rockets check fuel through these tags is read from the tag names, not from Ad Astra's
    code.
- **KubeJS 2101.7.2.** Its `kubejs/data/` folder "acts just like the `data` folder inside of a
  datapack" and always loads (kubejs.com wiki, Folder structure, via Context7). The wiki doesn't
  say whether it outranks a mod's own data at the same ID. Step 2 finds out. The server's
  `kubejs/server_scripts/main.js` is KubeJS's generated example, not the pack's.
- **NeoForge 21.1 server configs** (`*-server.toml`) land in `config/`, not
  `world/serverconfig/`. Only the FTB mods still use `world/serverconfig/`. So a file under
  `pack/config/` reaches both the server and Logan's single-player instance.
- **packwiz** indexes every file under `pack/` (there's no `.packwizignore`), and a file without a
  `.pw.toml` has no side, so the server sync installs it. Not yet seen on this pack, so step 2
  confirms it.

## Open questions

- **Overriding a broken recipe at the same ID.** Default: a JSON at
  `pack/kubejs/data/<ns>/recipe/<path>.json`, with the same `<ns>:<path>` as the broken one. If
  the error is still logged at that ID after a boot (KubeJS's data loses to the mod's jar), use a
  server script instead (`pack/kubejs/server_scripts/recipe-fixes.js`: `ServerEvents.recipes`
  with `event.custom({...}).id('<same id>')`), and say which in the report and on the
  architecture page.
- **The Silent Gems crushing recipes.** Default: add the 13 IDs to Almost Unified's
  `ignored_recipe_ids`. If they still fail, override them at the same ID with a plain
  `{"item": ...}` ingredient instead of the `neoforge:compound` one, and keep them in the ignore
  list.

## Shape

### Step 0: the failing recipe IDs, **pinned**

`scripts/server-check.known-errors.txt`, committed: one line per known load error, sorted and
unique, with the kind and the ID separated by a space.

```
advancement dungeons_arise:find_fishing_hut
datafile create_ironworks:misc/compat/create_dd/recipe/crafting/tin_ingot_from_decompacting
datamap <id>
loot create_connected:blocks/dye_depot_amber_fan_dyeing_catalyst
recipe create:crushing/compat/silentgems/ruby_ore
```

Kinds and the line each comes from:

| Kind | Line |
| --- | --- |
| `recipe` | `Parsing error loading recipe <id>:` |
| `loot` | `Couldn't parse element ResourceKey[minecraft:root / minecraft:loot_table]:<id> -` |
| `datafile` | `Couldn't parse data file <id> from` |
| `datamap` | `DataMapLoader`'s `Object with ID <id>` |
| `advancement` | each ID in `Couldn't load advancements: [<ids>]` |

ERROR lines of any other shape aren't keyed. The check prints them as now (step 1).

Generate the first version from the current `run/server/logs/latest.log` before changing
anything else, and commit it on its own. It's the "before" for the report. List the recipe IDs
that steps 2 and 3 should remove in the report.

### Step 1: the baseline in `scripts/server-check.sh`

On a pass, in place of the first 20 ERROR lines:

- Extract the keys from `$LOG` as step 0 does, with one function used both here and to write the
  baseline.
- Compare against `scripts/server-check.known-errors.txt` with `sort -u` and `comm`. Bash 3.2: no
  associative arrays (the server check page, Rules worth keeping).
- Print three things:
  - `Load errors: <n> known, <n> new, <n> gone`.
  - Each new key, then each gone key, indented, up to 20 of each with a count of the rest.
  - ERROR lines that matched no kind, as now (the first 20, deduplicated, with the count).
- **`CHECK_UPDATE_BASELINE=1`** rewrites the baseline file from this run's keys after a pass.
  Never on a fail.
- A missing baseline file isn't an error: say so and print the keys count.
- Exit codes don't change. New keys never fail the check (Decisions).

Update [the server check page](../architecture/server-check.md): how it works, step 7, a section
on the baseline (the file, the kinds, how to refresh it, why it only reports), and the Decisions
section.

### Step 2: recipe repairs

- **`pack/config/almostunified/unification/materials.json`:** the generated file as it is now,
  with:
  - the 13 IDs from Already checked in `ignored_recipe_ids`;
  - `pneumaticcraft` and `create_dd` removed from `mod_priorities`.

  Keep the rest as generated, so the pack pins today's behavior rather than changing it.
- **Create Compressed:** the 7 recipes at the same IDs under
  `pack/kubejs/data/create_compressed/recipe/...`, copied from the jar with `"item"` changed to
  `"id"` in the results and the water ingredient in Create's form (Already checked). Counts and
  chances stay as the mod wrote them.
- **Create Deco:** `pack/kubejs/data/createdeco/recipe/placard.json`, the jar's file with the
  white dye as `{"item": "minecraft:white_dye"}`.
- Run `packwiz refresh` in `pack/`, then the server check. Each repaired ID must show as gone.
  Confirm the Almost Unified file arrived in `run/server/config/` unchanged: diff it against
  `pack/`'s copy after the boot. Almost Unified may rewrite it on load, and if it does, report
  what changed.

### Step 3: Ad Astra on Create

Under `pack/kubejs/data/claude_modpack/recipe/ad_astra/`, six files:

- `pressing/<metal>_plate.json` for desh, ostrum and calorite: `#c:ingots/<metal>` to one
  `ad_astra:<metal>_plate`, matching the compressor's one to one.
- `crushing/<metal>_ore.json` for each metal: `#c:ores/<metal>` to one `ad_astra:raw_<metal>`, a
  0.75 chance of a second, a 0.75 chance of `create:experience_nugget`, and `processing_time` 250,
  like Create's iron ore. Leave out the cobblestone, because the ores sit in planet stone and
  deepslate.

The `claude_modpack` namespace marks the pack's own recipes, so they can't collide with a mod's.

### Step 4: rocket fuel

`pack/kubejs/data/ad_astra/tags/fluid/fuel.json`:

```json
{
  "replace": true,
  "values": [
    "ad_astra:fuel",
    "ad_astra:cryo_fuel",
    { "id": "#c:diesel", "required": false },
    { "id": "#c:biodiesel", "required": false },
    { "id": "#c:gasoline", "required": false },
    { "id": "#c:kerosene", "required": false }
  ]
}
```

To confirm it applied, without a client: a throwaway server script that logs the tag's members
(`ServerEvents.tags('fluid', e => console.info(e.get('ad_astra:fuel').getObjectIds()))`), read in
`run/server/logs/kubejs/server.log` after a boot, then deleted before the commit. If
`replace` loses to Ad Astra's own file, ship the change as a server script instead
(`pack/kubejs/server_scripts/rocket-fuel.js`: `removeAll` then `add`), and say so.

### Docs

- **A new architecture page, `docs/architecture/pack-overrides.md`,** with Sources
  `pack/config/` and `pack/kubejs/`. Cover:
  - what lives where (configs under `pack/config/`, recipes and tags under `pack/kubejs/data/`,
    the pack's own recipes in the `claude_modpack` namespace);
  - how a fix overrides a mod's recipe at the same ID, and which way step 2 found works;
  - that a NeoForge server config in `pack/config/` reaches single-player;
  - that the baseline is how to see a fix take.

  Then run `python3 -I ~/.claude/skills/brief/scripts/areas.py .` to add the Areas row in
  `AGENTS.md` and the `.claude/rules/` pointer. Check that the rule's `paths:` match files under
  both folders (`pack/config/**` and `pack/kubejs/**`), not only the folder names.
- **`docs/guide/mods.md`:**
  - Ad Astra's row in "Left behind" says KubeJS recipes stand in for Create Ad Astra Recipes'
    pressing and crushing.
  - "Known rough edges" gains the rocket fuel list in one sentence.
  - Mention ruby, sapphire and peridot crushing if the page names crushing anywhere.
- **`FUTURE.md`,** Integrations: strike the Almost Unified and Ad Astra candidates and the
  Just Enough Breeding one, which the baseline now covers. Server check section: strike the
  known-noise half.

## Out of scope

- Keybinds, `options.txt` and any client default (Logan, 2026-10-19).
- Simple Backups' and Chunky's defaults, Better Combat's ram rod blacklist, and the melee parity
  pass.
- Recipes for absent mods. They stay as baseline entries.
- Sequenced assembly or other Create routes for Ad Astra's rocket parts, and any change to
  `#ad_astra:oil`.
- Almost Unified's material list and loot unification.
- The client-side rule check in the server check (`FUTURE.md`).
- Farmer's Delight's broken netherwood cutting recipe: report it, don't fix it.

## Build order

`packwiz serve` for Prism may be holding 8080: use `CHECK_PORT=8081`.

1. Step 0: write the baseline from the current log. Commit: `Record the server check's known load
   errors`.
2. Step 1, then a server check: `0 new, 0 gone`. Commit with the server check page.
3. Steps 2, 3 and 4, a server check after each. Then `CHECK_UPDATE_BASELINE=1`, which should only
   remove lines. Show the baseline's diff in the report.
4. Docs, `scripts/export.sh`, and a last server check. Commit, staging files by name.

## Acceptance

- `scripts/server-check.sh` exits 0 twice in a row on the final pack. Paste both summaries.
- The summary shows `Load errors: <n> known, 0 new, 0 gone` and no longer prints the first 20 raw
  ERROR lines.
- `git diff <step 0's commit> -- scripts/server-check.known-errors.txt` shows only removed lines,
  and they include:
  - the 13 Almost Unified recipes;
  - the 7 `create_compressed` recipes;
  - `createdeco:placard`.
- Each recipe in step 3 loads: its ID appears in no `Parsing error` line, and
  `logs/kubejs/server.log` shows no errors.
- The step 4 tag log showed exactly the six entries' fluids, and the throwaway script isn't
  committed.
- With a fake new key (append a line to a copy of the log, or point the check at a doctored
  baseline), the summary lists it as new and the check still exits 0. Describe the method in the
  report.
- `git status --short` shows nothing under `run/` or `dist/`.
- `python3 -I ~/.claude/skills/brief/scripts/checklinks.py .` reports 0 broken.

**Logan, by hand.** Re-sync the Prism instance from `packwiz serve` first.

- In JEI, a Silent Gems ruby ore shows a Create crushing recipe.
- Desh, ostrum and calorite ingots show a pressing recipe, and their ores a crushing one.
- Create Compressed's crushed iron pile shows a washing recipe. The placard dye recipe shows.
- An Ad Astra fuel tank or rocket takes TFMG gasoline or kerosene, and refuses creosote.
- Nothing he relies on vanished from JEI (Almost Unified's hiding is unchanged).

Then stop. Report, and leave merging to Logan.
