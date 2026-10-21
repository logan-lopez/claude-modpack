# Playing the pack

Play the pack in Prism Launcher, either kept in sync with the repo on every launch or imported
once from a `.mrpack` file.

**Covers:** `scripts/export.sh`

## Auto-sync from the repo

The instance runs packwiz-installer before each launch. It fetches the pack from `packwiz serve`
on your machine and installs whatever changed, so the instance always matches `pack/`.

Once:

1. Install [Prism Launcher](https://prismlauncher.org/).
2. Create an instance: Minecraft 1.21.1, NeoForge at the version in `pack/pack.toml` under
   `[versions]` (21.1.264 now).
3. Download `packwiz-installer-bootstrap.jar` from
   [its releases](https://github.com/packwiz/packwiz-installer-bootstrap/releases) and put it in the
   instance's Minecraft folder: right-click the instance, Folder, then `minecraft/` (older
   instances call it `.minecraft/`). The server check keeps a copy in `run/cache/`.
4. Edit the instance, Settings, Custom commands. Tick the box to override, and set the pre-launch
   command to:

   ```
   "$INST_JAVA" -jar "$INST_MC_DIR/packwiz-installer-bootstrap.jar" http://localhost:8080/pack.toml
   ```
5. In the same Settings, on the Java tab, override the memory and set the maximum to at least
   8192 MB. With less, the game doesn't get past loading. The pack can't set this for you: it's
   the instance's setting, and an imported `.mrpack` needs it too.

Each time you play:

1. In a terminal (Git Bash on Windows), `cd pack && packwiz serve`. Leave it running. If
   `packwiz` isn't found, it's in `$(go env GOPATH)/bin`.
2. Launch the instance. A small window shows packwiz-installer downloading mods, then the game
   starts.

`packwiz serve` holds port 8080, and so does the server check by default. Run the check with
`CHECK_PORT=8081 scripts/server-check.sh` while you're playing, or stop the serve first.

## Import a `.mrpack` instead

`scripts/export.sh` (from Git Bash on Windows) writes `dist/claude-modpack-<version>.mrpack`. In Prism: Add Instance, Import,
and pick the file. It's a snapshot: it doesn't update when the pack does, so export and import
again for a new build. This is also the file to share.

The mods that come from CurseForge (the FTB mods, LaserIO, Ars Elemental and the rest) and the
Create Armorer gun pack are inside the file, because a `.mrpack` can only link to Modrinth
downloads. That makes it about 25 MB, and sharing it hands those files on directly rather than
through CurseForge. Fine between friends; it's the reason the pack couldn't be uploaded to Modrinth
as it stands.

## Looking after a world

### Backups

Simple Backups zips the world every 120 minutes of play, as a full backup each time, and says so
in chat when it starts and finishes. It keeps the newest 10, and deletes the oldest when there
are more or when the folder passes 25 GB. They go in the instance's `minecraft/simplebackups/`,
in a folder named after the world's save folder (the one under `minecraft/saves/`). The timer
runs only while you're in the world.

To force one, `/simplebackups backup start`. Like every command here, it needs cheats on.

To restore one, with the game closed: move the world's folder out of `minecraft/saves/` somewhere
safe, then unzip the backup into `minecraft/saves/`. The zip holds the world's folder, so it
comes back under its old name. Open the world. If it's wrong, put the moved folder back. Moving
the old folder out, rather than unzipping over it, matters: files written after the backup would
otherwise stay mixed in with the restored ones.

### Pregenerating

Terralith, Biomes O' Plenty and the structure mods make new chunks slow to generate, so flying or
riding a train into fresh ground stutters. Chunky generates them ahead of time.

Its commands need cheats on: tick Allow Cheats when you create the world, or for a world without
them, Open to LAN with Allow Cheats on (it lasts until you leave the world). A starting point:

```
/chunky radius 1000
/chunky start
```

The radius is in blocks around the world's center (0, 0), so that's a 2000-by-2000 square of the
dimension you're standing in. `/chunky spawn` centers it on the world spawn instead. It takes a
while, and runs in the background while you play, with progress in chat. `/chunky pause` stops
it, and `/chunky continue` picks it up again, including after you've left the world and come
back: it doesn't resume on its own.

## When the instance won't launch

- **The loading screen stalls or the game runs out of memory.** Check the instance's maximum
  memory is at least 8192 MB (step 5 above).
- **packwiz-installer shows an error, or the launch stops at the pre-launch step.** It couldn't
  reach the pack. Check `packwiz serve` is running in `pack/` and on port 8080, then launch
  again.
- **NeoForge version mismatch, or mods complaining about the loader.** The instance's NeoForge has
  to match `pack/pack.toml`. Edit the instance, Version, and change NeoForge.
- **A crash on startup.** Run `scripts/server-check.sh` first. If the server fails too, its
  summary names the mod. If the server passes, the problem is client-side: the crash report is in
  the instance's `minecraft/crash-reports/`.
- **Mods you removed are still there.** packwiz-installer only removes files it installed itself.
  Delete anything you added by hand from `minecraft/mods/`.
