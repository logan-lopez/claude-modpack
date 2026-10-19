# Brief 03: Replacements for what didn't come over, and new mods

**Size:** S. Twenty-one picks, all resolved by packwiz in a dry run, added in four batches.

Read `CLAUDE.md`, [`README.md`](../README.md), [the server check page](../../architecture/server-check.md),
[the mod list](../../guide/mods.md) and [`FUTURE.md`](../FUTURE.md)'s "Replacements for what didn't
come over, and new mods" first. [Brief 02](02-port-old-mod-list.md)'s Build order is the
pattern this one follows. No prerequisites: brief 02 has landed.

## Goal

Brief 02 brought over the old 1.20.1 pack's mods that had NeoForge 1.21.1 builds, and left a
dozen behind. This brief adds a 1.21.1 mod for each role Logan wants back, and eight suggestions
he picked from a list pitched against the pack (Create, TaCZ, Apotheosis, magic, exploration).
Each batch passes the server check. The mod list guide page says what replaced what.

## Decisions already made

Logan picked every mod below in a Parley round, 2026-10-19. Don't revisit silently.

- **Replacements:** Alex's Mobs Continued and its Delight addon (for Alex's Mobs and Alex's
  Delight), My Nether's Delight (Nether's Delight), Construction Wand's KOTS fork (Construction
  Wand), Lamb Lanterns with LambDynamicLights (Curious Lanterns), DodoSpyglass (Spyglass of
  Curios), Create: Immersive TaCZ Integration (Create TaCZ Automation), Create: Recycled (Create
  Recycle; a different mod in the same role), and Sodium Extra, Reese's Sodium Options and
  Chloride.
- **Suggestions taken:** L_Ender's Cataclysm with Apothic Category Compat, Mowzie's Mobs,
  Naturalist, Create: The Factory Must Grow, Create: Dreams & Desires, Ars Creo, Towns and Towers,
  Repurposed Structures, End's Delight, Chef's Delight.
- **Turned down:** Friends & Foes, The Twilight Forest, Create Aeronautics. Polymorph and Better
  Combat are noted in `FUTURE.md` instead.
- **Sodium stays at 0.8.12,** pinned with Iris 1.8.14-beta.1. The newest Sodium Extra (0.9.4)
  and Reese's (2.2.4) need Sodium 0.8.13, so this brief takes the last builds that accept 0.8.12
  and pins them.
- **No replacement** for Apotheotic Additions, Apothic Curios, Delightful or Silent's Delight
  (none found). Create × Ad Astra stays for the integrations brief (KubeJS).

## Already checked

All 2026-10-19, against the Modrinth v2 API and the jars' own `META-INF/neoforge.mods.toml`.

- **Dry run.** Every slug in Shape was added with `packwiz -y modrinth add` to a scratch copy of
  `pack/` (the two Sodium add-ons by version ID). Each resolved to the project named in Shape, at
  the version listed there. packwiz pulled three libraries: CodxLib (`codxlib`, for Alex's Mobs
  Continued), Lionfish API (`lionfish-api`, for Cataclysm) and Cristel Lib (`cristel-lib`, for
  Towns and Towers). No existing `.pw.toml` changed. 26 new entries.
- **LambDynamicLights.** Modrinth lists Fabric API as a required dependency of its NeoForge
  build, but the jar's `neoforge.mods.toml` only requires its own nested runtime, and packwiz
  didn't pull Fabric API. If it ever does, remove it: it's a Fabric mod.
- **Brief 02 was wrong about Alex's Mobs:** it checked the official project. Two ports exist.
  `alexs-mobs-continued` is the active one (2026-10-16, needs CodxLib); `alexs-mobs-1.21.1`
  hasn't had a release since 2026-01.
- **Against the pins** (JEI 19.56.0.441, Sodium 0.8.12, Iris 1.8.14-beta.1), from each jar's
  dependency list at the versions in Shape:
  - Sodium Extra 0.9.3 (`iJsZtWpc`) needs Sodium `[0.8.12+mc1.21.1,)`; 0.9.4 needs `0.8.13`.
  - Reese's Sodium Options 2.2.3 (`KYgu9tXl`) needs Sodium `[0.8.12,)`; 2.2.4 needs exactly
    `0.8.13`. Every 2.2.x declares `sodiumoptionsapi` incompatible, so Sodium Options API, its
    Mod Compat and Sodium Dynamic Lights (which needs Options API) stay out for good.
  - Chloride 1.8.1 needs Sodium `[0.8.12,)` and NeoForge `[21.1.170,)`.
  - None of the picks names JEI. Only Lamb Lanterns names Iris (optional, `[1.8.0,)`).
