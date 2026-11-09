# Item, Equipment & Progression Compatibility Standard

This is a mandatory product requirement for NGOC RONG DEN. The target is the recognizable item/equipment gameplay loop of classic Vietnamese side-scrolling Dragon Ball MMORPGs (especially the Ngoc Rong / Chu Be Rong Online style), not a generic fantasy RPG.

## Non-negotiable player-facing systems

- Character status must clearly expose HP, KI, damage/attack, armor/defense, strength/power, potential, level, and experience.
- Equipment is organized by recognizable functional slots: body armor, pants, gloves, boots, head/visor scanner, and weapon/accessory slots where supported by the game design. Each item has a level/requirement, rarity or grade, stat bonuses, upgrade level, and sell value.
- Inventory is a grid/list with item icons, stack counts, descriptions, equip/use/sell actions, and a separate equipment view. Items must not be reduced to a text counter.
- Monster and boss drops must feed the same inventory/equipment/economy loop. Drop tables vary by monster, map, and boss; valuable equipment should not be guaranteed on every kill.
- Equipment upgrades consume defined materials and currency, show success/failure or upgrade result, and update character stats/power immediately. Upgrade rules and rates must be data-driven.
- Consumables include HP/KI recovery items with clear restore values and use limits/cooldowns.
- Shops, NPC rewards, quests, trading, and future player-to-player exchange must use the same item definitions and currency model.
- Item tooltips must show exact requirements and stat changes before equipping/upgrading.
- Android UI must support touch, landscape layout, readable labels, and clear item slots.

## Required item families

1. Armor/clothing: body, pants, gloves, boots.
2. Utility: scanner/visor and other character utility equipment.
3. Weapons/accessories: implemented as separate slots only where appropriate to the chosen original world.
4. Consumables: HP recovery, KI recovery, and temporary buffs.
5. Upgrade materials: stones, crystals, and other clearly defined materials.
6. Quest items and currencies.

## Content and intellectual-property boundary

Match the *systems, categories, player flow, balance philosophy, and interaction patterns* of the reference game as closely as practical. Do not copy its exact item names, sprites, icons, UI artwork, maps, dialogue, proprietary data tables, sounds, or source code. NGOC RONG DEN must use original names and original assets while preserving the familiar gameplay structure.

## Implementation progress (source committed, not yet Godot-tested)

- [x] Starter item database with weapon, body, pants, gloves, boots, scanner, HP/KI consumables, and upgrade materials.
- [x] Functional equipment slots and stat recalculation.
- [x] Inventory/equipment panel with item counts and descriptions; tap/click to equip or consume.
- [x] Monster drops include starter gear categories and recovery items at low probabilities.
- [ ] Illustrated item icons/grid, detailed comparison tooltips, and drag-and-drop.
- [x] Basic item selling from inventory for coins.
- [x] Equipment enhancement interface with material/currency costs, success chance, +10 cap, and stat recalculation.
- [x] Basic shop purchases and per-item selling connected to shared item database and coin currency.
- [ ] NPC shopkeeper interaction, expanded shop stock, boss-specific tables, and persistence.

## Current implementation gap (must not be misrepresented)

The current prototype now has basic functional gear slots, an inventory panel, equip/use actions, and expanded starter drops. It still does NOT have final item artwork/icons, drag-and-drop, expanded NPC shopkeeper interaction, boss-specific drop tables, persistence, or player trading. Basic buying and selling are implemented in the inventory panel. Enhancement values are prototype balance and have not been playtested. Changes are committed but have not yet been run or validated in Godot.

## Acceptance checklist

- [ ] Full inventory UI with item icons, stack counts, item details, and touch interaction.
- [ ] Equipment panel with functional slots and stat recalculation.
- [ ] Monster/map/boss-specific data-driven drop tables.
- [ ] HP/KI consumables with actual use effects.
- [x] Equipment upgrade flow using materials and currency.
- [ ] NPC shop, quest rewards, and sell flow connected to the same item database.
- [ ] Save/load inventory, equipment, currencies, and progression.
- [ ] Android landscape usability review.
