# Future

Unscheduled work. Each section has enough in it to become a brief; a section that gets scheduled
gains a line pointing at its brief.

## Integrations and default settings

**Next.** Logan wanted it after the replacements (brief 03), and the main list is now frozen
(brief 05), with Better Combat in on top (brief 06, 2026-10-19).

**Partly built:** [brief 07](07-recipe-fixes-and-ad-astra-on-create.md) took recipe repairs,
Almost Unified's config, Ad Astra's metals through Create and rocket fuel (2026-10-19). Just
Enough Breeding's unparsed Alex's Mobs recipes are in the server check's baseline now.

The pack is mods with their default configs. This brief makes them work together and sets
defaults a new instance starts with.

- **The question:** which cross-mod gaps are worth bridging, and which defaults a fresh instance
  should ship.
- **Known candidates:**
  - Keybind conflicts: Logan hasn't been through Controlling's list yet. A default `options.txt`
    (or a keybind config mod) could ship the resolved set. Known so far: Combat Roll's roll
    defaults to R, which TaCZ (reload) and Iron's Spells also bind; Logan moved it to **X** in
    his instance, "for now, might revisit" (2026-10-19). TaCZ Addon cycles guns on Tab + scroll,
    and Tab is also the player list (brief 04).
  - Simple Backups and Chunky defaults (brief 05): whether a backup every 120 minutes, keeping
    10, suits a world Logan means to keep; whether `commandsCheatsDisabled = true` is worth it,
    so a survival world without cheats can force a backup before something risky; and Chunky's
    `continueOnRestart = false`.
  - Better Combat's fallback gives Create Big Cannons' ram rod a wand moveset (its `rod`
    pattern). If that gets in the way of loading a cannon, set `blacklist_item_id_regex` to
    `pickaxe|ram_rod` in `config/bettercombat/fallback_compatibility.json` (brief 06).
  - Client defaults: render distance, a shader pack or none, JourneyMap and Jade settings.
- **How defaults ship:** packwiz includes any file under `pack/` that its index lists, so
  `pack/config/` and `pack/defaultconfigs/` go to the instance and the server. Check whether
  packwiz-installer overwrites a file the player has changed before relying on it for
  `options.txt`.
- **Memory** can't be set from the pack: it's Prism's instance setting. The playing guide says
  8 GB.
- **Kill criteria:** none; skip any default Logan has no opinion on.

## The server check: client-side rules and log noise

Two changes to `scripts/server-check.sh` from brief 02's report.

**Partly built:** the known-noise half is the known-errors baseline from
[brief 07](07-recipe-fixes-and-ad-astra-on-create.md) (2026-10-19). Client-side rules stay here.

- **Client-side rules.** Logan's first launch stopped on two dependency rules the server never
  evaluates: Petrolpark's `side = "CLIENT"` JEI range, and Supplementaries' incompatibility with
  Sodium below 0.8.12-beta.1, a client-only mod. Brief 02's fix session caught both with a
  resolver: sync the client set with packwiz-installer `-s client` into a scratch folder, read
  every `neoforge.mods.toml` (nested jars too), and test each rule with the Maven range classes
  NeoForge uses. Folding that into the check changes what a pass means, so it's a brief, not a
  side change.
- **Also seen:** the resolver flags seven mods whose Minecraft range is `[1.21,1.21.1)` (JEI,
  Iris, Productive Bees, When Dungeons Arise, both compasses, Clean Swing), yet NeoForge loads
  them on 1.21.1. A check built on the resolver has to match NeoForge here, not the range as
  written. Why NeoForge allows it isn't known.
- **What brief 03's rerun of the resolver taught it** (a throwaway Python script, 2026-10-19):
  most nested jars sit in `META-INF/jars/`, listed by `META-INF/jarjar/metadata.json`, not in
  `META-INF/jarjar/` itself; and Maven ranges compare a `-` before a number as a sublist, which
  sorts below a number (`1.21.1-3.7.2` is above `1.21-3.2.3`). Missing either gives false flags
  (New Age's `esl`, LambDynamicLights' runtime, MmmMmmMmmMmm's Moonlight range). With both, it
  flags exactly the seven Minecraft ranges, and still catches the two first-launch rules when fed
  JEI 19.57 or Sodium 0.6.13.
- **Kill criteria:** if the resolver can't match NeoForge's verdicts on the current pack (no
  false failures), keep it as a separate script rather than part of the pass.

## Melee parity

After Logan has played with guns and Better Combat in a real world. Logan wants it as a pass of
its own (2026-10-19). Brief 06's trial was a go: Better Combat, Combat Roll and Apothic Combat are
in (2026-10-19).

- **The question:** once melee feels better (or doesn't), is it worth using next to guns? A TaCZ
  rifle hits from 60 blocks and a sword reaches 3, and that's a numbers problem that Better Combat
  doesn't touch.
- **Likely shape:** config and datapacks, not mods:
  - TaCZ's server-side damage settings, and TaCZ Tweaks if it has the knobs.
  - Apotheosis' boss and invader spawn rates, so more fights happen up close.
  - Better Combat weapon attribute data for the weapons with no moveset: most of Alex's Mobs'
    (only the Skelewag Sword has one) and Cataclysm's that aren't in its own data (the Meat
    Shredder, say). Mowzie's are all covered. To list what has one, boot with
    `weapon_registry_logging` on in `config/bettercombat/server.json5` and decode the `Weapon
    Attribute assignments loaded:` log line (base64, gzip, JSON; `registrations` maps item to
    moveset). [The combat guide page](../guide/combat.md#which-weapons-get-one) has the 150 as of
    brief 06.
  - Combat Roll's server config (cooldown, invulnerability frames, which are off by default).
- **Input it needs:** Logan's answer to brief 06's last hand check (does melee feel like a real
  choice next to guns?), which he hasn't given yet, and a few hours of play.
  Balancing before that is guessing.
- **Overlaps** with Integrations and default settings: it can be a section of that brief rather
  than one of its own.
- **Kill criteria:** if melee already feels like a real choice after the trial, skip it.

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
