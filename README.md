# NGỌC RỒNG ĐEN

An original 2D side-scrolling online RPG project built with **Godot 4**, targeting Android landscape first.

## Current prototype
- Side-view player movement and jumping
- Energy projectile attack
- Chasing enemy with contact damage
- HP, KI, strength, defense, potential, EXP, and level progression
- Three original zones with different monster strength and EXP rewards
- Guide NPC with a 3-monster quest and EXP/potential rewards
- Zone portal travel with zone-specific color palettes
- Three monster archetypes with increasing HP, speed, damage, and EXP
- Random collectible drops: coins, upgrade stones, crystals, and a starter weapon
- Item database with six functional equipment slots (weapon, body, pants, gloves, boots, scanner)
- Touch-friendly inventory/equipment panel toggled with I on desktop or TÚI ĐỒ on mobile
- Equip/unequip flow with stat recalculation, plus usable HP/KI recovery consumables
- Monster drops include coins, upgrade materials, recovery items, and low-chance equipment
- Touch interaction button for Android NPC quests
- Keyboard controls for desktop testing
- Original placeholder vector visuals; no copyrighted game assets

## Controls
- **A / Left Arrow**: move left
- **D / Right Arrow**: move right
- **Space**: jump
- **J**: melee attack
- **K**: fire energy projectile
- **E**: interact with the guide NPC
- **I**: open/close inventory and equipment

## Run
1. Install Godot 4.2 or newer.
2. Clone or download this repository.
3. Import the folder containing `project.godot`.
4. Press **F6** or **F5** to run the main scene.

## Project status
This is an evolving offline gameplay prototype, not yet a complete MMORPG. The three-zone travel loop and a basic NPC quest are implemented in source. Online accounts, authoritative multiplayer server, persistence, matchmaking, chat, PvP, equipment upgrade interface, item selling, shop, boss-specific loot tables, persistence, bosses, polished art/animation, online server, and Android export configuration remain future milestones. The latest changes have not yet been run or validated in the Godot editor.

## Structure
- `scenes/`: playable game scenes
- `scripts/`: gameplay logic

All names, characters, visuals, and code in this project are original placeholders and are not affiliated with any existing franchise.


## Gameplay direction
The target is a close genre-level experience to classic 2D side-scrolling MMORPGs such as Chú Bé Rồng Online: horizontal movement, combat, skills, HP/KI-style resource HUD, monster grinding, quests, NPCs, map travel, progression, bosses, and real multiplayer social systems. This is a gameplay reference only. NGỌC RỒNG ĐEN uses original characters, maps, names, art, audio, writing, and code. See [Gameplay Direction](docs/GAMEPLAY_DIRECTION.md).


## Mandatory item/equipment direction

Item categories, equipment slots, drop progression, consumables, upgrades, and inventory interactions must follow the recognizable gameplay structure of classic Ngoc Rong Online / Chu Be Rong Online. The project must not become a generic RPG item system. Exact proprietary names, sprites, icons, artwork, maps, and data are replaced with original content. See [Item & Equipment Standard](docs/ITEMS_AND_EQUIPMENT_SPEC.md).


The inventory panel is an early functional implementation: item rows show names, counts, descriptions, and allow equipping gear or consuming recovery items. Visual icons, drag-and-drop, selling, upgrades, and save persistence are not implemented yet.
