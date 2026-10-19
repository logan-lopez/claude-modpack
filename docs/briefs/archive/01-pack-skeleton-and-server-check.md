# Brief 01: Pack skeleton, server check, Create and TaCZ

**Size:** L. Live runs against outside tools nobody here has run yet: packwiz, packwiz-installer
and a NeoForge server.

Read `CLAUDE.md` and [`README.md`](../README.md) first. No prerequisites: this is the first brief.

## Goal

Get the loop working that every later brief depends on: a packwiz pack in the repo, a script that
boots a headless NeoForge server from it and fails loudly when a mod crashes or a dependency is
missing, and the two mods the pack is built around (Create and TaCZ) added and passing that
check. Logan can then play the same pack in Prism Launcher, either kept in sync automatically or
imported by hand.

The pack is also an experiment in how well Claude Code builds a modpack, so the server check
matters more than it would otherwise. It's the only thing a session can verify on its own. If it
works, later briefs can add mods in bulk and trust it.

## Decisions already made

Decided with Logan, 2026-10-19. Don't revisit them without saying so.

- **Minecraft 1.21.1 on NeoForge.** Logan's mods (Create and its addons, TaCZ) are there.
- **TaCZ comes from the unofficial port.** Official TaCZ is 1.20.1 Forge only. On 1.21.1 the
  pack uses MUKSC's NeoForge port (Modrinth `tacz-1.21.1`). Logan accepted that it's a community
  fork, and that addons and gun packs will lag behind the official mod.
- **packwiz defines the pack.** One TOML per mod, pinned by hash. Mods come from Modrinth first,
  and from CurseForge only when a mod isn't on Modrinth.
- **Client: Prism Launcher with packwiz-installer auto-sync, with a manual `.mrpack` import
  available too.** The auto-synced instance pulls from `packwiz serve` when it launches. The
  `.mrpack` export is the fallback, and the way to share a build.
- **Scope of this brief:** the skeleton, the server check, and Create and TaCZ. No addons.

## Already checked

All checked 2026-10-19.

- **NeoForge for 1.21.1** is the `21.1.x` line; the newest on the NeoForged maven is
  `21.1.264`. The installer is at
  `https://maven.neoforged.net/releases/net/neoforged/neoforge/<v>/neoforge-<v>-installer.jar`
  (it returned HTTP 200 for 21.1.264). Source: `maven.neoforged.net/api/maven/versions/...`.
- **Create** (Modrinth `create`) has `6.0.10+mc1.21.1` for NeoForge 1.21.1, published
  2026-04-21. On Modrinth it's server required, client optional, with no required dependencies.
  Source: the Modrinth v2 API.
- **The TaCZ port** (Modrinth `tacz-1.21.1`, "[UNOFFICIAL] TaCZ 1.21.1 NeoForge Port", source at
  `github.com/MUKSC/TACZ-1.21.1`, GPL-3.0) is at `1.1.8-hotfix-r7`, published 2026-10-01.
  It's required on both client and server, with no required dependencies. Worlds made with
  1.20.1 TaCZ won't load in it, and 1.20.1 gun packs need a converter mod. Sources: the Modrinth
  v2 API, and the CurseForge listing `tacz-1-21-1`.
- **Official TaCZ** (Modrinth `timeless-and-classics-zero`, GitHub `MCModderAnchor/TACZ`) has
  branches up to `1.20.1` only. Its latest release is `1.1.8-hotfix`, Forge only.
- **packwiz** (`github.com/packwiz/packwiz`) is maintained: its last commit was 2026-10-14. It
  has no GitHub releases. Install it with `go install github.com/packwiz/packwiz@latest`, which
  needs Go 1.24+ (this machine has Go 1.24.0), or from nightly.link. NeoForge is a supported
  loader (`core/versionutil.go`).
  - `packwiz init` runs without prompts given `--name`, `--author`, `--version`, `--mc-version`,
    `--modloader neoforge`, and `--neoforge-version <v>` or `--neoforge-latest`.
  - `packwiz serve` takes `-p/--port` (default 8080) and refreshes the index by default.
  - `packwiz modrinth export` takes `-o/--output`.

  Source: `cmd/init.go`, `cmd/serve.go`, `modrinth/export.go` on `main`.
