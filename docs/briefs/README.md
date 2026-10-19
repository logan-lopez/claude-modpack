# Briefs

Each brief is a self-contained handoff for a fresh session. New ones go here, numbered in order,
and move to `archive/` when they're done. Ideas that aren't scheduled yet are in
[`FUTURE.md`](FUTURE.md).

## Where things stand

*Updated 2026-10-19.*

- Built: the packwiz pack in `pack/` on NeoForge 21.1.264 with Create and the TaCZ port, a
  headless server check, and a `.mrpack` export. Logan plays it in Prism, synced from
  `packwiz serve`, and the `.mrpack` import works too.
- In flight: nothing.
- Next: the mod list. Create addons and more mods like TaCZ need a brief: see
  [`FUTURE.md`](FUTURE.md), which starts by getting the list from Logan.
- Loose ends: the server check binds Minecraft's default port 25565, so a local server already
  on it would get in the way (not seen yet); shellcheck isn't installed, so neither script has had
  a pass.

## Open

Nothing open.

## Done

Archived in [`archive/`](archive/). They record what was asked for and why, not how the code works
now. For that, read `CLAUDE.md` and the code.

1. [`01-pack-skeleton-and-server-check.md`](archive/01-pack-skeleton-and-server-check.md) (sized
   L, was S, because the outside tools behaved as the brief's checked facts said): the packwiz
   pack, `scripts/server-check.sh` proven against a real missing-dependency failure, Create and
   the TaCZ port passing it, the `.mrpack` export, and the Prism guide.

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
| How the server check fails | On NeoForge's mod-loading log lines, a crash report, an exit before Done, or a timeout. Never on the exit code, and not on ERROR lines after a pass | NeoForge 21.1.264 exits 0 after a mod-loading failure, and big packs log harmless errors. Evidence in [the server check page](../architecture/server-check.md#decisions) (2026-10-19). |

## Not built

What's deliberately absent, so nobody flags it as missing. Point at `FUTURE.md` where it applies.

- **Client-side checks.** Nothing automated launches a client. Rendering, keybinds and how the
  guns feel are Logan's hand checks.
- **Hosting the pack.** `packwiz serve` on localhost is the only source for the auto-sync
  instance; sharing a build means sending the `.mrpack`.
- **TaCZ gun packs and the 1.20.1 pack converter.** See [`FUTURE.md`](FUTURE.md).

## Future direction new work must not block

Each item is cheap to keep possible now and expensive to retrofit later.

- **Hosting `pack/` at a public URL** (GitHub Pages, say) so the auto-sync instance works away
  from this machine. Keep everything the pack needs inside `pack/`, referenced by relative path.
