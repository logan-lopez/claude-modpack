# The server build

`scripts/server-pack.sh` builds `dist/<name>-<version>-server.zip`, a server someone can keep: it
unzips on macOS, Linux or Windows and starts with `start.sh` or `start.bat`. The launch scripts
and the files around them are templates in `server/`.

**Sources:** `scripts/server-pack.sh`, `server/`

## How the build works

It reuses `scripts/server-check.sh`'s first steps, duplicated rather than shared:

1. Finds Java 21 with `/usr/libexec/java_home -v 21`, finds packwiz as the other scripts do, and
   runs `packwiz refresh`. `<name>` and `<version>` come from `pack/pack.toml` the way
   `scripts/export.sh` derives them, so the zip sits beside the `.mrpack` of the same build.
2. Runs `packwiz serve` on `SERVE_PORT` (default 8080), refusing if the port is taken.
3. Fetches the NeoForge installer and packwiz-installer-bootstrap into `run/cache/` if they
   aren't there.
4. Wipes `run/server-pack/` and syncs the pack into `run/server-pack/<name>-<version>-server/` with
   the bootstrap (`-g -s server`). That gives `mods/` without the `side = "client"` mods,
   `config/`, `kubejs/` and `tacz/`. It stops the serve and deletes `packwiz.json`. The sync log
   is `run/cache/server-pack-sync.log`. A full sync downloads about 670 MB and took 34 seconds.
5. Copies in the installer jar and `server/`'s files, substitutes `@NEOFORGE_VERSION@` (both
   start scripts) and `@MOTD@` (`defaults/server.properties`, as `<pack name> <version>`), fails
   if a placeholder is left, converts `start.bat` to CRLF and makes `start.sh` executable.
6. Deletes an old zip of the same name and zips the folder from `run/server-pack/` with
   `zip -qrX`. Prints the size, the jar count and the zip's path.

### The zip

One top-level folder, `<name>-<version>-server/`:

```
start.sh                          mode 755
start.bat                         CRLF
README.txt                        for whoever runs the server
neoforge-<version>-installer.jar
defaults/server.properties        allow-flight=true, difficulty=hard, motd=<name> <version>
defaults/user_jvm_args.txt        -Xmx12G and a comment
mods/  config/  kubejs/  tacz/    from the server sync
```

Never at the top: `eula.txt`, `server.properties`, `user_jvm_args.txt`, `libraries/`, `run.sh`,
`run.bat`, `world/`, `packwiz.json`. They belong to a running server, and a newer zip unzipped over
it mustn't replace them.

## The start scripts

`start.sh` (bash) and `start.bat` do the same steps, from the folder they're in:

1. **Find Java 21.** `start.sh` tries `$JAVA_HOME/bin/java`, then `/usr/libexec/java_home -v 21`
   when that exists (macOS), then `java` on `PATH`. `start.bat` tries `%JAVA_HOME%\bin\java.exe`,
   then each `where java`. The first whose `-version` says `version "21` wins. With none, both
   print where they looked and the Temurin 21 link, and exit 1 (`start.bat` after a `pause`).
   Newer Java isn't accepted: NeoForge 21.1 is built for 21.
2. **Copy the defaults** from `defaults/` for `server.properties` and `user_jvm_args.txt`, only
   when the file isn't there.
3. **Install NeoForge** when `libraries/net/neoforged/neoforge/<version>/unix_args.txt`
   (`win_args.txt` on Windows) is missing, with `--installServer .` on the Java from step 1. It
   needs the network and took about 20 seconds here. A failure prints the last 20 lines of the
   installer's own log, `neoforge-<version>-installer.jar.log`.
4. **Ask about the EULA** unless `eula.txt` has a line starting `eula=true`. `y` or `Y` writes it;
   anything else exits 1. `start.sh` with no terminal on stdin prints what to do and exits 1
   rather than wait.
5. **Run** the found Java directly: `@user_jvm_args.txt @libraries/.../unix_args.txt nogui` plus
   the script's own arguments, in the foreground, so the window is the server console.
6. **Restart after a crash** (below). Otherwise exit with the server's exit code; `start.bat`
   `pause`s first.

## Rules worth keeping

- **`server/` isn't under `pack/`.** packwiz indexes every file in `pack/` and would sync these
  into Prism instances and the server check's server.
- **`start.bat` is CRLF.** `cmd.exe` misreads labels and `goto` in a `.bat` with LF endings.
  `.gitattributes` checks it out CRLF, and the build converts it again in case a checkout didn't.
- **No parenthesized blocks around `%variables%` in `start.bat`.** A path like `C:\Program Files
  (x86)\...` in `JAVA_HOME` would end the block early. The script uses `goto` and one-line `if`s.
- **Defaults never overwrite.** The scripts copy a default only when the file is missing, and
  copy `user_jvm_args.txt` before the installer runs, because the installer writes its own
  commented template (with no `-Xmx`) when there's none and leaves an existing one alone.
- **The restart rule needs both signs**: the server reached `Done (` in this run's
  `logs/latest.log`, and a crash report appeared during this run. The exit code can't say it:
  NeoForge exits 0 after a failed load ([the server check](server-check.md#rules-worth-keeping)),
  and a kill or a clean `stop` exit with codes that overlap a crash's. A failed load writes a crash
  report but never logs `Done (`, so it never restarts; a `stop` writes no crash report.
  - **This run's,** in `start.sh`: a stamp file is touched before each start, and both
    `logs/latest.log` and the crash report must be newer than it. In `start.bat`, which can't
    compare file times: the number of files in `crash-reports\` went up, and `latest.log`'s time
    or size changed. A log left from an earlier run would otherwise count when the JVM dies
    before logging anything.
- **Signals.** Ctrl+C in a terminal reaches both the script and Java; Java saves and stops in a
  couple of seconds, and `start.sh`'s `INT` trap then exits with 130 without restarting. The save
  doesn't show in `latest.log`, because Log4j has shut down by then; `world/level.dat` and the
  region files' times show it. The 10-second wait runs `sleep`
  in the background and `wait`s, so a signal ends it at once. A script started in the background
  by another non-interactive shell has `SIGINT` ignored, and that can't be trapped: test it from
  a wrapper that resets `SIGINT` to default.
- **`/bin/bash` is 3.2 on macOS,** and both scripts stay within it.

## Decisions

The decisions table in [the briefs README](../briefs/README.md) has the choices (Java required
not bundled, the EULA asked, the defaults, `-Xmx12G`, a self-contained zip).

The `.bat` has never been run by a session: there's no Windows here. It was read against
`start.sh` step by step.
