# Future

Unscheduled work. Each section has enough in it to become a brief; a section that gets scheduled
gains a line pointing at its brief.

## Integrations and default settings

**Next.** Logan wanted it after the replacements, which brief 03 added (2026-10-19).

The pack is mods with their default configs. This brief makes them work together and sets
defaults a new instance starts with.

- **The question:** which cross-mod gaps are worth bridging, and which defaults a fresh instance
  should ship.
- **Known candidates:**
  - KubeJS recipes for Ad Astra's materials through Create (the Create Ad Astra mods have no
    1.21.1 build; decisions table).
  - Almost Unified's config, so the pack's many ore and ingot sources collapse to one item each.
  - Keybind conflicts: Logan hasn't been through Controlling's list yet. A default `options.txt`
    (or a keybind config mod) could ship the resolved set.
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

- **Client-side rules.** Logan's first launch stopped on two dependency rules the server never
  evaluates: Petrolpark's `side = "CLIENT"` JEI range, and Supplementaries' incompatibility with
  Sodium below 0.8.12-beta.1, a client-only mod. Brief 02's fix session caught both with a
  resolver: sync the client set with packwiz-installer `-s client` into a scratch folder, read
  every `neoforge.mods.toml` (nested jars too), and test each rule with the Maven range classes
  NeoForge uses. Folding that into the check changes what a pass means, so it's a brief, not a
  side change.
- **Known-noise ERROR lines.** Every boot logs about 675 ERROR lines, nearly all loot tables and
  recipes for absent compat mods (`railways` alone is 492, then `create_connected`,
  `create_ironworks`). The summary prints the first 20, so a real error is buried. A filter for
  known-noise sources would make the summary useful again.
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

## Better Combat, and combat as a direction

**Scheduled:** [brief 06](06-better-combat-trial.md), a trial on its own branch with Combat Roll
and Apothic Combat, ending in Logan's go or no-go (2026-10-19).

Logan turned Better Combat down for brief 03 but wants it noted as a possible direction to
explore (2026-10-19).

- **The question:** whether melee in this pack should change, given guns (TaCZ), spells (Iron's,
  Ars) and Apotheosis gear are already the main ways to fight.
- **What's known:** Better Combat `2.4.0+1.21.1-neoforge` (Modrinth `better-combat`) needs
  playerAnimator, already in, and Cloth Config, which isn't (this section said both were in until
  2026-10-19). Apothic Combat (`apothic-combat`) bridges it with Apotheosis; its last 1.21.1 build
  is 2025-01-19. How it behaves alongside TaCZ isn't known. "Don't Punch My TACZ" was once read
  here as a hint that the area is fiddly. It fixes TaCZ's clashes with Punchy, a different
  animation mod that isn't in the pack, so it says nothing about Better Combat.
- **Likely shape:** an ideate run on combat first, then a small brief with a world to try it in.
  The ideate run happened on 2026-10-19 and produced brief 06.
- **Kill criteria:** if it fights TaCZ's aiming or firing, it stays out.

## Melee parity

After brief 06's go or no-go, and after Logan has played with guns in a real world. Logan wants it
as a pass of its own, after the trial (2026-10-19).

- **The question:** once melee feels better (or doesn't), is it worth using next to guns? A TaCZ
  rifle hits from 60 blocks and a sword reaches 3, and that's a numbers problem that Better Combat
  doesn't touch.
- **Likely shape:** config and datapacks, not mods:
  - TaCZ's server-side damage settings, and TaCZ Tweaks if it has the knobs.
  - Apotheosis' boss and invader spawn rates, so more fights happen up close.
  - Better Combat weapon attribute data for the modded weapons the fallback patterns miss
    (Cataclysm, Mowzie's, Alex's), if the trial went.
  - Combat Roll's server config (cooldown, invulnerability frames, which are off by default).
- **Input it needs:** Logan's verdict from brief 06's last hand check, and a few hours of play.
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
- **FTB Quests and FTB XMod Compat.** A new pack has no quest book. Back when there's a quest
  brief.
