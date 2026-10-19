# Where guns come from

Guns are TaCZ, from the unofficial NeoForge port, with three gun packs on top of its own. This
page covers where you craft them, find them, and keep them working.

**Covers:** `pack/tacz/` and the TaCZ entries in `pack/mods/`

## The gun packs

| Pack | Guns | Crafted at | How it's in the pack |
| --- | --- | --- | --- |
| TaCZ's default pack | The port's own | TaCZ Gun Smith Table (ammo and attachments also at the Ammo Assembly and Attachment tables) | Inside the TaCZ jar |
| Elite X Quality Guns | 47 | Elitebench | A mod jar. Its models need TacZ Mesh Loader, which is client-only |
| TaCZ Fallout (the unofficial port) | 8 | TaCZ Gun Smith Table | A mod jar |
| Create Armorer | 13, Create-themed | Weapon Station, or Create machines (below) | A 1.20.1 zip in `tacz/`, converted when the game loads |

Elite X and Create Armorer keep their guns off TaCZ's tables, so look for an Elite X gun at the
Elitebench and a Create Armorer gun at the Weapon Station, not at the Gun Smith Table. Fallout has
no table of its own and shares the Gun Smith Table. JEI shows each table's recipe.

**Create Armorer is a 1.20.1 pack.** packwiz puts the zip in `<instance>/tacz/`, and TaCZ Pack
Upgrader rewrites it for the port when the game loads. If the guns are missing, check that the
zip is there.

## At the table

TaCZ Addon changes the tables:

- **Hold a gun when you open a table,** in either hand, and it lists only that gun's ammo and
  attachments.
- **Shift-click** to craft in bulk.
- **Materials come from nearby containers,** Sophisticated Backpacks included.
- Each material links to its JEI recipe.

It also lets you hold **Tab and scroll** to cycle through the guns in your inventory, and
**Shift-right-click an ammo box** to pull all the loose ammo in your inventory into it.

## Crafting through Create

Create: Immersive TaCZ Integration adds Create recipes for Create Armorer's guns only:

- **Gun parts** (barrel, trigger mechanism, firing mechanism) made in Create, then the guns from
  those parts and precision mechanisms, on mechanical crafters.
- **Ammo** by the machine: saw brass sheets into casings (put a filter on the saw to pick the
  casing), fill andesite casings with gunpowder for primers, then primers and gunpowder into the
  casings. Gunpowder goes in tanks as a fluid; with Create Big Cannons, nitropowder works too.

The Weapon Station recipes stay. Create is a second way to make the same guns, not the only one.

## Ammo

Each pack's ammo is made at its own table, or the Ammo Assembly Table for the default pack's.

**The ammo box** goes in its own Curios slot (Curios for Ammo Box), and a gun reloads from it
there.

## Chest loot

TaCZ Structure Loot puts the default pack's guns, ammo and attachments into vanilla structure
chests: dungeons, mineshafts, temples, villages, strongholds, fortresses, bastions, trial
chambers and more, 56 vanilla tables in all. YUNG's versions of those structures still use the
vanilla tables for their main chests, but the extra chests they add have their own loot and no
guns. Lootr's per-player chests roll the same tables.

## Turrets

TACZ Turrets fire a gun you give them.

- **Place** by right-clicking a block; the underside of a block hangs it from the ceiling.
- **Load** by right-clicking it: a gun in the gun slot, ammo below. A turret standing on a chest
  or barrel takes matching ammo from it.
- **Pick up** by crouching and right-clicking. You get it back with its gun and ammo.
- **Repair** by right-clicking with iron bars.

Its screen sets power (always on, off, or by redstone), fire mode (aggressive, conservative or
adaptive), and whether it shoots players. It never targets you or your allies, FTB Teams parties
included. The light on it: green ready, yellow reloading, bright red out of ammo, dark red no gun.

## Durability and repair

TaCZ Durability gives each gun 2,000 shots of durability, one per shot, shown when you inspect
the gun. As it wears, the gun gets less accurate and jams more often. Inspect it to clear a jam.
At zero it jams on every shot. Repair it at the Repair Bench with repair items; JEI has both
recipes. Its settings are in each world's `serverconfig/` folder.

## Apotheosis on guns

Apotheosis Modern Ragnarok gives TaCZ guns Apotheosis affixes, gems and rarities like any other
weapon. Some of Brawler's gem bonuses overlap and get skipped ([the mod
list](mods.md#known-rough-edges)).

## Melee

Better Combat changes melee, not guns: no TaCZ item gets a moveset, so left-click still fires and
right-click still aims. Combat Roll's dodge is on R by default, the same key as reload. [Fighting
up close](combat.md) has both.

## Not here

Fiber's Gunspack, Maxstuff and Gucci & Vuitton Attachments were in the old pack. Fiber's isn't on
Modrinth and packwiz can't find it on CurseForge. Maxstuff and Gucci & Vuitton are 1.20.1 only,
and converting them was your call not to make. Create Armorer is the only converted pack.