- **Against Create 6.0.10 and the rest:** Dreams & Desires needs Create `[6.0.9,6.1.0)`; TFMG
  `[6.0.6,)`; Ars Creo `[6.0.9,)` and Ars Nouveau `[5.0.0,)`; Immersive TaCZ Integration Create
  `[6.0.0,)` and any `tacz`, NeoForge `[21.1.228,)`; Apothic Category Compat Apotheosis `[8.5,9)`
  (the pack has 8.9.0); Cataclysm Curios `[9.2.2+1.21.1,)` (the pack has 9.5.1); Lamb Lanterns
  NeoForge `[21.1.228,21.2)` and Curios.
- **Sides.** Sodium Extra, Reese's, Chloride and LambDynamicLights are client-only: the server
  check never loads them. Lamb Lanterns is on both sides (its Curios slot), with its
  LambDynamicLights dependency client-side only.

## Open questions

- **Memory.** 26 more entries on top of 251. If the client needs more than 8 GB now, Logan will
  see it at launch. Default: note it in the spot checks; change nothing.

## Shape

### How to add

From `pack/`, as in brief 02. `packwiz -y modrinth add <slug>` for each; if the project name
packwiz prints doesn't match Shape, it fell back to a search: remove it and stop. Accept required
dependencies only. The two pinned add-ons:

```sh
packwiz -y modrinth add --project-id sodium-extra --version-id iJsZtWpc
packwiz -y modrinth add --project-id reeses-sodium-options --version-id KYgu9tXl
packwiz pin sodium-extra && packwiz pin reeses-sodium-options
```

If packwiz picks a newer version than Shape lists for any other mod (a release since
2026-10-19), read that jar's `neoforge.mods.toml` against the pins before keeping it.

### The mods

By batch, in build order. Version checked in brackets.

**1. Mobs and bosses.** `alexs-mobs-continued` (2.2.3), `alexs-mobs-continued-delight` (1.0.1),
`naturalist` (2.0.5), `mowzies-mobs` (1.8.2), `l_enders-cataclysm` (3.33),
`apothic-category-compat` (2.1.0).

**2. Create.** `create-tfmg` (1.2.0), `create-dreams-and-desires` (2.3a-BETA), `ars-creo`
(5.4.0), `create-immersive-tacz-integration` (1.6), `createrecycled` (1.0.0).

**3. Food, building and structures.** `my-nethers-delight` (1.10.4.1), `ends-delight` (2.6.1,
beta), `chefs-delight` (1.0.6), `construction-wand-kots` (2.16.12),
`dodospyglass-spyglass-curios-compat` (2.0.0), `towns-and-towers` (1.13.11),
`repurposed-structures-forge` (7.5.22).

**4. Client.** `lambdynamiclights` (4.8.11), `lamb-lanterns` (1.2.0), `chloride` (1.8.1), and
Sodium Extra 0.9.3 and Reese's 2.2.3 pinned (How to add).

### The client-side rule check

The server check can't see a rule that lives in a client-only mod or a `side = "CLIENT"`
dependency; both of Logan's first-launch errors were these. Until the server check covers it
(`FUTURE.md`), do it by hand once, after batch 4:

1. Sync the client set into a scratch folder: `packwiz serve` on a free port, then
   packwiz-installer-bootstrap (cached in `run/cache/`) with `-g -s client` and the served URL,
   from inside that folder.
2. For every jar in it, nested jars too (`META-INF/jarjar/`), read `META-INF/neoforge.mods.toml`
   and check each `required` dependency's `versionRange` and each `incompatible` one against the
   installed mod versions. A rough script is fine; it goes in the scratchpad, not the repo.
3. Report what it flags. Brief 02's run flagged seven mods with a Minecraft range of
   `[1.21,1.21.1)` that NeoForge loads anyway (JEI, Iris, Productive Bees, When Dungeons Arise,
   both compasses, Clean Swing); those are known and not failures. Anything else is: fix it with
   an older version of the new mod, or drop it.

### Docs