- **packwiz-installer-bootstrap**'s latest release is v0.0.3 (2020), asset
  `packwiz-installer-bootstrap.jar`. Server use, per packwiz's docs:
  `java -jar packwiz-installer-bootstrap.jar -g -s server <url>/pack.toml`. `-g` turns off the
  GUI, and `-s server` downloads only the server-side mods. The docs show only HTTP(S) URLs, so
  serve the pack rather than pointing the installer at a file path.
- **Java:** the default `java` on this machine is Zulu 17. NeoForge 1.21.1 needs Java 21, and
  `/usr/libexec/java_home -v 21` finds Temurin 21.0.7. The scripts must set `JAVA_HOME` from it
  rather than trust `PATH`.
- **Launchers:** `CurseForge.app` and `Minecraft.app` are in `/Applications`. Prism Launcher
  isn't installed.

## Open questions

Each one has a default to use if Logan doesn't answer.

- **The Minecraft EULA.** The server won't start until `eula.txt` says `eula=true`. Default: the
  script writes it into the throwaway server directory, and the README says that running the
  check accepts the EULA.
- **Pack name and author in `pack.toml`.** Default: name `Claude Modpack`, author `Logan Lopez`,
  version `0.1.0`.

## Shape

### Layout

These paths are **pinned**: later briefs and the scripts depend on them.

```
pack/                     the packwiz pack: pack.toml, index.toml, mods/*.pw.toml
pack/.packwizignore       (if needed)
scripts/server-check.sh   the headless check
scripts/export.sh         builds the .mrpack
run/                      gitignored: server dir, downloaded installer and bootstrap jars
dist/                     gitignored: exported .mrpack files
```

The pack lives in `pack/`, not at the root, so packwiz's index doesn't pick up `docs/` and
`scripts/`.

### Pack

- `packwiz init` in `pack/`, with no prompts: MC `1.21.1`, `--modloader neoforge`, and the newest
  `21.1.x` NeoForge (pin whatever `--neoforge-latest` picks; the latest was 21.1.264 on
  2026-10-19).
- `packwiz modrinth add create` and `packwiz modrinth add tacz-1.21.1`, taking the newest 1.21.1
  NeoForge file of each. If packwiz asks about dependencies, accept the required ones and nothing
  optional.

### `scripts/server-check.sh`

A `#!/bin/bash` script with `set -euo pipefail`. It exits 0 when the server reaches "Done" with no
mod errors and non-zero otherwise, and either way ends with a short summary: the loader version,
the mod count, the boot time, and the failure reason with the log lines that show it.

1. `JAVA_HOME=$(/usr/libexec/java_home -v 21)`, and fail clearly if that finds nothing.
2. `packwiz refresh` in `pack/`.
3. Start `packwiz serve -p <port>` in the background, with the port from `CHECK_PORT` (default
   8080). Kill it on exit with a `trap`.
4. Server directory `run/server/`. Read the NeoForge version from `pack/pack.toml`. If the
   installed server doesn't match it, wipe the directory and run the NeoForge installer with
   `--installServer`. Cache the jars in `run/cache/`.
5. Run the bootstrap with `-g -s server http://localhost:<port>/pack.toml` in `run/server/`. Use
   a fresh world each run (delete `world/`), so a world from an earlier mod set can't hide or
   cause failures. Write `eula.txt` (see Open questions) and a fixed `level-seed` in
   `server.properties`.
6. Start the server with `nogui`, using the run script the NeoForge installer writes, with stdin
   on a FIFO or pipe so the script can send `stop`.
