# Briefs

Each brief is a self-contained handoff for a fresh session. New ones go here, numbered in order,
and move to `archive/` when they're done. Ideas that aren't scheduled yet are in
[`FUTURE.md`](FUTURE.md).

## Where things stand

*Updated 2026-10-19.*

- Nothing built yet: the repo has the briefs layout and no pack.
- Minecraft 1.21.1 on NeoForge, defined with packwiz. Played through Prism Launcher.
- Next: [`01`](01-pack-skeleton-and-server-check.md), the pack skeleton, a headless server check,
  and Create and TaCZ.
- Waiting on Logan after 01: install Prism and do the hand checks.

## Open

### Other

1. [`01-pack-skeleton-and-server-check.md`](01-pack-skeleton-and-server-check.md): a packwiz pack,
   a headless server check that fails on crashes and missing dependencies, and Create and the
   TaCZ port passing it.

## Done

Archived in [`archive/`](archive/). They record what was asked for and why, not how the code works
now. For that, read `CLAUDE.md` and the code.

## Decisions already made

Don't relitigate these. If one turns out to be wrong in practice, stop and say so.

| Decision | Choice | Why |
| --- | --- | --- |
| Minecraft version | 1.21.1 | Most of the mods Logan wants are on it (Logan, 2026-10-19). |
| Mod loader | NeoForge (21.1.x) | Create and its addons, and the TaCZ port, are there (Logan, 2026-10-19). |
| TaCZ | The unofficial NeoForge port, Modrinth `tacz-1.21.1` | Official TaCZ is 1.20.1 Forge only. Logan accepted the community-fork risk (2026-10-19). |
| Pack tooling | packwiz, pack in `pack/`, Modrinth first | Text manifests pinned by hash, which Claude can read and diff; exports `.mrpack` (Logan, 2026-10-19). |
| Client | Prism Launcher with packwiz-installer auto-sync, `.mrpack` import as the fallback | Logan, 2026-10-19. |
| What a session verifies | A headless server boot (`scripts/server-check.sh`); client-side checks are Logan's | Claude can't play the game. A server boot catches crashes and missing dependencies (Logan, 2026-10-19). |

## Not built

What's deliberately absent, so nobody flags it as missing. Point at `FUTURE.md` where it applies.

## Future direction new work must not block

Each item is cheap to keep possible now and expensive to retrofit later.