- **`docs/guide/mods.md`:**
  - The entry count.
  - A new "Mobs and bosses" group.
  - The other new mods in their groups.
  - A "Replaced" table: old mod → what stands in for it.
  - Rows taken out of Left behind as they're replaced. Apotheotic Additions, Apothic Curios,
    Delightful and Silent's Delight stay, with "No 1.21.1 build, and no replacement found". The
    Sodium add-ons row becomes Options API, Mod Compat and Sodium Dynamic Lights, with the
    Reese's incompatibility as the reason.
  - Sodium Extra and Reese's under Held back on purpose.
- **`docs/briefs/FUTURE.md`:** take this section out, and take "Sodium add-ons" out (this brief
  settles it).
- **Root `README.md`:** the mod list line if "about 200" no longer reads right.

## Out of scope

- Configs, KubeJS, recipe changes, default settings: the integrations brief.
- Any mod not picked above, including the turned-down ones and Polymorph and Better Combat.
- Moving Sodium, Iris or JEI off their pins.
- Folding the client-side rule check into `scripts/server-check.sh`: its own brief.

## Build order

Commit after each batch that passes, staging `pack/` by name, `pack/pack.toml` and
`pack/index.toml` included (brief 02 missed `pack.toml` in its intermediate commits), with a
message like `Add batch 1: mobs and bosses`.

1. For each batch: add the mods, run `scripts/server-check.sh`, then
   `git status --short pack/mods` (only new files; a modified one means an overwrite: restore
   it). On a failure, the same rules as brief 02's Build order step 1: add a missing dependency,
   try the next-older 1.21.1 NeoForge version, or `packwiz remove` it and record why.
2. After batch 4, the client-side rule check.
3. No duplicates across the pack; the server check twice more on the final pack.
4. The docs, then `scripts/export.sh`.

`packwiz serve` for Prism may be holding 8080: use `CHECK_PORT` as brief 02 did.

Stop and ask Logan if Cataclysm, Alex's Mobs Continued or TFMG won't load, or if more than four
picks have to be dropped.

## Acceptance

- `scripts/server-check.sh` exits 0 on the final pack, twice in a row. Paste both summaries and
  the ERROR-line count. Brief 02's pack logged 641; TFMG's arrival should make some of the
  compat recipe errors go away. Say whether the count moved, and group any new sources.
- Every slug in Shape has a `.pw.toml` in `pack/mods/`, or a line in the report and a row in the
  guide saying why it was dropped.
- `grep -h '^filename' pack/mods/*.pw.toml | sort | uniq -d` prints nothing.
- `sodium-extra.pw.toml` names 0.9.3 and `reeses-sodium-options.pw.toml` 2.2.3, both with
  `pin = true`. `sodium`, `iris` and `jei` are unchanged and still pinned.
- No `fabric-api.pw.toml`.
- The client-side rule check flags nothing beyond the seven known Minecraft ranges.
- `scripts/export.sh` writes the `.mrpack`.
- `python3 -I ~/.claude/skills/brief/scripts/checklinks.py .` reports 0 broken.

**Logan, by hand** (re-sync the Prism instance from `packwiz serve` first):

- The client launches with the instance's memory at 8192 MB. If it doesn't, try more and say
  what it took.
- Video Settings show Reese's reorganized menu with Sodium Extra's pages, and a shader pack still
  loads in Iris.
- Hold a torch: the light moves with you (LambDynamicLights). A lantern in its Curios slot does
  the same (Lamb Lanterns). The spyglass in its Curios slot zooms on its key (DodoSpyglass; check
  Controlling for the key and any conflict).
- JEI shows Cataclysm, Mowzie's, Alex's Mobs, TFMG, Dreams & Desires and Immersive TaCZ recipes.
- In a new world, a Naturalist or Alex's animal turns up, and a Towns and Towers village or a
  Repurposed Structures variant generates.

Then stop. Report, and leave merging to Logan.

## Report

### Built

- **`pack/`:** 26 new entries in four batches, each passing the server check and committed on its
  own: 23 picks and the three libraries the dry run predicted (CodxLib, Lionfish API, Cristel
  Lib). Every slug resolved to the project and version in Shape; no existing `.pw.toml` changed,
  and packwiz didn't pull Fabric API (it printed "Failed to get latest version of dependency
  Fabric API" for LambDynamicLights and moved on). Sodium Extra 0.9.3 and Reese's 2.2.3 are
  pinned. Nothing was dropped.
