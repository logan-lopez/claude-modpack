# Brief 06: Better Combat and Combat Roll trial

**Size:** S. Four entries that resolved in a dry run and booted in a scratch copy. Most of the
verdict is Logan's hand checks, which don't count toward the size.

Read `CLAUDE.md`, [`README.md`](README.md), [the server check page](../architecture/server-check.md),
[the mod list](../guide/mods.md), [the guns page](../guide/guns.md) and [`FUTURE.md`](FUTURE.md)'s
"Better Combat, and combat as a direction" first. Prerequisite: [brief 05](05-backups-pregen-and-sound.md)'s
commits are on `main`, so the trial branch starts from the frozen list and `index.toml` doesn't
conflict later.

## Goal

A trial that ends in **go or no-go**, not a merge. Guns in this pack take skill: aiming down
sights, recoil, attachments. Melee is vanilla click-on-cooldown. Better Combat gives melee weapons
combos, swing arcs and two-handed movesets. Combat Roll adds a dodge on a key, which helps a sword
player close distance and a gun player get out of a bad spot. Apothic Combat makes Better Combat
and Apotheosis agree on what a heavy weapon is. This brief puts the four entries on a branch, gets
them through the server check, writes down what Logan should test, and hands it to him. His hand
checks decide whether it merges.

Balancing melee against guns (damage numbers, weapon data for modded weapons) is **not** this
brief. It waits until the trial is decided and Logan has played with it ([`FUTURE.md`](FUTURE.md),
"Melee parity").

## Decisions already made

Logan made these calls on 2026-10-19 (an ideate run, then a Parley round). Don't revisit silently.

- **The mods:** Better Combat (`better-combat`), Combat Roll (`combat-roll`), Apothic Combat
  (`apothic-combat`), and Cloth Config (`cloth-config`), which Better Combat needs.
- **Apothic Combat is in,** knowing its cost. It registers Better Combat's two-handed weapons as
  Apotheosis heavy weapons, and in exchange it removes the entity reach attribute from weapons and
  makes Apotheosis' attack-range affix do nothing. How Apotheosis and Better Combat get along is
  half of what the trial tests.
- **Its own branch:** `better-combat-trial`, from `main`. It's merged on go and deleted on no-go,
  and `main` stays frozen until Logan decides. The merge and the delete are Logan's.
- **The kill rule** from `FUTURE.md` stands: if Better Combat or Combat Roll gets in the way of
  aiming or firing a TaCZ gun, both come out.
- **No configs.** All four run on their defaults, keybinds included. The resolved keybind set
  ships with the integrations brief.
- **After brief 05,** which is the last content before the freeze. Better Combat adds no blocks or
  items, so it can come into or out of a running world.

## Already checked

All 2026-10-19, against the Modrinth v2 API, each jar's `META-INF/neoforge.mods.toml`, and the
jars' bytecode (`javap -c`).

- **Dry run.** In a scratch copy of `pack/`, `packwiz -y modrinth add` with `better-combat`,
  `apothic-combat` and `combat-roll` gave four new entries, all `side = "both"`:
  - `better-combat` 2.4.0+1.21.1-neoforge (`bettercombat-neoforge-2.4.0+1.21.1.jar`, 2026-07-14)
  - `cloth-config` 15.0.140+neoforge, which packwiz pulled for Better Combat
  - `apothic-combat` 1.2.1+1.21.1 (`apothiccombat-1.2.1.jar`, 2025-01-19)
  - `combat-roll` 2.0.6+1.21.1-neoforge (`combat_roll-neoforge-2.0.6+1.21.1.jar`, 2025-12-17)
- **`FUTURE.md` was wrong on two counts,** corrected there while writing this brief:
  - Cloth Config was **not** in the pack. Only playerAnimator was (`playeranimator.pw.toml`,
    2.0.4+1.21.1).
  - "Don't Punch My TACZ" fixes TaCZ's clashes with **Punchy**, a first-person animation mod that
    isn't in this pack. It says nothing about Better Combat. Leave it out.
- **Dependencies:**
  - Better Combat needs playerAnimator `[1,)` and `cloth_config` `[15.0.0,)`.
  - Combat Roll needs playerAnimator `[1,)`. Modrinth lists Cloth Config for it too, but its jar
    doesn't require it.
  - Apothic Combat needs `bettercombat` `[2.1.3,)` and `apotheosis` `*`. Any Apotheosis passes
    the loader, so a mismatch with Apotheosis 8.9.0 wouldn't stop it loading. It would show up as
    an error or wrong behavior during play. That's why the hand checks cover Apotheosis.
