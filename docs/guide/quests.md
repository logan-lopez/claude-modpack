# The quest book

FTB Quests' quest book, which the pack ships and keeps in the repo. It has a short sample chapter
and two real ones, on Create, drafted by minecraft-mcp.

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

**Create: Andesite to Precision**, beside it: Create's early game in 19 quests. It starts at
andesite alloy and shafts, builds the water wheel and the mechanical press for iron sheets, then
the mixer, basin and blaze burner for brass, and ends at the deployer and the precision mechanism
it assembles. Zinc and polished rose quartz are side branches you can start at any time. Each
quest says how to make its item, and gives 25 to 100 XP.

**Create: Mechanical Crafting**, after it: 11 quests, locked until the precision mechanism is
done. Brass casing makes mechanical crafters, 21 of which build a pair of crushing wheels; crushed
iron, washed with an encased fan, gives more iron per ore. The mechanical arm, the rotation speed
controller and the crafters' tools (the extendo grip, the potato cannon and the wand of symmetry)
branch off on the way. Bulk Washing is a box to tick rather than items to hand in.

Four more Create chapters follow, each locked until a quest in the first two:

- **Create: Contraptions**, 16 quests, after the andesite casing: the mechanical bearing, then
  windmills, glue and chassis, pistons, gantries and pulleys, and the drill, saw, harvester and
  plough that work on the move. It ends at the clockwork bearing and the elevator pulley.
- **Create: Fluids and Steam**, 12 quests, after the mechanical press: copper sheets and pipes,
  the mechanical pump, valves, the fluid tank, the spout, item drain and hose pulley, and the
  steam engine that turns a heated tank into a boiler.
- **Create: Logistics**, 17 quests, after the andesite casing: depots, belts, chutes and
  funnels, then the brass funnels and tunnels, and packages: cardboard, the packager, chain
  conveyors and frogports, stock links and the factory gauge, ending at the stock ticker.
- **Create: Trains**, 12 quests, after the crushing wheels: track, sturdy sheets and train
  casing, then the station, controls, schedule and signals, and two pieces from Steam 'n' Rails
  (the train coupler and the fuel tank). All Aboard, ticked once a train runs its schedule, ends
  it.

**Industry**, the third group, holds Create's big addons:

- **Create: Electricity**, 14 quests, after the mechanical crafters: Crafts & Additions' copper
  wire and rolling mill, spools and connectors, the alternator and electric motor, the tesla coil
  that charges gold into electrum, and the accumulator that stores power.
- **Create: More Machines**, 13 quests, after the mechanical crafters: Create Connected's kinetic
  battery, then Create Ore Excavation's drill, vein finder, drilling machine and fluid well
  extractor, Dreams and Desires' industrial fan, catalyst sails and hydraulic press, and Petrol's
  Parts' differential, gearsets, colossal cogwheel and pneumatic tube.
- **Steel and Alloys**, 13 quests, after the mechanical pump: The Factory Must Grow's fireproof
  bricks and coke ovens, the blast furnace with its hatches, flux, reinforcements and blast stove,
  a first batch of steel mixed in a heated basin, and the casting basin. Steel Ingot, the last
  quest, opens the chapters built on steel.
- **Create: Enchantment Industry**, 8 quests, after the spout: the experience lantern, the
  mechanical grindstone that turns experience into a liquid, the experience hatch, printer and
  infuser, and the blaze forger and blaze enchanter with enchanting templates.

The rest of the book is planned in minecraft-mcp's
[outline](../../../minecraft-mcp/docs/design/quest-book.md): its groups, chapters and the order
they're drafted in.

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

- One real chapter so far, and no rewards beyond XP.
- Nothing pulls edits from a server back into the repo; `scripts/pull-quests.sh` reads a Prism
  instance's folder, though any folder shaped like one works.
