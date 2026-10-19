# Fighting up close

Melee with Better Combat: swing animations, combos and arcs that hit more than one mob, with
Combat Roll for a dodge on a key. Guns are unchanged.

**Covers:** `pack/mods/better-combat.pw.toml`, `pack/mods/combat-roll.pw.toml`,
`pack/mods/apothic-combat.pw.toml`

All three run on their defaults, keybinds included. Their settings are files in the instance's
`minecraft/config/bettercombat/` and `minecraft/config/combat_roll/`.

## Swinging a weapon

A weapon with a Better Combat moveset swings with its own animation when you left-click, and holding
the button keeps swinging.

- **Combos.** Each weapon has a sequence of attacks, and clicking again moves to the next one.
  Stop for about three times the weapon's cooldown and the combo starts over.
- **Swing arcs.** A swing hits every mob in its arc, not only the one under the crosshair. Each
  extra target weakens it, down to half damage at five targets. Vanilla's sweep is off; Sweeping
  Edge works on Better Combat's sweep instead.
- **Who gets hit.** Hostile and passive mobs in the arc. Other players,
  villagers, iron golems, your pets and your teammates only when you're looking right at them.
  Swings don't go through walls.
- **You slow down** to half speed while swinging.
- **Two-handed weapons** (greatswords, hammers, spears, scythes and the like) have heavier
  movesets.
- **Dual wielding.** A one-handed weapon in each hand swings both, alternating, 20% faster.

## Which weapons get one

150 items have a moveset. Silent Gear, Create: Ironworks, Iron's Spells, Cataclysm, Farmer's
Delight and Supplementaries ship their own Better Combat data. Everything else is caught by
Better Combat's fallback, which matches the item's name (`sword`, `axe`, `knife`, `hammer`,
`spear`, `staff`, `rod` and so on) and only takes items that deal attack damage.

| From | Has a moveset | Two-handed |
| --- | --- | --- |
| Vanilla | Swords, axes, the mace, the trident | — |
| Silent Gear | Sword, katana, knife, dagger, machete, axe, mace, hammer, spear, sickle, trident, pickaxe, paxel, bow, crossbow | Katana, hammer, spear, paxel, bow, crossbow |
| Iron's Spells | Magehunter, Misery, the amethyst rapier, the claymore, Boreal Blade, both flamberges, both scythes, Spellbreaker, Twilight Gale; its staves, the Artificer's Cane and the lightning rod swing like maces | Claymore, Boreal Blade, both flamberges, both scythes, Spellbreaker, Twilight Gale |
| L_Ender's Cataclysm | The Incinerator, Infernal and Void Forge, Ceraunus, Astrape, Ancient Spear, the coral spear and bardiche, Athame, the gauntlets and Tidal Claws, and the black steel sword and axe | Incinerator, both forges, Ceraunus, Astrape, Ancient Spear, coral spear and bardiche |
| Mowzie's Mobs | Wrought Axe, Spear, Naga Fang Dagger, Earthrend Gauntlet, Sculptor Staff | Spear |
| Create: Ironworks | Its swords, axes, paxels and hammers | Hammers |
| Other Create addons | Swords and axes from Stuff 'N Additions, Quality of Life, Deep Dark, Confectionery and TFMG; Misc and Things' knives; Create's cardboard sword | — |
| Everything else | Knives from Farmer's Delight, End's Delight and Aquaculture; Aquaculture's neptunium sword and axe; Deeper and Darker's swords and axes; Ars Nouveau's Enchanter's Sword; Alex's Mobs' Skelewag Sword | — |

A few tools got one too: Farmer's Delight's skillet and Diesel Generators' hammer swing like
maces, Supplementaries' wrench like a dagger, and Create Big Cannons' ram rod like a wand.
Vanilla pickaxes, shovels and hoes don't.

**Without one,** a weapon attacks the vanilla way: TaCZ's guns, Ars Nouveau's wands and spell
staves, most of Alex's Mobs' and Cataclysm's other weapons.

## Rolling

Combat Roll adds a dodge: press **R** and you roll about three blocks the way you're moving.

- **R is TaCZ's reload,** and Iron's Spells uses R too. Rebind the roll in Options → Controls →
  Key Binds (Controlling's search finds it as "Roll").
- **One roll,** then a 4-second recharge.
- **No invulnerability.** A roll gets you out of the way; it doesn't make you immune.
- **During a roll** you can't attack, use an item or jump, so a gun can't fire mid-roll.
- **You can't roll** in the air, while your weapon is on cooldown, or with 3 food shanks or fewer.
  Each roll costs a little hunger.

Three enchantments, from the enchanting table:

| Enchantment | Goes on | Does | Max |
| --- | --- | --- | --- |
| Multi-Roll | Helmet | One more roll per level before the recharge | III |
| Acrobat | Chestplate | Recharges 20% faster per level | V |
| Longfooted | Boots | Rolls one block further per level | IV |

## Apotheosis

Better Combat weapons roll Apotheosis affixes and take gems like any other weapon.

Apothic Combat, at the version for 1.21.1, only tidies the tooltip: it hides Better Combat's
weapon lines and the vanilla reach line, and shows one attack-range line worked out from your
reach. Its Modrinth page describes the 1.20.1 mod, which made two-handers Apotheosis heavy
weapons and turned the attack-range affix off. This one does neither. Better Combat reads a
swing's reach from your entity reach, so an attack-range affix should lengthen your swings.

## Guns

Unchanged. No TaCZ item has a Better Combat moveset, so left-click fires and right-click aims as
before, and TaCZ's melee key (V) still does a gun's melee or bayonet attack. If either stops
working, Better Combat and Combat Roll come out: that's the condition they're in on.

## Not yet

- **Balance between melee and guns.** Damage numbers are each mod's own. That's the melee parity
  pass, still to come.
- **Movesets for the weapons the fallback misses** (most of Alex's Mobs' and Cataclysm's) need
  weapon data written for them, in the same pass.
- **Keybinds.** The roll stays on R until the integrations work sets the pack's keys.