- **Keybinds.** Default key codes read from each jar's bytecode:
  - Combat Roll's roll is **R** (82). Its Modrinth page says the same.
  - TaCZ: reload **R**, melee V, crawl C, inspect H, fire select G, interact O.
  - Iron's Spells binds **R** and **V** too. Which of its actions take them wasn't read.

  So R would carry three mods. Brief 02 left Controlling's conflict list for Logan, and it's still
  unchecked.
- **Better Combat's fallback.** It gives movesets to items with no weapon data by matching the
  item ID against patterns in `FallbackConfig`. Some of them: `sword|blade`, `dagger|knife`,
  `mace|hammer|flail`, `katana`, `spear`, `claymore|great_sword|greatsword`, and
  `staff|wand|sceptre|stave|rod`. So Silent Gear's swords and katanas should get movesets. Iron's
  staves and Ars wands may get a melee swing too, which the hand checks have to cover. TaCZ guns
  are one item (`tacz:modern_kinetic_gun`) that matches none of them.
- **The scratch boot.** `scripts/server-check.sh`, copied into a scratch root, was run against
  that scratch copy with these four and brief 05's three. It **passed**: 271 jars, 299 mods
  loaded, Done in 21 s. None of the 678 ERROR lines came from these four. Their only log line at
  WARN or above was `Reference map 'apothiccombat.refmap.json' ... could not be read`, which Mixin
  logs for many production jars and isn't a failure. No mixin failed to apply. So Apothic Combat
  **loads** against Apotheosis 8.9.0. Whether it **works** there is still a hand check.
- **The configs the scratch boot generated:**
  - `config/bettercombat/server.json5` has `"fallback_compatibility_enabled": true`.
    `config/bettercombat/fallback_compatibility.json` has `"blacklist_item_id_regex":
    "pickaxe"`, then the patterns above.
  - `config/combat_roll/server.json5`: `roll_cooldown` 4.0 seconds, `invulnerable_ticks_upon_roll`
    0 (no invulnerability frames), and `allow_rolling_while_weapon_cooldown` false. During a roll
    the player can't use items, attack or jump, so a gun can't fire mid-roll.

## Open questions

- **Combat Roll's key for the trial.** Default: leave it on R and say in the guide page that it
  clashes with TaCZ's reload, with a suggestion to rebind it in Controlling. Logan picks the key
  in game and records it in his hand-check notes, for the integrations brief.

## Shape

### How to add

On a new branch `better-combat-trial` from `main`. From `pack/`: `packwiz -y modrinth add
better-combat` (accept Cloth Config), then `apothic-combat`, then `combat-roll`. If the project name
packwiz prints doesn't match, it fell back to a search: remove it and stop. If packwiz picks a
newer version than Already checked lists, read that jar's `neoforge.mods.toml` against the pack
before keeping it.

One batch, one commit on the branch: `Add Better Combat, Combat Roll and Apothic Combat (trial)`.

### The checks

- **Apothic Combat on the server.** After the server check, search `run/server/logs/latest.log`
  for `apothiccombat`, `bettercombat` and `combat_roll` lines at WARN or above, and for any
  mixin that failed to apply (`Mixin apply`, `InvalidMixinException`). Quote them in the report.
  Not finding any doesn't prove it works with Apotheosis 8.9.0, so say that too.
- **Better Combat's server config.** Confirm `run/server/config/bettercombat/server.json5` and
  `fallback_compatibility.json` say what Already checked lists, and report any difference.
- **The client-side rule check,** as brief 03 did it (its Shape, with the two fixes from its
  Deviations). Nothing here is client-only, but Better Combat and Combat Roll declare
  `side="BOTH"` dependencies that only the client check reads as a set. Expect the seven known
  Minecraft ranges and nothing else.

### Docs

On the branch, so they go wherever the trial goes.

