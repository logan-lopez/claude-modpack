# What's in the pack

The mods the pack ships, grouped by what they're for, the mods from the old 1.20.1 pack that
didn't come over, with why, and what stands in for them. Compare it with the old list
(`docs/briefs/assets/02/old-modlist.txt`) to decide what to add back.

**Covers:** `pack/mods/`, `pack/tacz/`

288 entries in `pack/mods/`: about 200 picked from the old pack, 23 added as replacements and new
picks, 9 TaCZ gun packs and addons, the rest libraries they need. The server loads 264 jars; the
other 24 are client-only (Sodium, Iris and their add-ons, the tooltip and overlay mods, TacZ Mesh
Loader, and the like). `pack/tacz/` has one more entry, the Create Armorer gun pack.

## What's in

**Create and the guns.** The core of the pack: Create, the TaCZ port and TaCZ Tweaks.

**TaCZ gun packs and addons.** Where guns come from and what they do, in [their own
page](guns.md): the Elite X Quality Guns and TaCZ Fallout gun packs, Create Armorer (a 1.20.1 gun
pack in `pack/tacz/`, converted on load by TaCZ Pack Upgrader), TaCZ Addon (a better gunsmith
table), Endless Ammo Refabricated, TaCZ Durability, TACZ Turrets, TaCZ Structure Loot (guns in
structure chests), Curios for Ammo Box, Immersive TaCZ Integration (Create recipes for Create
Armorer's guns), and Apotheosis Modern Ragnarok (below).

**Apotheosis.** Affixes, gems, spawner and enchanting rework, and the gateways to farm them:
Apotheosis with its Apothic Attributes, Enchanting and Spawners modules, Gateways to Eternity,
Apotheosis Modern Ragnarok (Apotheosis affixes on TaCZ guns), Apothic Category Compat (puts
modded weapons, Cataclysm's among them, in the right Apotheosis loot categories), AttributeFix,
Max Health Fix, Enchantment Descriptions.

**Mobs and bosses.** Wildlife and fights: Alex's Mobs Continued (the community port) and its
Delight addon, Naturalist, Mowzie's Mobs, L_Ender's Cataclysm.

**Create, the big addons.** New machines, power, trains and decoration: Steam 'n' Rails (the
community port), The Factory Must Grow (oil, steel and heavy industry), Dreams & Desires,
Crafts & Additions, Enchantment Industry, Deco, Big Cannons, New Age, Connected, Copycats+,
Diesel Generators, Encased, Quality of Life, Bells & Whistles, Interiors, Slice & Dice, Petrol's
Parts, Pattern Schematics, Framed, Goggles, Filters Anywhere, Contraption Terminals, Ender Link,
Ore Excavation, Power Loader, Trading Floor.

**Create, the rest.** Smaller addons, most of them themed content or compat: Central Kitchen,
Confectionery, Stuff 'N Additions, Compressed, Deep Dark, Easy Structures, Factory, Ironworks,
Jetpack and its Curios slot, Kart, Let The Adventure Begin, Mechanical Extruder, Mechanical
Spawner, Misc and Things, Ranged, Structures Arise, Ultimate Factory, Waystones Recipes, Winery,
Wizardry, Addon Compatibility, Teleporters, Ultimine, Molten Vents, Dynamic Village, Recycled,
Ars Creo (Ars Nouveau with Create).

**Storage and tech.** Somewhere to put it all, and the scripting to change recipes later:
Sophisticated Backpacks and Storage with their Create integrations, Tom's Simple Storage,
EnderChests, Trash Cans, Dank Storage, LaserIO, CC: Tweaked, KubeJS, Almost Unified.

**Magic and gear.** Spells, artifacts and tools: Ars Nouveau and Ars Elemental, Iron's Spells 'n
Spellbooks, Artifacts, Relics, Reliquary Reincarnations, Silent Gear, Silent's Gems, Jewelry,
Time in a Bottle, Dark Utilities, Iron Furnaces, Productive Bees, Aquaculture 2, Small Ships,
Ad Astra with the Giselle addon, Akashic Tome, Morph-o-Tool, Comforts, Building Gadgets, Tool
Belt, Hyperbox.

**Worldgen.** New biomes and better structures: Biomes O' Plenty, Terralith, Deeper and Darker,
When Dungeons Arise, Explorify, Towns and Towers, Repurposed Structures, Lootr, and YUNG's
Better Desert Temples, Dungeons, End Island, Jungle Temples, Mineshafts, Nether Fortresses, Ocean
Monuments, Strongholds, Witch Huts and Extras.

**Food.** Farmer's Delight, My Nether's Delight, End's Delight (a beta), Chef's Delight (Farmer's
Delight villagers), Cooking for Blockheads, Farming for Blockheads, Aquaculture Delight, Ocean's
Delight, Spice of Life: Carrot Edition.

**Building and decoration.** Blocks to build with: Macaw's Bridges, Doors, Fences and Walls,
Furniture, Lights and Lamps, Paths and Pavings, Roofs, Stairs, Trapdoors and Windows; Chipped,
Rechiseled with its Chipped and Create addons, Supplementaries, Amendments, FramedBlocks,
Connected Glass, ConnectedTexturesMod, Additional Lanterns, Additional Placements, TorchMaster,
Construction Wand (the KOTS fork).

**Quality of life.** Getting around and doing less busywork: Waystones, Carry On, FallingTree,
FTB Ultimine, FTB Chunks and Teams (claims and parties), FTB Essentials (homes, `/back`,
`/spawn`), Explorer's Compass, Nature's Compass, RightClickHarvest, Simple Magnets, ElevatorMod,
Easy Villagers, Corail Tombstone, Inventory Essentials, Inventory Sorter, Crafting Tweaks, Mouse
Tweaks, TrashSlot, Controlling, AppleSkin, Bridging Mod, Animal Feeding Trough, Anvil
Restoration, Pylons, Elytra Slot, Lamb Lanterns (a Curios slot for a lantern), DodoSpyglass (a
Curios slot for the spyglass), MmmMmmMmmMmm (target dummies), Rotten Flesh to Leather,
Measurements, Pig Pen Cipher, Leaves Be Gone, Clean Swing Through Grass.

**Seeing what's going on.** Recipes, tooltips and the map: JEI with Just Enough Resources,
Professions, Breeding and Archaeology; Jade and Jade Addons; JourneyMap; Legendary Tooltips,
Equipment Compare, Durability Tooltip, More Overlays Updated, Transmog, Visual Workbench,
AmbientSounds, Freecam, No Chat Reports, LambDynamicLights (light from a held torch or a worn
lantern).

**Performance.** Sodium and Iris for rendering and shaders, both held at fixed versions (Sodium
0.8.12, Iris 1.8.14-beta.1, the Iris built for Sodium 0.8), with Sodium Extra, Reese's Sodium
Options (the reorganized Video Settings) and Chloride, and ModernFix, FerriteCore,
ImmediatelyFast, Entity Culling, BadOptimizations, Noisium, FastFurnace, FastWorkbench,
FastSuite, Clumps, ServerCore, spark.

**Libraries.** In because something above needs them, not picked by hand: Architectury, Balm,
Bookshelf, Caelus, CodxLib, Collective, Common Storage Lib, Create: Dragons Plus, CreativeCore,
Cristel Lib, Curios, FTB Library, Fusion, Geckolib, GlitchCore, Gunsmith Lib, Iceberg, Iron's
Lib, JamLib, Kotlin for Forge, Lionfish API, Mechanicals Lib, MezzConfig, Moonlight, Patchouli,
Petrolpark's Library, Placebo, playerAnimator, Prickle, Prism, Puzzles Lib, Ranged Weapon API,
Resourceful Config and Lib, Rhino, Better Advanced Tooltips, Ritchie's Projectile Library,
Searchables, ShatterLib, ShetiPhianCore, Silent Lib, SmartBrainLib, Sophisticated Core, Spell
Power Attributes, Structure Pool API, SuperMartijn642's Core and Config Lib, TacZ Mesh Loader,
TerraBlender, Athena, YACL, YUNG's API.

## Replaced

Old mods with no 1.21.1 build, and what does their job now. Checked 2026-10-19.

| Old mod | Stands in for it |
| --- | --- |
| Alex's Mobs | Alex's Mobs Continued, a community port. |
| Alex's Delight | Alex's Mobs Continued Delight. |
| Nether's Delight | My Nether's Delight. |
| Construction Wand | Construction Wand - KOTS, a fork. |
| Curious Lanterns | Lamb Lanterns, with LambDynamicLights for the light. |
| Spyglass of Curios | DodoSpyglass. |
| Create TaCZ Automation | Create: Immersive TaCZ Integration, with the Create Armorer gun pack it works through. |
| Endless Ammo | Endless Ammo Refabricated, a 1.21.1 rebuild of it. |
| Gun Durability | TaCZ Durability 2.2.2, the same mod (`gundb`) under a new name. |
| Create Recycle | Create: Recycled, a different mod for the same job. |
| Embeddium, Oculus | Sodium and Iris. |
| Sodium Extras (Embeddium Extras in the old pack) | Sodium Extra 0.9.3, with Reese's Sodium Options for its menus. |
| Sodium Dynamic Lights | LambDynamicLights. |
| Chloride | Chloride itself, at a build that runs on Sodium 0.8. |

## Left behind

From the old pack, checked 2026-10-19.

| Old mod | Why |
| --- | --- |
| MineColonies, Jade Colonies, Town Talk, Colony Curios | Your call. The addons also have no 1.21.1 build. |
| Create Ad Astra Compat, Create Ad Astra Recipes, Ad Astra: Rocketed | No 1.21.1 build. KubeJS recipes can stand in, later. |
| Apotheotic Additions, Apothic Curios | No 1.21.1 build, and no replacement found. |
| Delightful, Silent's Delight | No 1.21.1 build, and no replacement found. |
| Structure Essentials, Silent Compat, Additional Lights | Not found for 1.21.1 on Modrinth or CurseForge. |
| FTB Ultimine Addition | Its author has turned off third-party downloads on CurseForge, so packwiz can't fetch it, nor its library CoolCatLib. Adding it would mean putting the jar in the instance by hand. |
| LesRaisinsAddon, Create Planetary Tweaks | Built for other modpacks. |
| AllTheLeaks, Better FPS Distance, Better Compatibility Checker | 1.20.1 fixes, or only useful when publishing a pack. |
| Sodium Options API, Sodium Options Mod Compat | Every Reese's Sodium Options 2.2.x declares Options API incompatible, and Reese's is in. Mod Compat needs Options API. |
| FTB Quests, FTB XMod Compat | Waiting for a quest book. A new pack has no quests yet, and XMod Compat is mostly Quests integration. |
| Fiber's Gunspack | Not on Modrinth, and packwiz's CurseForge search doesn't find it. |
| Maxstuff, Gucci & Vuitton Attachments | 1.20.1 gun packs only. TaCZ Pack Upgrader could convert them; your call was to leave them out. Elite X and Fallout, the other two old gun packs, came back with 1.21.1 builds ([Where guns come from](guns.md)). |
| Mods disabled in the old pack (`.jar.disabled`) | You had turned them off. |

## Held back on purpose

Pinned in packwiz, so `packwiz update` leaves them alone:

- **Sodium 0.8.12 and Iris 1.8.14-beta.1.** Iris for 1.21.1 was built against Sodium
  0.8.12-beta.1 and hasn't been rebuilt since, so Sodium stays on the release nearest it.
- **Sodium Extra 0.9.3 and Reese's Sodium Options 2.2.3.** The newer builds (0.9.4, 2.2.4) need
  Sodium 0.8.13, so these are the last that run on the pinned Sodium.
- **JEI 19.56.** Petrolpark's Library (needed by Petrol's Parts) only accepts JEI below 19.57,
  because it patches JEI's code. Newer JEI stops the game at the loading screen.

## Known rough edges

- **Small Ships logs an error when the server stops,** while unloading its server config. It's
  noise: a dedicated server has already saved by then, and Save and Quit from a single-player
  world goes through cleanly.
- **Apotheosis Modern Ragnarok's Brawler's gems** have gun bonuses whose categories overlap, and
  Apotheosis skips the ones that clash, so those gems may do less on guns than you'd expect.
- **Just Enough Breeding is likely missing six Alex's Mobs entries** (the rattlesnake, Tasmanian
  devil, triops, warped toad, straddler and warped mosco). It loads its Alex's Mobs recipes only
  when Alex's Mobs is in, and those six don't parse.
- **Endless Ammo Refabricated's calibers have no guns yet.** It's an ammo library for gun packs,
  and none of the four here use it, so its 52 ammo types and Ammo Bench are craftable but fire
  from nothing.
