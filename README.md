# Claude Modpack

A Minecraft 1.21.1 modpack, assembled mostly by Claude Code, partly to see how well that works.
It's built around Create and Timeless and Classics Zero (TaCZ).

## Built around

- **Minecraft 1.21.1 on NeoForge** (21.1.x), where Create, its addons and the TaCZ port are.
- **TaCZ from the unofficial NeoForge port,** Modrinth
  [`tacz-1.21.1`](https://modrinth.com/mod/tacz-1.21.1). Official TaCZ is 1.20.1 Forge only, so
  addons and gun packs lag behind it.
- **packwiz defines the pack,** in `pack/`: one TOML per mod, pinned by hash, from Modrinth first.
- **A headless server boot is the check** a session can run on its own. Client-side checks are
  done by hand.

## Features

- [Playing the pack](docs/guide/playing.md) in Prism Launcher, synced from the repo on each launch,
  or imported from a `.mrpack`.
- [What's in the pack](docs/guide/mods.md): about 200 mods from the old 1.20.1 pack and two
  dozen added since, grouped by what they're for, what replaced the old mods that didn't come
  over, and what was left behind and why.

## Requirements

- Java 21. The scripts find it with `/usr/libexec/java_home -v 21`, so it doesn't have to be the
  default `java`.
- Go 1.24+ for packwiz: `go install github.com/packwiz/packwiz@latest`. The scripts also look in
  `$(go env GOPATH)/bin`, so it doesn't have to be on `PATH`.
- [Prism Launcher](https://prismlauncher.org/) to play, with at least 8 GB of memory given to the
  instance.

## Running it

```sh
scripts/server-check.sh   # boot a headless server from pack/; exit 0 means it reached Done
scripts/export.sh         # write dist/claude-modpack-<version>.mrpack
cd pack && packwiz modrinth add <slug>   # add a mod, then run the server check
```

The check downloads the NeoForge server into `run/` (gitignored) on its first run, and boots in
under a minute after that. `CHECK_PORT` (default 8080) and `CHECK_TIMEOUT` (default 300 seconds)
override its defaults. How it decides pass or fail:
[`docs/architecture/server-check.md`](docs/architecture/server-check.md).

**Running the server check accepts the [Minecraft EULA](https://aka.ms/MinecraftEULA)** for the
throwaway server in `run/server/`: the script writes `eula=true` there.

## Where the rest is

- [`docs/guide/`](docs/guide/README.md): how to play it.
- [`docs/briefs/README.md`](docs/briefs/README.md): status, open work, and decisions already made.
- [`AGENTS.md`](AGENTS.md): instructions for agents working in the repo.
