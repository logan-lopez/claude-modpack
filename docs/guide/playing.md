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

Each time you play:

1. In a terminal, `cd pack && packwiz serve`. Leave it running.
2. Launch the instance. A small window shows packwiz-installer downloading mods, then the game
   starts.

`packwiz serve` holds port 8080, and so does the server check by default. Run the check with
`CHECK_PORT=8081 scripts/server-check.sh` while you're playing, or stop the serve first.

## Import a `.mrpack` instead

`scripts/export.sh` writes `dist/claude-modpack-<version>.mrpack`. In Prism: Add Instance, Import,
and pick the file. It's a snapshot: it doesn't update when the pack does, so export and import
again for a new build. This is also the file to share.

## When the instance won't launch

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
