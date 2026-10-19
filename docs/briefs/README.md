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
- Next: brief 02 brings over the mods from Logan's old 1.20.1 pack that have 1.21.1 builds.
  After it, Logan compares the result with the old list and asks for additions.
- Loose ends: the server check binds Minecraft's default port 25565, so a local server already
  on it would get in the way (not seen yet); shellcheck isn't installed, so neither script has had
  a pass.

## Open

2. [`02-port-old-mod-list.md`](02-port-old-mod-list.md): the old pack's mods that have NeoForge
   1.21.1 builds, about 200, in batches that each pass the server check, and a guide page of
   what's in and what was left behind.

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
| The old pack | A guide to what Logan likes, not a port: fresh worlds, and only mods with NeoForge 1.21.1 builds. Its list is [`assets/02/old-modlist.txt`](assets/02/old-modlist.txt) | Logan, 2026-10-19. |
| MineColonies | Out, with its addons | Logan, 2026-10-19. |
| Create: Steam 'n' Rails | The community port, Modrinth `create-steam-n-rails-1.21.1` | Official stops at 1.20.1; same risk as the TaCZ port, and a fresh world has little to lose (Logan, 2026-10-19). |
| Renderer | Sodium 0.6.13 + Iris 1.8.12, both pinned | Oculus has no 1.21.1 build, and Iris 1.8.12 asks for Sodium 0.6 (Logan chose Sodium + Iris, 2026-10-19; the versions are from brief 02's checks). |
| Ad Astra | In, without its Create integrations | They have no 1.21.1 build; KubeJS can bridge recipes later (Logan, 2026-10-19). |
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
