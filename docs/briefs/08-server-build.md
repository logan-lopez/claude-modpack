# Brief 08: A server build

**Size:** M. One build script, two launch scripts and a few template files; the `.bat` can't be
run here, so it's a hand check.

Read `CLAUDE.md`, [`README.md`](README.md), [the server check page](../architecture/server-check.md)
and [Playing the pack](../guide/playing.md) first. No prerequisites: brief 07's work is on `main`
(`8cbe8da`), and nothing here touches its files.

## Goal

The only server the repo makes is the server check's throwaway in `run/server/`: a fresh world
every run, `eula=true` written for you, and only on this Mac. This brief makes a server someone
can keep: `scripts/server-pack.sh` writes `dist/<name>-<version>-server.zip`, which unzips on
macOS or Windows (Linux comes free with the `.sh`) and starts with `start.sh` or `start.bat`.

What a "proper" build means here:

- **Self-contained.** The server-side mods, configs, KubeJS data and gun packs are inside. Nothing
  is downloaded on start except what NeoForge's installer fetches, because there's no hosted pack
  URL to sync from ([README](README.md), Not built).
- **Runs where it's unzipped,** with the Java 21 it finds, and says plainly what's wrong when
  there isn't one.
- **Survives an update.** Unzipping the next version over it never clobbers the world, the
  server's own `server.properties` or its memory setting.
- **Restarts after a crash,** but not after a clean `stop` or a failed load.

## Decisions already made

Logan, 2026-10-19 (a Parley round). Don't revisit silently.

- **Java:** required, not bundled. The start scripts find Java 21, and stop with a link to
  Adoptium's Temurin 21 when there's none. One zip for every OS.
- **EULA:** the start script asks on first start, prints the EULA link, and writes `eula=true` on
  yes. It never asks again once `eula.txt` says true. The zip never contains `eula.txt`.
- **Defaults a fresh server gets:** `allow-flight=true` (Create contraptions, jetpacks and Ad Astra
  kick players for flying otherwise), `difficulty=hard`, and a restart after a crash. Whitelist
  stays off.