7. Watch `logs/latest.log` until one of these happens:
   - **Pass:** a `Done (` line. Send `stop` and wait for the process to exit.
   - **Fail:** the process exits before "Done", or a new file appears in `crash-reports/`, or the
     log hits a mod-loading failure (strings such as "Mod loading has failed" or "missing or
     unsupported mandatory dependencies"). Get the exact strings from a real NeoForge failure,
     not from memory (see Build order).
   - **Fail:** a timeout, from `CHECK_TIMEOUT` (default 300 seconds), after which the server is
     killed.
8. After a pass, also report any `ERROR` lines from the log as warnings without failing on them.
   Big packs log harmless errors, and failing on all of them would make the check useless.

### `scripts/export.sh`

Runs `packwiz modrinth export -o dist/<name>-<version>.mrpack` from `pack/`, taking the name and
version from `pack.toml`.

### Prism auto-sync

Prism isn't installed, and installing it is Logan's call: don't install it. Write the steps
instead (see Docs):

- Install Prism.
- Create a NeoForge 1.21.1 instance at the pack's NeoForge version.
- Put `packwiz-installer-bootstrap.jar` in the instance's `.minecraft/` folder.
- Set the pre-launch command to
  `"$INST_JAVA" -jar packwiz-installer-bootstrap.jar http://localhost:8080/pack.toml`.
- Run `packwiz serve` in `pack/` before launching.

Also name the manual alternative: import `dist/*.mrpack` from `scripts/export.sh`. Check Prism's
current pre-launch variable names against its docs (Context7 or the web) before writing them down.

### Docs

- **The root `README.md`** (new): what the pack is, requirements (Java 21, Go for packwiz,
  Prism), how to run the server check and the export, where the briefs are, and the EULA note.
- **`AGENTS.md`**: a Commands table (`scripts/server-check.sh`, `scripts/export.sh`, and
  `packwiz modrinth add <slug>` run in `pack/`), and the rule that every change to the mod set
  ends with a passing server check.
- **`docs/guide/README.md`** with one page, `docs/guide/playing.md`. It covers setting up Prism
  with auto-sync, the manual `.mrpack` import, and what to do when the instance won't launch.
  Its Covers line is `scripts/export.sh`.
- **`docs/architecture/server-check.md`**: how the check works, what it treats as a failure and
  why, and what it can't catch (anything client-only: rendering, keybinds, the feel of the
  guns). `**Sources:** scripts/server-check.sh`. Then run
  `python3 -I ~/.claude/skills/brief/scripts/areas.py .` to generate the Areas table and rule.
- **`.gitignore`**: `run/` and `dist/`.

## Out of scope

- Create addons, other mods, configs, KubeJS, and quests. Those are later briefs (see
  [`FUTURE.md`](../FUTURE.md)).
- TaCZ gun packs and the 1.20.1 pack converter.
- Installing Prism or launching any GUI app.
- Publishing the pack anywhere.

## Build order

1. Install packwiz with `go install`. Confirm that `packwiz --help` runs.
2. Init the pack with no mods. Write `server-check.sh` and get it passing on the bare NeoForge
   server.
3. **Prove the check catches a failure before trusting it when it passes.** Add a mod with a
   missing required dependency, or temporarily remove one, and confirm the check fails and names
   it. Record the exact NeoForge log strings it matched. Undo the change.
4. Add Create, then run the check. Add TaCZ, then run the check.
5. Write `export.sh` and produce a `.mrpack`.
6. Write the docs, then run `areas.py` and `checklinks.py`.

Stop and report if the server check can't be made reliable, meaning it passes and fails on the
same pack across runs. A flaky check is worse than none.

## Acceptance

- `scripts/server-check.sh` exits 0 on the final pack, run twice in a row. The summary names
  NeoForge 21.1.x and the mod count.
- The report records the failure run from build order step 3: the command, the exit code and the
  matched log line.
- `pack/mods/` holds `create.pw.toml` and the TaCZ port's `.pw.toml`, and both name 1.21.1
  NeoForge files.