- **The client-side rule check,** after batch 4: the client set (277 jars) synced with
  packwiz-installer `-s client` into the scratchpad, every `neoforge.mods.toml` read, nested jars
  included, and each rule tested. It flags exactly the seven known Minecraft ranges.
- **Docs:** the mod list guide page, `FUTURE.md`, the root README's feature line.

### Deviations

- **The brief itself was uncommitted** (with its README and `FUTURE.md` edits) when the session
  started. It went in first as its own commit, `Brief 03: replacements and new mods`, as brief
  02's did, so the batches and this report sit on top of it.
- **23 picks, not 21.** The Size line's count doesn't match the lists in Decisions and Shape,
  which have 23 between them (12 replacements, 11 suggestions). Shape's 23 are all in, and 26
  new entries is what the dry run predicted.
- **Embeddium and Oculus** moved from Left behind into the new Replaced table, since they're a
  replacement too.
- **Create Armorer isn't in,** and Create: Immersive TaCZ Integration probably does nothing
  without it. The mod's install steps call for that gun pack in `.minecraft/tacz/`; the server
  log says `Create Armorer is not installed, please download it and place it in the /tacz
  folder`. `packwiz curseforge add` on it, in a scratch copy of `pack/`, found no file for 1.21.1
  NeoForge. Gun packs are their own section in `FUTURE.md`, so the mod stays in, the guide says
  so under Known rough edges, and `FUTURE.md`'s gun pack section has the note.