- **`docs/guide/combat.md`, new: "Fighting up close."** For Logan in game:
  - Better Combat's movesets: combos, swing arcs that hit more than one mob, two-handed weapons,
    dual wielding. Which weapons get them: vanilla ones, and modded ones whose IDs match the
    fallback patterns (Silent Gear's among them).
  - Combat Roll: the key (R by default, which clashes with TaCZ's reload, so rebind it in
    Controlling), the cooldown, one roll by default. Its enchantments: extra rolls on helmets,
    faster recharge on chestplates and leggings, longer rolls on boots.
  - Apotheosis: two-handers count as heavy weapons, and the attack-range affix does nothing.
  - Guns: unchanged. Better Combat leaves TaCZ guns alone.
  - What it doesn't do yet: no weapon data for Cataclysm, Mowzie's or Alex's weapons beyond what the
    fallback catches, and no balancing between melee and guns.

  Add a line for it in `docs/guide/README.md`.
- **`docs/guide/mods.md`:** update the counts. Better Combat, Combat Roll and Apothic Combat go in
  a new "Combat" group, or under Apotheosis for Apothic Combat. Cloth Config goes under Libraries.
  The Known rough edges entry about Sound Physics' missing settings screen (from brief 05) goes,
  because Cloth Config gives it one.
- **`docs/guide/guns.md`:** one line under Not here or a new short section, saying Better Combat
  doesn't touch guns, and linking `combat.md`.

`FUTURE.md` already has its "Scheduled" line and the corrected facts. The README's decisions table
and `FUTURE.md` change only after Logan's verdict, and that's `wrap`'s job, not this brief's.

## Out of scope

- Any config for the four mods, keybinds included: the integrations brief.
- Weapon attribute data for Cataclysm, Mowzie's, Alex's or other modded weapons, and any damage
  balancing between melee and guns: `FUTURE.md`, "Melee parity."
- Epic Fight, Don't Punch My TACZ, Punchy, or any other combat or animation mod.
- Merging the branch, or deleting it. Both are Logan's after his hand checks.
- `main`: nothing in this brief is committed there.

## Build order

1. `git switch -c better-combat-trial main`.
2. Add the four entries, run `scripts/server-check.sh`, then `git status --short pack/`. Only new
   files should show, plus `index.toml` and `pack.toml`. On a failure, follow brief 02's Build
   order step 1. If Apothic Combat is what fails, drop it, carry on with the other three, and say
   so at the top of the report: that's Logan's call to revisit.
3. The Apothic Combat log check, Better Combat's config, and the client-side rule check.
4. No duplicate filenames. Run the server check twice more.
5. The docs, then `scripts/export.sh`. Commit on the branch, staging `pack/` and the docs by name.

`packwiz serve` for Prism may be holding 8080: use `CHECK_PORT=8081`.

## Acceptance

- `git branch --show-current` prints `better-combat-trial`, and `git log main..better-combat-trial`
  shows only this brief's commits.
- `scripts/server-check.sh` exits 0 on the branch, twice in a row. Paste both summaries and the
  ERROR-line count, and account for any change from brief 05's count by source.
- `better-combat.pw.toml`, `cloth-config.pw.toml`, `apothic-combat.pw.toml` and
  `combat-roll.pw.toml` exist, each `side = "both"`.
- `grep -h '^filename' pack/mods/*.pw.toml pack/tacz/*.pw.toml | sort | uniq -d` prints nothing.
- The report quotes the Apothic Combat log check and Better Combat's fallback setting.
- The client-side rule check flags nothing beyond the seven known Minecraft ranges.
- `scripts/export.sh` writes the `.mrpack`.
- `python3 -I ~/.claude/skills/brief/scripts/checklinks.py .` reports 0 broken.

**Logan, by hand.** These decide go or no-go. In Prism, re-sync from a `packwiz serve` run on the
`better-combat-trial` branch, and use a **new world**, since the branch may be thrown away. Any
**kill** item failing means no-go.

- **Kill:** with a gun from each gun pack (TaCZ default, Elite X, Fallout, Create Armorer),
  left-click fires and right-click aims, with the off hand empty and with a shield or torch in it.
- **Kill:** TaCZ's melee key (V) still does a gun's melee or bayonet attack, and reloading works
  after Combat Roll is rebound off R.
- Combat Roll: rebind it in Controlling and note the key you chose. A roll moves you about three
  blocks in the direction you're moving, then goes on cooldown. Rolling with a gun drawn doesn't
  break aiming afterwards.
- A vanilla sword and axe swing with Better Combat's animations and combo. A Silent Gear sword or
  katana does too.
- Iron's Spells and Ars Nouveau still cast from their staves and wands. Note whether those now
  swing like weapons too, and whether that's a problem.
- A Better Combat two-hander (a vanilla-fallback greatsword, if one exists in the pack) shows
  Apotheosis' heavy-weapon affixes. An Apotheosis weapon with an attack-range affix shows no
  error, and the affix does nothing, as expected.
- A Cataclysm or Mowzie's weapon still attacks, whether or not it gets a moveset.
- Carry On, Create's wrench and extendo grip, and MmmMmmMmmMmm's target dummies still behave.
- **Your verdict:** does melee now feel like a real choice next to guns, or just a different
  animation on a weaker option? Your answer sets up the Melee parity pass.

Then stop. Report on the branch, and leave the go or no-go, the merge and the branch to Logan.