- `scripts/export.sh` writes `dist/claude-modpack-0.1.0.mrpack` (or whatever name the pack
  ended up with).
- `python3 -I ~/.claude/skills/brief/scripts/checklinks.py .` reports 0 broken.
- `git status` shows nothing under `run/` or `dist/`.

**Logan, by hand:**

- Install Prism and follow `docs/guide/playing.md` to set up the auto-sync instance. Launch it,
  then make a creative world and check that:
  - Create blocks place and a shaft turns.
  - A TaCZ gun is in the creative tab and fires.
- Import `dist/*.mrpack` into a second Prism instance and confirm it launches.

The server check runs headless (`nogui`) and opens no windows, so it needs no warning.

Then stop. Commit, report, and leave merging to Logan.

## Report

### Built

- **Pack** (`pack/`): `packwiz init` with no prompts, NeoForge pinned at `21.1.264` (what
  `--neoforge-latest` picked). `mods/create.pw.toml` is Create `6.0.10+mc1.21.1` and
  `mods/tacz-1.21.1.pw.toml` is the TaCZ port `1.1.8-hotfix-r7`; both files are tagged
  `neoforge` / `1.21.1` on Modrinth (checked by version ID through the v2 API). No dependencies
  were offered for either.
- **Server check** (`scripts/server-check.sh`): the steps in Shape, in order. Watches
  `logs/latest.log` for Done or one of three real failure strings, `crash-reports/` for any file,
  the process for an early exit, and a timeout. Kills by PID, `run.sh`'s java child first. Traps
  `INT`/`TERM` so an interrupted run cleans up. Caches the installer, the bootstrap and
  `packwiz-installer.jar` in `run/cache/`, with the serve, install and sync logs beside them.
- **Export** (`scripts/export.sh`): slugs the pack name, refreshes, and writes
  `dist/claude-modpack-0.1.0.mrpack`.
- **Docs**: root `README.md`; `AGENTS.md` (Commands, Rules, Areas); `docs/guide/README.md` and
  `docs/guide/playing.md`; `docs/architecture/server-check.md`; `.claude/rules/server-check.md`
  from `areas.py`; `.gitignore`.

### Deviations

- **Failure strings.** The brief's examples were guesses, as it said. From the real failure:
  `Missing or unsupported mandatory dependencies` (ERROR), `Error during pre-loading phase`
  (FATAL) and `Failed to start the minecraft server`. "Mod loading has failed" appears only in the
  crash report, never in `latest.log`, so it isn't a pattern.
- **The server exits 0 after a mod-loading failure.** Found by running the broken server
  unwatched: crash report at 5 s, exit code 0 at 7 s. The check never reads the exit code.
- **No `set -m`.** The first version killed process groups via job control. On the TaCZ run,
  bash 3.2 printed `child setpgid (…): Operation not permitted`: a lost race, which would aim the
  kill at a process group that doesn't exist and could orphan `packwiz serve` on 8080, making the
  next run fail. Nothing leaked that time, but the check now kills by PID instead.
- **Prism pre-launch.** Prism's wiki says pre-launch commands run "in the launcher's working
  folder". Its source (`launcher/minecraft/MinecraftInstance.cpp`, `setWorkingDirectory(gameRoot())`
  on the Pre-Launch step) runs them in the instance's Minecraft folder, so packwiz's bare-path
  command works. The guide uses `"$INST_MC_DIR/packwiz-installer-bootstrap.jar"` anyway, which
  works under either reading. New instances call that folder `minecraft/`, not `.minecraft/`
  (`gameRoot()` uses `.minecraft` only when it already exists), so the guide names both.
- **Mod count** in the summary is the server's `Mod List:` table: 7 on the final pack (Create,
  Flywheel, Ponder, SimpleBedrockModel, TaCZ, Minecraft, NeoForge), since jar-in-jar mods count.
  The summary prints the jar count in `mods/` beside it (2).