- **The rule-check script needed two fixes before its verdicts meant anything.** Its first run
  flagged three more mods: New Age (`esl` missing), LambDynamicLights (its runtime missing) and
  MmmMmmMmmMmm (Moonlight out of range). All three were the script's mistakes: nested jars sit in
  `META-INF/jars/`, listed by `jarjar/metadata.json`, not in `jarjar/`; and Maven compares a `-`
  before a number as a sublist, so `1.21.1-3.7.2` is above `1.21-3.2.3`. Fixed, it flags the
  seven, and still catches both first-launch rules when fed JEI 19.57.0.1 (Petrolpark's
  `[19.53.0.426,19.57.0.0)`) or Sodium 0.6.13 (Supplementaries' incompatible `[0,0.8.12-beta.1)`).
  `FUTURE.md`'s server check section has both lessons for the brief that folds this in.

### Defaults taken

- **Memory:** nothing changed; the 8192 MB launch is in the spot checks.

### Acceptance

- **Server check, twice on the final pack:** both exit 0.

  ```
  == server check: PASS ==
  NeoForge:  21.1.264 (Minecraft 1.21.1)
  Mods:      283 loaded (incl. minecraft and neoforge), 254 jar(s) in mods/
  Boot:      47s wall, server says Done (18.632s)!
  Warnings:  675 ERROR line(s) in the log (not failing on them):

  == server check: PASS ==
  NeoForge:  21.1.264 (Minecraft 1.21.1)
  Mods:      283 loaded (incl. minecraft and neoforge), 254 jar(s) in mods/
  Boot:      47s wall, server says Done (17.679s)!
  Warnings:  675 ERROR line(s) in the log (not failing on them):
  ```

  The batches: 1 passed at 679 ERROR lines (269 loaded), 2 at 674 (274), 3 at 675 (282), 4 at
  675 (283; its five mods are client-only but for Lamb Lanterns).

  **The ERROR count moved from 641 to 675,** +34, all accounted for:

  | Change | Source | What |
  | --- | --- | --- |
  | −6 | `RecipeManager` | TFMG's own `tfmg:distillation/crude_oil*` recipes (3, logged twice), which failed until TFMG was in. TFMG's arrival cleared only these; the other compat recipes for absent mods remain. |
  | +12 | `RecipeManager` | Just Enough Breeding's Alex's Mobs recipes (6, logged twice), which load now that Alex's Mobs is in: `No key tag in MapLike[{"meat":true}]`. In the guide's Known rough edges. |
  | +26 | `DataMapLoader` | Apothic Category Compat's Apotheosis data map naming 13 weapons from mods the pack doesn't have (Lands of Icaria, Twilight Forest, Alex's Caves, Undergarden, Born in Chaos), logged twice. Noise. |
  | +1 | `RuntimeDistCleaner` | One more mod touching `AbstractClientPlayer` on the server; logged and skipped, as the other six. |
  | +1 | `CreateImmersiveTaCZ` | `Create Armorer is not installed` (Deviations). |

  The recipe errors left are 52 recipes logged twice, all owned by brief 02's mods: Create's
  Silent's Gems crushing compat (12), Silent Gear's netherwood (10), Misc and Things (6),
  Ironworks (8), Compressed (7), JEB (6), and one each from Productive Bees, Farmer's Delight
  and Deco.
- **Every slug in Shape has a `.pw.toml`:** yes, all 23, plus the three libraries. None dropped.
- **Duplicate filenames:** `grep -h '^filename' pack/mods/*.pw.toml | sort | uniq -d` prints
  nothing. Duplicate Modrinth project IDs: none either.
- **Pins:** `sodium-extra.pw.toml` names `sodium-extra-neoforge-0.9.3+mc1.21.1.jar` and
  `reeses-sodium-options.pw.toml` `reeses-sodium-options-neoforge-2.2.3+mc1.21.1.jar`, both
  `pin = true`. `git diff cb24480` on `sodium`, `iris` and `jei` is empty, and all three are still
  pinned. No existing `.pw.toml` changed at all.
- **No `fabric-api.pw.toml`:** none.
- **The client-side rule check:** 956 rules over 340 mod entries, 7 flagged, all the known
  `[1.21,1.21.1)` ranges (and Clean Swing's `[1.21,1.21z)`): When Dungeons Arise, both compasses,
  Clean Swing, Iris, JEI, Productive Bees.
- **`scripts/export.sh`:** wrote `dist/claude-modpack-0.1.0.mrpack` (18 MB).
- **`checklinks.py`:** 13 files, 0 broken.

### Size

Sized S, this session M (18 active min, 18 wall, 0 compactions). The adds went as the dry run
said; the time went on the rule-check script and on accounting for the ERROR lines.

### Spot checks for Logan

Re-sync the Prism instance from `packwiz serve` first (it's still up on 8080).

- **Memory:** the client launches at 8192 MB. If it doesn't, try more and say what it took.
- **Video Settings** show Reese's layout with Sodium Extra's pages, and a shader pack still loads
  in Iris.
- **Dynamic lights:** a held torch lights the ground as you move (LambDynamicLights). A lantern in
  its Curios slot does the same (Lamb Lanterns).
- **Spyglass:** in its Curios slot, it zooms on its key (DodoSpyglass). Check Controlling for the
  key and any conflict.
- **JEI** shows Cataclysm, Mowzie's, Alex's Mobs, TFMG and Dreams & Desires recipes. Immersive
  TaCZ's likely won't show, for want of Create Armorer: say whether anything of it is there.
- **New world:** a Naturalist or Alex's animal turns up, and a Towns and Towers village or a
  Repurposed Structures variant generates.

### Docs updated

- `docs/guide/mods.md`: the counts (277 entries, 254 on the server, 23 client-only), a Mobs and
  bosses group, the other picks in their groups, the three libraries, a Replaced table, Left
  behind trimmed (the four with no replacement say so; the Sodium row is now Options API and Mod
  Compat, with the Reese's incompatibility), Sodium Extra and Reese's under Held back, and two
  Known rough edges (Immersive TaCZ without its gun pack, JEB's six Alex's Mobs entries).
  Sodium Dynamic Lights went to Replaced (LambDynamicLights), not to the Left behind row the
  brief named.
- `docs/briefs/FUTURE.md`: the replacements and Sodium add-ons sections out; Integrations marked
  next; the server check section's ERROR count updated and the rule-check lessons added; Create
  Armorer under gun packs.
- `README.md`: the mod list line.
- No architecture page changed: `scripts/server-check.sh` wasn't touched.

### Follow-ups

- **Create Armorer**, or another way to make Immersive TaCZ Integration do something: it rides
  on the gun packs question (`FUTURE.md`). If gun packs stay out for long, the mod is dead weight
  and could come out.
- **JEB's six Alex's Mobs recipes** fail to parse. Upstream's problem; a KubeJS removal would
  quiet the log, in the integrations brief.
- **Known-noise filter:** Apothic Category Compat's data map errors are a new family for it
  (`FUTURE.md`, server check).
- **Status page:** "Where things stand" in `docs/briefs/README.md` still says about 200 mods and
  nothing in flight. `wrap` refreshes it.
