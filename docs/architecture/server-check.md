# The server check

`scripts/server-check.sh` boots a headless NeoForge server from `pack/` and says whether it
reached "Done". It's the only thing a session can verify about the pack on its own, so every
change to the mod set ends with it passing.

**Sources:** `scripts/server-check.sh`, `scripts/server-check.known-errors.txt`

## How it works

1. Finds Java 21 with `/usr/libexec/java_home -v 21` and puts it first on `PATH`. The default
   `java` here is 17, and the run script NeoForge writes calls whatever `java` is on `PATH`.
2. Runs `packwiz refresh` in `pack/`, then `packwiz serve` on `CHECK_PORT` (default 8080). It
   refuses to start if something already listens there, which is usually a `packwiz serve` left
   up for Prism.
3. Reads the NeoForge version from `pack/pack.toml`. If `run/server/` doesn't have that version's
   `libraries/net/neoforged/neoforge/<v>/unix_args.txt`, it wipes `run/server/` and runs the
   installer with `--installServer`. Installer and bootstrap jars are cached in `run/cache/`.
4. Syncs the pack with packwiz-installer-bootstrap (`-g -s server`, from the served URL): the
   mods, and the gun packs in `pack/tacz/` into `run/server/tacz/`, where TaCZ reads them. It
   also deletes files it installed earlier that the pack no longer lists. Then it stops the
   serve.
5. Deletes `world/`, `crash-reports/` and `logs/latest.log`, writes `eula.txt` and a
   `server.properties` with a fixed `level-seed`, and starts `./run.sh nogui` with stdin on a
   FIFO.
6. Polls `logs/latest.log` once a second until one of the outcomes below, then sends `stop` on a
   pass, or kills the server on a fail.
7. Prints a summary: the NeoForge version the server actually ran (from `--fml.neoForgeVersion`
   in the log), the mod count from the log's `Mod List:` table, the boot time, and on a fail the
   reason with the log or crash-report lines that show it. On a pass it compares the log's load
   errors with the [baseline](#the-known-errors-baseline), lists the new and gone ones, then
   prints the first 20 ERROR lines of no known kind, without timestamps and deduplicated.
   `CHECK_UPDATE_BASELINE=1` then rewrites the baseline from this run.

Logs from the steps around the boot are in `run/cache/`: `serve.log`, `install.log`, `sync.log`.
The server's own output is `run/server/console.log`.

## What counts as a failure

Checked in this order each second:

- **Pass:** a `Done (<n>s)!` line in the log.
- **A mod-loading line in the log.** One of:
  - `Missing or unsupported mandatory dependencies` (ERROR, from `ModSorter`), about 2 seconds
    in. The lines under it name each missing mod, who wanted it and the version range.
  - `Error during pre-loading phase` (FATAL, from `ModLoader`).
  - `Failed to start the minecraft server`.
- **A crash report:** any file in `crash-reports/`.
- **The server exited before Done.**
- **A timeout:** `CHECK_TIMEOUT` seconds (default 300) without Done.

ERROR lines after a pass don't fail the check, known or new. Big packs log harmless errors, and
failing on all of them would make the check useless. The baseline is how a session sees them.

## The known-errors baseline

`scripts/server-check.known-errors.txt` holds every load error the pack is known to log, one per
line as `<kind> <id>`, sorted with `LC_ALL=C sort -u`. About 330 lines, almost all recipes and
loot tables for mods that aren't in the pack. `load_error_keys` in the script turns a log into
these keys, from ERROR lines of five shapes:

| Kind | Line |
| --- | --- |
| `recipe` | `Parsing error loading recipe <id>:` |
| `loot` | `Couldn't parse element ResourceKey[minecraft:root / minecraft:loot_table]:<id> -` |
| `datafile` | `Couldn't parse data file <id> from` |
| `datamap` | `DataMapLoader`'s `Object with ID <id>` |
| `advancement` | each ID in `Couldn't load advancements: [<ids>]` |

Data loads twice per boot, on `main` and again on the `Server thread`, so most IDs are logged
twice; the keys are unique. `KEYED`, next to the function, matches the same lines so the summary
can print the rest raw. Change the two together.

On a pass the summary prints `Load errors: <n> known, <n> new, <n> gone` (from `comm` against
the baseline), then up to 20 new and 20 gone keys. A new key is a recipe or loot table that
stopped loading; a gone key is a fix that took, or a mod that left. Neither changes the exit
code. With no baseline file the summary gives the key count and says so.

To refresh it, run `CHECK_UPDATE_BASELINE=1 scripts/server-check.sh` and commit the file. It's
written only after a pass. Read the diff first: a fix should only remove lines.

## Rules worth keeping

- **The server's exit code means nothing.** After a mod-loading failure, NeoForge 21.1.264 writes
  a crash report, logs `Failed to start the minecraft server` and exits 0. The check never reads
  the exit code; it reads the log, the crash reports and whether the process is alive.
- **The failure strings are copied from a real run,** not remembered. "Mod loading has failed"
  appears only inside the crash report, never in `latest.log`. Before adding a pattern, cause the
  failure and copy the line.
- **No job control.** An earlier version used `set -m` to kill whole process groups. On macOS's
  bash 3.2 that printed `child setpgid ... Operation not permitted` once, and a lost race would
  leave the kill aimed at a group that doesn't exist. The script kills by PID, and `run.sh`'s
  children first, because `run.sh` runs java without `exec`.
- **`/bin/bash` is 3.2 here.** Nothing newer: no associative arrays, `mapfile` or `${var,,}`.
- **A fresh world every run,** so a world saved by an earlier mod set can't hide or cause a
  failure. Configs in `run/server/config/` do persist between runs.

## What it can't catch

Anything that only happens on a client: rendering, models, shaders, keybinds, sounds, the feel of
the guns, client-only mods (the sync runs with `-s server`, so they're never installed here), and
client–server mismatches. It also boots one fixed seed and loads spawn chunks, so it misses
crashes that need a player, a particular structure or a later dimension. Those are Logan's hand
checks.

## Decisions

The baseline only reports (Logan, 2026-10-19, brief 07). A pass keeps meaning "it booted with no
mod-loading failure", and a mod update that breaks one recipe in a pack of hundreds isn't a reason
to stop. The summary's new keys are what a session reads to catch it.

The failure run that proved the check, on 2026-10-19: `create-enchantment-industry` added
without its required `create` and `create_dragons_plus`. `scripts/server-check.sh` exited 1 in
2 seconds on `Missing or unsupported mandatory dependencies`. With the log patterns blanked it
failed on the crash report at 5 seconds instead, and run unwatched the server exited 0 at 7
seconds, so each layer catches this failure on its own.
