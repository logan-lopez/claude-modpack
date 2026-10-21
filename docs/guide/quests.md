# The quest book

FTB Quests' quest book, which the pack ships and keeps in the repo. Today it has one short sample
chapter; real chapters come later, drafted by minecraft-mcp.

**Covers:** [The quest book](../architecture/quests.md)

## Opening it

Click **Quests** in the buttons FTB Library adds beside the inventory screen. FTB Quests also has
an "Open Quests" key, unbound by default; set one in Controls if you want it (check for clashes
first).

## What's in it

**Getting Started**, three quests in a row, left to right:

1. **A Crafting Table:** craft one.
2. **Andesite Alloy:** Create's andesite alloy. Locked until the first is done.
3. **A Shaft:** a Create shaft, with 100 XP to claim. Locked until the second is done.

It's there to show the format works end to end, and will be replaced.

## Editing in the game

Turn on edit mode with `/ftbquests editing_mode` (cheats on in single-player). You can then drag
quests, add them and change their text in the book.

**The repo's copy is the real one.** An edit you make in the game lives only in your instance
until you bring it back:

1. Quit the world, to the title screen or out of the game. FTB Quests saves the book when the
   world saves, so a running world may not have written your edit yet.
2. From the repo, run `scripts/pull-quests.sh`. It copies the instance's book into
   `pack/config/ftbquests/quests/` and prints what changed. With another instance, give its
   `minecraft` folder as the argument.
3. Look at the diff and commit it.

If someone else (minecraft-mcp, say) has changed the book in the repo and not committed it yet,
the script refuses rather than overwrite their quests. `FORCE=1 scripts/pull-quests.sh`
overwrites them anyway.

## If you don't pull

Your edit stays in the instance through every launch, as long as the pack doesn't change the same
file. The first sync after the repo changes that chapter (or the text file, for any title or
description) replaces your copy with the repo's, and the edit is gone. So pull before the next
change to the book, not before every launch.

## On a server

The server zip carries the book, so players on a server built from it get the same quests. An
edit made on that server stays on that server, and the next zip unzipped over it replaces it.
A chapter the pack dropped stays on an updated server until you delete it from its
`config/ftbquests/quests/chapters/`.

## What it doesn't do yet

- No real chapters, and no rewards beyond the sample's XP.
- Nothing pulls edits from a server back into the repo; `scripts/pull-quests.sh` reads a Prism
  instance's folder, though any folder shaped like one works.
