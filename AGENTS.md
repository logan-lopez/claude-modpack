# AGENTS.md: instructions for agents in `claude-modpack`

## The project

A Minecraft 1.21.1 modpack, built with Claude Code doing most of the assembly, partly to see how
well that works. It's a packwiz pack in `pack/` on NeoForge, played through Prism Launcher, and
checked by booting a headless server.

Handoff briefs are in `docs/briefs/`. Start with `README.md`; unscheduled ones are in `FUTURE.md`,
and finished ones move to `archive/`. The decisions not to relitigate are the table in
`docs/briefs/README.md`.

## Commands

| Command | Run from | What it does |
| --- | --- | --- |
| `scripts/server-check.sh` | the repo root | Boots a headless NeoForge server from `pack/`. Exit 0 means it reached Done with no mod-loading failure. |
| `scripts/export.sh` | the repo root | Writes `dist/<name>-<version>.mrpack`. |
| `packwiz modrinth add <slug>` | `pack/` | Adds a mod. Modrinth first; `packwiz curseforge add` only when a mod isn't on Modrinth. |

packwiz may not be on `PATH`: it's in `$(go env GOPATH)/bin`, where the scripts look for it.

## Rules

- **Every change to the mod set ends with a passing `scripts/server-check.sh`.** Adding, removing
  or updating a mod, or changing the NeoForge version. Paste its summary into the report. A pass
  says nothing about the client: list what needs a hand check.
- **Don't commit `run/` or `dist/`.** They're the throwaway server, the cached jars and the
  exports.

### Areas

`docs/architecture/` has one page per area, describing the code as it is now. Before changing code
in an area, read its page. When a change makes a sentence on a page untrue, fix the page in the same
commit. A new area gets a page, a row here and a pointer in `.claude/rules/` (Claude Code loads the
matching one by itself; this table is the same map for every agent).

| Code | Read first |
| --- | --- |
| `pack/config/**`, `pack/kubejs/**` | [Pack overrides](docs/architecture/pack-overrides.md) |
| `scripts/server-check.sh`, `scripts/server-check.known-errors.txt` | [The server check](docs/architecture/server-check.md) |
