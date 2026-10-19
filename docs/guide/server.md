# Running a server

A server zip you can keep a world on, or send to a friend to host: it unzips and starts on
macOS, Linux or Windows, with the pack's mods inside.

**Covers:** [The server build](../architecture/server-pack.md)

## Building it

```sh
scripts/server-pack.sh
```

It writes `dist/claude-modpack-<version>-server.zip`, about 625 MB, in under a minute. Like the
server check it uses port 8080 for a moment; if `packwiz serve` is running for Prism, build with
`SERVE_PORT=8081 scripts/server-pack.sh`.

To play on it, players need the client pack of the same version: run `scripts/export.sh` too, and
send both files. A friend imports the `.mrpack` ([Playing the pack](playing.md#import-a-mrpack-instead)),
and hosts the zip if they're the one running the server.

## First start

The person running it needs Java 21 ([Temurin 21](https://adoptium.net/temurin/releases/?version=21)).
A newer Java won't do; 21 installs alongside it. With no Java 21, the start script says so, lists
where it looked, and gives that link.

Unzip it, then:

- **macOS or Linux:** in Terminal, `cd` into the folder and run `./start.sh`. Double-clicking a
  `.sh` opens it in an editor.
- **Windows:** double-click `start.bat`.

The first start installs NeoForge, which downloads Minecraft's server (a minute or so), then
prints the [Minecraft EULA](https://aka.ms/MinecraftEULA) link and asks whether you accept it.
Answer `y` and the server starts; it doesn't ask again. The window is the server console: commands
without the slash, and `stop` to shut it down.

If the server crashes after it has started, the script prints `Server crashed. Restarting in 10
seconds, Ctrl+C to quit.` and starts it again. It doesn't restart after `stop`, or when the
server fails to load, so a broken mod can't loop.

## Settings

Both files are made on the first start from the copies in `defaults/`, and edits to them are kept
through updates. Edit the ones next to `start.sh`, then restart the server.

- **Memory:** the `-Xmx` line in `user_jvm_args.txt`, 12 GB (`-Xmx12G`) to start with. The
  machine needs more than that free.
- **Everything else:** `server.properties`. A fresh server allows flight (Create contraptions,
  jetpacks and Ad Astra kick players for flying otherwise), plays on Hard, and shows `Claude
  Modpack <version>` in the server list. The whitelist is off.

Players connect on port 25565; forward it on the router for anyone outside the network.

## Updating

1. Back up `world/`. Simple Backups also runs on the server, into `simplebackups/`.
2. `stop` the server and let the script exit.
3. Delete `mods/`, `kubejs/` and `tacz/`, so mods the new version dropped don't stay behind.
4. Unzip the new zip somewhere else and copy everything inside its folder into the server's
   folder, replacing files. The folder inside the zip is named after the version, so unzipping
   it in place makes a second server rather than updating this one.
5. Start it.

The world, `server.properties`, `user_jvm_args.txt` and the EULA answer stay: the zip never
contains them. A new NeoForge version installs itself on that start.

The zip carries `README.txt` with the same instructions, for whoever runs it.

## What it doesn't do

- **Host anything.** The zip is the whole server; nothing syncs from the repo when it starts, so
  every pack change means a new zip.
- **Bundle Java.** Java 21 has to be installed.
- **Whitelist players.** It's off by default; `whitelist on` and `whitelist add <name>` in the
  console turn it on.
- **Run as a service.** It runs while its window is open. Type `stop` before closing the window,
  so the world is saved.
- **Go on Modrinth or CurseForge.** It carries the CurseForge mods' jars, as the `.mrpack` does:
  fine between friends, not for publishing.
