Claude Modpack server
=====================

A Minecraft 1.21.1 server on NeoForge, with the pack's mods already inside.


What you need
-------------

- Java 21. Get Temurin 21 from https://adoptium.net/temurin/releases/?version=21
  It has to be 21: an older or newer Java won't run it. Java 21 installs
  alongside any other Java you have.
- More free memory than the server is given: 12 GB by default (see Memory).


Starting it
-----------

1. Unzip this folder wherever the server should live.
2. Start it:
   - macOS or Linux: open Terminal, cd into the folder, and run ./start.sh
     (Double-clicking a .sh file opens it in an editor instead.)
   - Windows: double-click start.bat.

The first start downloads Minecraft's server, which takes a minute, then
asks whether you accept the Minecraft EULA (https://aka.ms/MinecraftEULA).
Answer y and the server starts. It won't ask again.

The window is the server console: type commands there without the slash,
and type stop to shut it down. If the server crashes while running, the
script restarts it after 10 seconds; press Ctrl+C during the countdown to
quit instead. It doesn't restart after a stop, or when it fails to load.


Settings
--------

- Memory: the -Xmx line in user_jvm_args.txt. -Xmx12G is 12 GB.
- Everything else: server.properties (difficulty, view distance, the
  message in the server list, and so on). A fresh server allows flight,
  because Create contraptions, jetpacks and rockets need it, and plays on
  Hard. The whitelist is off.

Both files are made on the first start from the copies in defaults/. Edit
the ones next to start.sh, not those in defaults/.

Restart the server after changing either.


Letting people in
-----------------

Players connect on port 25565. From outside your network, forward that
port on your router to this machine.

Players need the matching client pack: the .mrpack file of the same version
as this zip, imported into Prism Launcher or another launcher that reads
.mrpack files. A different version of the pack won't connect.


Updating to a new version
-------------------------

1. Back up the world/ folder first. Simple Backups also makes backups on
   the server, in simplebackups/.
2. Type stop in the console and wait for the script to exit.
3. Delete the mods/, kubejs/ and tacz/ folders. Mods the new version
   removed would otherwise stay.
4. Unzip the new zip somewhere else. Its folder is named after the new
   version, so copy everything inside it into this folder, replacing files
   when asked.
5. Start it again.

The world, server.properties, user_jvm_args.txt and the EULA answer stay as
they are: the zip never contains them. If the new version needs a different
NeoForge, the first start installs it.