- **Memory:** `-Xmx12G`.
- **Self-contained zip** (decided writing this brief, from the README's Not built: no hosting).
  It carries the CurseForge jars, as the `.mrpack` already does: fine between friends, not for
  publishing anywhere ([Playing the pack](../guide/playing.md#import-a-mrpack-instead)).

## Already checked

2026-10-19, on this machine.

- **NeoForge's installer** (`run/cache/neoforge-21.1.264-installer.jar --installServer .`, run in
  an empty scratch folder with Java 21) finished in about 20 seconds and needs the network: it
  downloads Minecraft's server and patches it into `libraries/` (179 MB). Mojang's server jar
  can't be redistributed, so the zip ships the installer, not `libraries/`.
- **It writes** `run.sh`, `run.bat`, `libraries/net/neoforged/neoforge/21.1.264/unix_args.txt` and
  `win_args.txt` on any OS. `run.sh` is `java @user_jvm_args.txt
  @libraries/net/neoforged/neoforge/21.1.264/unix_args.txt "$@"`; `run.bat` is the same with
  `win_args.txt` and `%*`, then `pause`. Both call whatever `java` is on `PATH`.
- **It leaves an existing `user_jvm_args.txt` alone:** a file holding `-Xmx6G` and a comment came
  through the install unchanged. Without one it writes a commented template with no `-Xmx`.
- **The server sync** (`packwiz-installer-bootstrap -g -s server`, as `scripts/server-check.sh`
  step 4 runs it) puts 269 jars in `mods/` (673 MB) of the pack's 294 entries: 25 are
  `side = "client"`, none are server-only. It also syncs `config/almostunified/`, `kubejs/data/`
  and `tacz/`, and leaves `packwiz.json` behind, which the zip doesn't want.
- **A partial `server.properties` is fine.** The server check writes only `level-seed=`, and the
  server fills in every other key with its default on boot (`run/server/server.properties`).
- **`zip` and `unzip`** are `/usr/bin/zip` and `/usr/bin/unzip`.
- **NeoForge exits 0 after a mod-loading failure** and writes a crash report
  ([the server check page](../architecture/server-check.md#rules-worth-keeping)), so neither the
  exit code nor a crash report alone says "it crashed while running". The restart rule below
  leans on this.

## Open questions

- **A cap on restarts.** Default: none. Each restart waits 10 seconds with a Ctrl+C prompt, and a
  load failure never restarts, so a loop can't spin fast.
- **The MOTD.** Default: `motd=Claude Modpack <version>` in the shipped defaults, filled in at
  build time.
- **Java newer than 21** (Temurin 25 is a current LTS, and people have it). Default: not accepted.
  NeoForge 21.1 is built for 21; the error says to install 21 alongside.

## Shape

### Files

- **`server/`** (new, repo root): the templates the build copies in. **Not under `pack/`:** packwiz
  indexes every file there and would sync these into Prism instances and the server check.
  - `server/start.sh`, `server/start.bat`: the launch scripts, with `@NEOFORGE_VERSION@` where
    the version goes. The build substitutes it.
  - `server/defaults/server.properties`: `allow-flight=true`, `difficulty=hard`,
    `motd=@MOTD@`. Nothing else.
  - `server/defaults/user_jvm_args.txt`: `-Xmx12G`, with a comment saying this is the line to
    change.
  - `server/README.txt`: plain text for whoever runs it (below).
- **`scripts/server-pack.sh`** (new): the build.
- **`.gitattributes`** (new): `*.bat text eol=crlf`, and `server/start.bat` committed with CRLF.
  `cmd.exe` mis-reads labels and `goto` in a `.bat` with LF endings.

### The zip (**pinned**: `docs/guide/` and the README describe it)

`dist/<name>-<version>-server.zip`, `<name>` and `<version>` as `scripts/export.sh` derives them
(`claude-modpack-0.1.0-server.zip` now). One top-level folder, `<name>-<version>-server/`:

```
start.sh                          mode 755
start.bat                         CRLF
README.txt
neoforge-<version>-installer.jar
defaults/server.properties
defaults/user_jvm_args.txt
mods/  config/  kubejs/  tacz/    from the server sync
```

No `eula.txt`, `server.properties`, `user_jvm_args.txt`, `libraries/`, `run.sh`, `run.bat`,
`world/` or `packwiz.json` at the top: those belong to a running server, and an update unzipped
over it must not replace them.

### `scripts/server-pack.sh`

`#!/bin/bash`, bash 3.2-safe, `set -euo pipefail`, in the style of the two scripts beside it. It
reuses `scripts/server-check.sh`'s steps 1 to 5 rather than calling that script:

1. Java 21 via `/usr/libexec/java_home -v 21`, packwiz found as the other scripts find it,
   `packwiz refresh`.
2. `packwiz serve` on `SERVE_PORT` (default 8080), refusing if the port is taken, with the same
   message shape as the check.
3. Fetch the NeoForge installer and the bootstrap jar into `run/cache/` if missing (the check's
   `fetch`).
4. Stage in `run/server-pack/<name>-<version>-server/`, wiped first: run the bootstrap there with
   `--bootstrap-main-jar "$CACHE/packwiz-installer.jar" -g -s server`, stop the serve, delete
   `packwiz.json`.
5. Copy in the installer jar and `server/`'s files, substitute `@NEOFORGE_VERSION@` and `@MOTD@`,
   `chmod 755 start.sh`.
6. `zip -qr` from `run/server-pack/` into `dist/`, replacing an old zip of the same name. Print
   its path and size, and the jar count.

Duplicating the check's helpers is fine: `export.sh` already duplicates the packwiz lookup. Don't
change `scripts/server-check.sh`.

### `start.sh` and `start.bat` (**pinned**: behavior the README.txt and guide describe)

Both do the same, in this order, from the folder they're in (`cd "$(dirname "$0")"`, `cd /d
"%~dp0"`):

1. **Find Java 21.** Try `$JAVA_HOME/bin/java`, then on macOS `/usr/libexec/java_home -v 21`
   (only if that file exists, so Linux skips it), then `java` on `PATH`. Accept one whose
   `-version` output has `version "21`. None: print that Java 21 is needed, where it looked, and
   `https://adoptium.net/temurin/releases/?version=21`, then exit 1. On Windows: `%JAVA_HOME%`,
   then `where java`, and `findstr` on `-version`'s output; `pause` before exiting so a
   double-clicked window doesn't vanish.
2. **Copy defaults** from `defaults/` for `server.properties` and `user_jvm_args.txt` when the
   file isn't there. Never overwrite.
3. **Install NeoForge** when `libraries/net/neoforged/neoforge/<version>/` is missing: run the
   installer with `--installServer .` using the Java from step 1, and stop with its log's tail if
   it fails. This also covers an update that changes the NeoForge version. Step 2 comes first so
   the installer finds `user_jvm_args.txt` and leaves it alone.
4. **EULA.** If `eula.txt` doesn't contain `eula=true`: print
   `https://aka.ms/MinecraftEULA`, ask `Do you accept the Minecraft EULA? [y/N]`, write
   `eula=true` on `y`/`Y`, otherwise exit. With no terminal to ask (`[ -t 0 ]` false), print what
   to do and exit 1 rather than hang.
5. **Run** the found Java directly, not NeoForge's `run.sh`/`run.bat` (they use `PATH`'s `java`):
   `java @user_jvm_args.txt @libraries/net/neoforged/neoforge/<version>/unix_args.txt nogui`
   (`win_args.txt` on Windows), in the foreground, so the console is the server console. Extra
   arguments to the start script pass through.
6. **Restart after a crash.** When the server exits, restart only if both: this run's
   `logs/latest.log` has a `Done (` line (it loaded; a log left from an earlier run doesn't
   count), and a file appeared in `crash-reports/` during this run (compare the
   listing before and after). Then print `Server crashed. Restarting in 10 seconds, Ctrl+C to
   quit.`, wait, and go back to step 5. Anything else, a clean `stop`, a failed load or a kill,
   exits with the server's code. On Windows, `timeout /t 10` gives the countdown, and the script
   `pause`s before exiting.

### `server/README.txt`

Short and plain, for someone who isn't Logan: Java 21 and where to get it; unzip, then
`./start.sh` in Terminal on macOS or Linux (double-clicking a `.sh` opens an editor), or
double-click `start.bat` on Windows; the first start downloads Minecraft's server and asks about
the EULA; memory is the `-Xmx` line in `user_jvm_args.txt` (12 GB by default, so the machine
needs more than that free); `server.properties` for the rest; port 25565 to forward; players need
the matching client pack (the `.mrpack` of the same version). **Updating:** `stop`, delete
`mods/`, `kubejs/` and `tacz/`, unzip the new zip over the folder, start. The world, settings and
memory stay; removed mods go, which is why `mods/` is deleted first. Back up `world/` first: Simple
Backups runs on the server too, into `simplebackups/`.

### Docs, in the same commit

- **`docs/architecture/server-pack.md`** (new area): what the build does, the zip layout, the
  start scripts' steps, and the rules worth keeping (why `server/` isn't under `pack/`, CRLF, the
  restart rule and why exit codes don't work, defaults never overwrite). **Sources:**
  `scripts/server-pack.sh`, `server/`.
- **The Areas table in `AGENTS.md`** gets a row for `scripts/server-pack.sh`, `server/**`, and
  `.claude/rules/server-pack.md` the matching pointer. Run `python3 -I
  ~/.claude/skills/brief/scripts/areas.py .` to regenerate both from the Sources lines, and check
  its diff.
- **`AGENTS.md`'s Commands table** gets `scripts/server-pack.sh`.
- **`docs/guide/server.md`** (new): "Running a server": building the zip, what to send a friend,
  first start, updating, where memory and settings live, and what it doesn't do (no hosting, no
  whitelist by default, no bundled Java). **Covers:** the new architecture page. One line in
  `docs/guide/README.md`.
- **The root `README.md`:** a Features line linking the guide page, and the command under Running
  it.

## Out of scope

- **`scripts/server-check.sh` and its baseline.** Don't refactor the check to share code with the
  build; that's a later choice if the duplication bites.
- **Anything under `pack/`.** No mod, config or KubeJS changes, so no server check is owed for the
  mod set (run one anyway if the build's sync misbehaves, to tell a pack problem from a build
  problem).
- **Hosting**, a sync-on-start mode, a bundled JRE, Docker, a systemd or launchd service, RCON
  setup, a whitelist.
- **Server-side config tuning** (Simple Backups, Chunky, TaCZ damage): FUTURE.md's Integrations and
  Melee parity.
- **Publishing** the zip anywhere.

## Build order

1. `server/` templates and `.gitattributes`.
2. `scripts/server-pack.sh`; build once and inspect the zip.
3. Boot it (Acceptance 3 to 5). Fix and rebuild until those pass.
4. Docs.
5. One commit.

## Acceptance

Run these from the repo root. No GUI and no desktop: everything here is headless.

1. **Build.** `scripts/server-pack.sh` exits 0 and prints
   `dist/claude-modpack-0.1.0-server.zip`. Run it a second time: it exits 0 and replaces the zip.
2. **Contents.** `zipinfo dist/claude-modpack-0.1.0-server.zip` shows one top-level folder;
   `start.sh` as `-rwxr-xr-x`; `start.bat`, `README.txt`, the installer jar, `defaults/` with both
   files; 269 jars in `mods/` (the same count as the check's `run/server/mods/`), none of them
   Sodium, Iris or another `side = "client"` mod; and no `eula.txt`, `server.properties`,
   `user_jvm_args.txt`, `libraries/` or `packwiz.json` at the top. `unzip -p ... start.bat | file -`
   says CRLF. No `@NEOFORGE_VERSION@` or `@MOTD@` left in any file.
3. **First start.** Unzip into a scratch folder. Run `./start.sh </dev/null`: it exits 1 at the
   EULA step with a message, having already copied the defaults and installed NeoForge. Write
   `eula=true` to `eula.txt`, then start it again with stdin on a FIFO (as the check does) and
   the server reaches `Done (`. `user_jvm_args.txt` is `-Xmx12G`, and the log's JVM args show it.
   `server.properties` after boot has `allow-flight=true` and `difficulty=hard`. Send `stop`: the
   script exits and does not restart.
4. **Second start keeps settings.** Change `user_jvm_args.txt` to `-Xmx10G` and the MOTD in
   `server.properties`. Unzip the zip over the folder, start again: no installer run, no EULA
   question, both edits still there. Stop it.
5. **Restart rule.** With the server up past `Done`, create a file in `crash-reports/` and kill
   the java process (not the script): the script prints the restart line and starts the server
   again. Stop it the same way and send SIGINT to the script during the countdown: it exits.
   Then delete `create-*.jar` from `mods/` and start: the load fails, and the script exits without
   restarting.
6. **Java check.** With `JAVA_HOME` pointed at the Java 17 on this machine, `start.sh` still runs
   on 21 (from `java_home`). Read `start.bat`'s Java and restart logic once against
   `start.sh`'s, since it can't run here.
7. **Docs.** `python3 -I ~/.claude/skills/brief/scripts/checklinks.py .` and
   `python3 -I ~/.claude/skills/brief/scripts/drift.py .` are clean for the new pages.

Paste the build's output and the boot summaries into the report.

**Logan's hand checks:**

- `start.bat` on a Windows machine with Java 21: double-click, first start installs and asks about
  the EULA, the server reaches Done, `stop` exits, the window waits on `pause`. And with no Java
  21, the message and link show and the window stays open.
- A client from the matching `.mrpack` (or the auto-sync instance) joins the zip's server, flies
  on a Create contraption without being kicked, and the difficulty is Hard.

Then stop. Report, and leave merging to Logan.
