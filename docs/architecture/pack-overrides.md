# Pack overrides

The files the pack ships besides mods: configs, and recipes and tags that repair or extend what the
mods ship. They reach the server check and Logan's instance through the same packwiz sync as the
mods.

**Sources:** `pack/config/`, `pack/kubejs/`

## What lives where

- **`pack/config/`:** mod configs, copied to the instance's `config/`. Today that's Almost
  Unified's `almostunified/unification/materials.json`, and the quest book.
- **`pack/config/ftbquests/quests/`:** FTB Quests' quest book. It has its own format, rules and
  check: [the quest book](quests.md).
- **`pack/kubejs/data/`:** a datapack KubeJS always loads, so recipes and tags here need no
  script. Laid out like any datapack: `data/<namespace>/recipe/...`, `data/<namespace>/tags/...`.
  - **Repairs** of a mod's recipe use the mod's own namespace and path, so they replace it:
    `create_compressed/recipe/...`, `createdeco/recipe/placard.json`.
  - **The pack's own recipes** use the `claude_modpack` namespace, so they can't collide with a
    mod's: `claude_modpack/recipe/ad_astra/{pressing,crushing}/`, Create pressing and crushing for
    Ad Astra's desh, ostrum and calorite.
  - **Tag changes** use the tag's own path: `ad_astra/tags/fluid/fuel.json` replaces Ad Astra's
    rocket fuel list with `"replace": true`.
- **`pack/kubejs/server_scripts/`:** none yet. KubeJS's generated `main.js` on the server isn't
  the pack's.

packwiz indexes every file under `pack/`. A file with no `.pw.toml` has no side, so the server
sync (`-s server`) installs it, and so does the client sync. Deleting a file from `pack/` deletes
it from the instance at the next sync.

## Overriding a mod's data

A file in `pack/kubejs/data/` at the same ID as one in a mod's jar wins: the seven Create
Compressed recipes and Create Deco's placard stopped logging parse errors and load from the pack's
copies (brief 07). So does a tag file with `"replace": true`. No script is needed for either.

Copy the mod's file from its jar and change only what's broken. Create 6's processing recipes
write results as `{"id": ...}` (with `count` and `chance`), and a fluid ingredient as
`{"type": "neoforge:single", "amount": ..., "fluid": ...}`. Item ingredients still use `"item"`
or `"tag"`.

**A `ServerEvents.recipes` script changes the error log.** With one present, KubeJS parses every
recipe itself and logs the failures as WARN lines in `logs/kubejs/server.log`, and some recipes
that failed in `latest.log` stop appearing there (Silent Gear's netherwood recipes, seen in brief
07). The first such script will show those as gone in the server check: refresh the baseline in
the same commit and say why.

## Almost Unified

`materials.json` pins the file Almost Unified 1.4.2 generated on a first boot, with two changes:
`ignored_recipe_ids` lists the Create recipes its unification broke (Silent Gems ore crushing,
and Create Misc and Things' copper scaffolding), and `mod_priorities` drops `pneumaticcraft` and
`create_dd`, which aren't in the pack. Almost Unified didn't rewrite it on load: the server's copy
matched `pack/`'s after a boot.

Copper scaffolding still fails: its result is `create_things_and_misc:deleted_mod_element`, an
item the mod doesn't have. It stays in the ignore list and in the baseline.

## Configs and single-player

NeoForge 21.1 puts server configs (`*-server.toml`) in `config/`, not in the world's
`serverconfig/` (only the FTB mods still use that). So a server config in `pack/config/` applies
to Logan's single-player worlds too. Whether packwiz-installer overwrites a config the player has
changed in the instance hasn't been checked.

## Seeing a fix take

The server check's [known-errors baseline](server-check.md#the-known-errors-baseline) is how. A
repaired recipe shows as gone in the summary; a fix that breaks something shows as new. Then
`CHECK_UPDATE_BASELINE=1` records it, and the baseline's diff should only remove lines.

A recipe that loads without an error can still be missing. To confirm one exists, a throwaway
server script can log `event.countRecipes({ id: '<id>' })` from `ServerEvents.recipes`, and a tag
`event.get('<tag>').getObjectIds()` from `ServerEvents.tags`, read in
`run/server/logs/kubejs/server.log`. Delete it before committing; the recipes listener shifts the
error log (above).