- **`areas.py`** needs an `### Areas` heading in `AGENTS.md`; added one with parley's wording.

### Defaults taken

- **EULA:** the script writes `eula=true` into `run/server/`, and the root README says running
  the check accepts the EULA.
- **Pack name and author:** `Claude Modpack`, `Logan Lopez`, `0.1.0`.

### Acceptance

- **Two passes in a row on the final pack: pass.** Both exit 0. `NeoForge: 21.1.264 (Minecraft
  1.21.1)`, `Mods: 7 loaded`, `2 jar(s) in mods/`, boot 17 s and 15 s wall (`Done (5.602s)!`,
  `Done (4.453s)!`). No ERROR lines in either log. Nothing left running afterwards.
- **The failure run (build order step 3): recorded.** With `create-enchantment-industry` added
  and its two required dependencies declined: `scripts/server-check.sh`, exit 1, after 2 s.
  Matched line:
  `[main/ERROR] [net.neoforged.fml.loading.ModSorter/LOADING]: Missing or unsupported mandatory dependencies:`
  followed by `Mod ID: 'create', Requested by: 'create_enchantment_industry', Expected range: '[6.0.10,)', Actual version: '[MISSING]'`
  and the same for `create_dragons_plus`. With the log patterns blanked, it failed on the crash
  report at 5 s and printed both `Failure message:` lines. The addon was removed with
  `packwiz remove`, and the next sync deleted its jar.
  - Also exercised: `CHECK_TIMEOUT=4` fails with `no Done after 4s` and leaves no java running;
    `SIGTERM` mid-boot leaves nothing running and removes the FIFO.
- **`pack/mods/` holds `create.pw.toml` and `tacz-1.21.1.pw.toml`, both 1.21.1 NeoForge files:
  pass.**
- **`scripts/export.sh` writes `dist/claude-modpack-0.1.0.mrpack`: pass.** Its index lists both
  mods from `cdn.modrinth.com` and depends on `minecraft 1.21.1`, `neoforge 21.1.264`.
- **`checklinks.py`: pass,** 10 files, 0 broken.
- **`git status` shows nothing under `run/` or `dist/`: pass.** Both are ignored.
- **Not run:** shellcheck (not installed).

### Size

Sized L, this session S (9 active min, 9 wall, 0 compactions).

### Spot checks for Logan

- Install Prism and follow `docs/guide/playing.md` for the auto-sync instance, with
  `cd pack && packwiz serve` running. In a creative world: Create blocks place and a shaft turns;
  a TaCZ gun is in the creative tab and fires. Also confirm the guide's description of the
  packwiz-installer window matches what you see.
- Import `dist/claude-modpack-0.1.0.mrpack` (run `scripts/export.sh` first) into a second
  instance and confirm it launches.
- Read the server check's summary on one run yourself: `scripts/server-check.sh`.

### Docs updated

- New: root `README.md`, `docs/architecture/server-check.md`, `docs/guide/README.md`,
  `docs/guide/playing.md`, `.claude/rules/server-check.md`.
- `AGENTS.md`: the project paragraph no longer says nothing is built; Commands, Rules, and the
  Areas table.

### Follow-ups

- **packwiz warns about both mods:** "Modrinth versions … inconsistent between latest version
  number and newest release date" (Create `mc1.21.1-6.0.9` vs `6.0.10+mc1.21.1`; TaCZ `1.1.8-r3`
  vs `1.1.8-hotfix-r7`). It picked the newest both times. Check what `packwiz update` does with
  them before relying on it.
- **The server check binds Minecraft's default port 25565.** A local server already on it would
  fail to bind. Not seen; worth a `server-port` override if it happens.
- **shellcheck** isn't installed; worth a pass over both scripts when it is.
- **Machine facts** (Java 17 default, `~/go/bin` not on `PATH`, `/bin/bash` 3.2) written to
  `~/Dev/dotfiles/.claude/CLAUDE.md` under a new `## This machine` section, uncommitted.
