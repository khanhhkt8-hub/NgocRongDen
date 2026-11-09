extends CharacterBody2D

signal stats_changed
signal inventory_changed

const ENERGY_BALL = preload("res://scenes/EnergyBall.tscn")
const ITEM_DB := {
	"kiem_tan_thu": {"name": "Kiếm tập sự", "type": "equipment", "slot": "weapon", "attack": 4, "defense": 0, "hp": 0, "ki": 0, "power": 200, "description": "Vũ khí khởi đầu dành cho chiến binh mới."},
	"ao_tap_su": {"name": "Áo tập sự", "type": "equipment", "slot": "body", "attack": 0, "defense": 2, "hp": 10, "ki": 0, "power": 120, "description": "Áo bảo hộ cơ bản, tăng sức chống chịu."},
	"quan_tap_su": {"name": "Quần tập sự", "type": "equipment", "slot": "pants", "attack": 0, "defense": 1, "hp": 5, "ki": 0, "power": 80, "description": "Quần luyện tập nhẹ và bền."},
	"gang_tap_su": {"name": "Găng tập sự", "type": "equipment", "slot": "gloves", "attack": 2, "defense": 0, "hp": 0, "ki": 0, "power": 100, "description": "Găng tay tăng lực đánh."},
	"giay_tap_su": {"name": "Giày tập sự", "type": "equipment", "slot": "boots", "attack": 0, "defense": 1, "hp": 0, "ki": 5, "power": 80, "description": "Giày nhẹ giúp di chuyển linh hoạt."},
	"rada_tap_su": {"name": "Rada tập sự", "type": "equipment", "slot": "head", "attack": 0, "defense": 0, "hp": 0, "ki": 10, "power": 90, "description": "Thiết bị hỗ trợ quan sát năng lượng."},
	"binh_hp_nho": {"name": "Đậu hồi phục nhỏ", "type": "consumable", "hp_restore": 45, "ki_restore": 0, "description": "Hồi 45 HP."},
	"binh_ki_nho": {"name": "Nước hồi KI", "type": "consumable", "hp_restore": 0, "ki_restore": 35, "description": "Hồi 35 KI."},
	"da_nang_cap": {"name": "Đá nâng cấp", "type": "material", "description": "Nguyên liệu dùng để nâng cấp trang bị."},
	"tinh_thach": {"name": "Tinh thạch", "type": "material", "description": "Nguyên liệu quý dùng trong chế tạo và nâng cấp."}
}
const EQUIPMENT_SLOTS := ["weapon", "body", "pants", "gloves", "boots", "head"]
const SLOT_NAMES := {"weapon": "Vũ khí", "body": "Áo", "pants": "Quần", "gloves": "Găng", "boots": "Giày", "head": "Rada"}

@export var move_speed: float = 300.0
@export var jump_velocity: float = -560.0
@export var attack_cooldown: float = 0.35
@export var melee_cooldown: float = 0.45

var max_hp: int = 120
var hp: int = 120
var max_ki: int = 100
var ki: int = 100
var strength: int = 12
var defense: int = 3
var potential: int = 0
var power: int = 1000
var exp_points: int = 0
var level: int = 1
var coins: int = 0
var inventory: Dictionary = {}
var equipment: Dictionary = {"weapon": "", "body": "", "pants": "", "gloves": "", "boots": "", "head": ""}
var equipment_levels: Dictionary = {"weapon": 0, "body": 0, "pants": 0, "gloves": 0, "boots": 0, "head": 0}
var equipped_weapon: String = "Chưa có"
var weapon_bonus: int = 0
var equipment_attack: int = 0
var equipment_defense: int = 0
var equipment_hp: int = 0
var equipment_ki: int = 0
var equipment_power: int = 0
var potential_hp_bonus: int = 0
var potential_ki_bonus: int = 0
var facing: int = 1
var attack_timer: float = 0.0
var melee_timer: float = 0.0
var ki_regen_timer: float = 0.0
var invulnerable_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	add_to_group("player")
	stats_changed.emit()
	inventory_changed.emit()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	var axis := Input.get_axis("move_left", "move_right")
	if axis != 0.0:
		facing = 1 if axis > 0.0 else -1
	velocity.x = axis * move_speed
	attack_timer = maxf(0.0, attack_timer - delta)
	melee_timer = maxf(0.0, melee_timer - delta)
	invulnerable_timer = maxf(0.0, invulnerable_timer - delta)
	ki_regen_timer += delta
	if ki_regen_timer >= 1.0:
		ki_regen_timer = 0.0
		ki = mini(max_ki, ki + 2)
		stats_changed.emit()
	if Input.is_action_just_pressed("attack"):
		melee_attack()
	if Input.is_action_just_pressed("ki_blast"):
		fire_energy()
	move_and_slide()

func melee_attack() -> void:
	if melee_timer > 0.0:
		return
	melee_timer = melee_cooldown
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var offset: Vector2 = enemy.global_position - global_position
		if absf(offset.x) <= 78.0 and absf(offset.y) <= 72.0 and signf(offset.x) == float(facing):
			enemy.take_hit(strength + weapon_bonus + level * 2)

func fire_energy() -> void:
	if attack_timer > 0.0 or ki < 8:
		return
	attack_timer = attack_cooldown
	ki -= 8
	stats_changed.emit()
	var shot = ENERGY_BALL.instantiate()
	shot.direction = facing
	shot.damage = (strength + weapon_bonus) * 2 + level * 3
	shot.global_position = global_position + Vector2(34.0 * facing, -12.0)
	get_tree().current_scene.add_child(shot)

func collect_item(item_id: String, amount: int, _display_name: String = "") -> void:
	if amount <= 0:
		return
	if item_id == "dong_xu":
		coins += amount
	elif ITEM_DB.has(item_id):
		inventory[item_id] = int(inventory.get(item_id, 0)) + amount
		if item_id == "kiem_tan_thu" and equipment["weapon"] == "":
			equip_item(item_id)
	inventory_changed.emit()
	stats_changed.emit()

func equip_item(item_id: String) -> bool:
	if not ITEM_DB.has(item_id) or int(inventory.get(item_id, 0)) <= 0:
		return false
	var data: Dictionary = ITEM_DB[item_id]
	if String(data.get("type", "")) != "equipment":
		return false
	var slot := String(data.get("slot", ""))
	if not EQUIPMENT_SLOTS.has(slot):
		return false
	var previous := String(equipment.get(slot, ""))
	if previous != "":
		inventory[previous] = int(inventory.get(previous, 0)) + 1
	inventory[item_id] = int(inventory.get(item_id, 0)) - 1
	if int(inventory[item_id]) <= 0:
		inventory.erase(item_id)
	equipment[slot] = item_id
	equipment_levels[slot] = 0
	_refresh_equipment_stats()
	inventory_changed.emit()
	stats_changed.emit()
	return true

func use_item(item_id: String) -> bool:
	if not ITEM_DB.has(item_id) or int(inventory.get(item_id, 0)) <= 0:
		return false
	var data: Dictionary = ITEM_DB[item_id]
	if String(data.get("type", "")) != "consumable":
		return false
	var old_hp := hp
	var old_ki := ki
	hp = mini(max_hp, hp + int(data.get("hp_restore", 0)))
	ki = mini(max_ki, ki + int(data.get("ki_restore", 0)))
	if hp == old_hp and ki == old_ki:
		return false
	inventory[item_id] = int(inventory[item_id]) - 1
	if int(inventory[item_id]) <= 0:
		inventory.erase(item_id)
	inventory_changed.emit()
	stats_changed.emit()
	return true

func item_action(item_id: String) -> String:
	if not ITEM_DB.has(item_id):
		return "Không tìm thấy vật phẩm."
	var item_type := String(ITEM_DB[item_id].get("type", ""))
	if item_type == "equipment":
		return "Đã trang bị." if equip_item(item_id) else "Không thể trang bị vật phẩm này."
	if item_type == "consumable":
		return "Đã sử dụng." if use_item(item_id) else "Chưa cần sử dụng hoặc không thể dùng."
	return "Đây là nguyên liệu nâng cấp."

func _refresh_equipment_stats() -> void:
	equipment_attack = 0
	equipment_defense = 0
	equipment_hp = 0
	equipment_ki = 0
	equipment_power = 0
	for slot in EQUIPMENT_SLOTS:
		var item_id := String(equipment.get(slot, ""))
		if item_id != "" and ITEM_DB.has(item_id):
			var data: Dictionary = ITEM_DB[item_id]
			var upgrade_level := int(equipment_levels.get(slot, 0))
			equipment_attack += int(data.get("attack", 0)) + upgrade_level * 2
			equipment_defense += int(data.get("defense", 0)) + upgrade_level
			equipment_hp += int(data.get("hp", 0)) + upgrade_level * 5
			equipment_ki += int(data.get("ki", 0)) + upgrade_level * 3
			equipment_power += int(data.get("power", 0)) + upgrade_level * 100
	max_hp = 120 + (level - 1) * 12 + equipment_hp + potential_hp_bonus
	max_ki = 100 + (level - 1) * 8 + equipment_ki + potential_ki_bonus
	hp = mini(hp, max_hp)
	ki = mini(ki, max_ki)
	weapon_bonus = equipment_attack
	equipped_weapon = String(ITEM_DB[equipment["weapon"]]["name"]) if equipment["weapon"] != "" else "Chưa có"
	power = 1000 + (level - 1) * 250 + equipment_power + strength * 50 + defense * 30


func get_upgrade_info(slot: String) -> Dictionary:
	if not equipment.has(slot) or String(equipment.get(slot, "")) == "":
		return {"ok": false, "message": "Ô trang bị này đang trống."}
	var current_level := int(equipment_levels.get(slot, 0))
	if current_level >= 10:
		return {"ok": false, "message": "Trang bị đã đạt cấp nâng tối đa +10."}
	var stone_cost := 1 + int(current_level / 3)
	var crystal_cost := 1 if current_level >= 3 else 0
	var coin_cost := 100 + current_level * 150
	var chance := maxi(30, 90 - current_level * 6)
	return {"ok": true, "level": current_level, "next_level": current_level + 1, "stone": stone_cost, "crystal": crystal_cost, "coins": coin_cost, "chance": chance, "message": "Nâng lên +%d | %d%% thành công | cần %d đá, %d tinh thạch, %d xu." % [current_level + 1, chance, stone_cost, crystal_cost, coin_cost]}

func upgrade_equipped(slot: String) -> String:
	var info := get_upgrade_info(slot)
	if not bool(info.get("ok", false)):
		return String(info.get("message", "Không thể nâng cấp."))
	if int(inventory.get("da_nang_cap", 0)) < int(info["stone"]):
		return "Không đủ đá nâng cấp."
	if int(inventory.get("tinh_thach", 0)) < int(info["crystal"]):
		return "Không đủ tinh thạch."
	if coins < int(info["coins"]):
		return "Không đủ xu."
	inventory["da_nang_cap"] = int(inventory["da_nang_cap"]) - int(info["stone"])
	if int(inventory["da_nang_cap"]) <= 0:
		inventory.erase("da_nang_cap")
	if int(info["crystal"]) > 0:
		inventory["tinh_thach"] = int(inventory["tinh_thach"]) - int(info["crystal"])
		if int(inventory["tinh_thach"]) <= 0:
			inventory.erase("tinh_thach")
	coins -= int(info["coins"])
	if randi_range(1, 100) <= int(info["chance"]):
		equipment_levels[slot] = int(equipment_levels.get(slot, 0)) + 1
		_refresh_equipment_stats()
		inventory_changed.emit()
		stats_changed.emit()
		return "Nâng cấp thành công! Trang bị đạt +%d." % int(equipment_levels[slot])
	inventory_changed.emit()
	stats_changed.emit()
	return "Nâng cấp thất bại. Trang bị giữ nguyên cấp, nguyên liệu và xu đã tiêu hao."

func get_inventory_entries() -> Array:
	var entries: Array = []
	for item_id in inventory.keys():
		if int(inventory[item_id]) > 0 and ITEM_DB.has(item_id):
			entries.append({"id": String(item_id), "count": int(inventory[item_id]), "data": ITEM_DB[item_id]})
	entries.sort_custom(func(a, b): return String(a["data"]["name"]) < String(b["data"]["name"]))
	return entries

func get_equipment_summary() -> String:
	var lines: Array[String] = []
	for slot in EQUIPMENT_SLOTS:
		var item_id := String(equipment.get(slot, ""))
		var item_name := String(ITEM_DB[item_id]["name"]) if item_id != "" else "Trống"
		var level_text := " +%d" % int(equipment_levels.get(slot, 0)) if item_id != "" else ""
		lines.append("%s: %s%s" % [SLOT_NAMES[slot], item_name, level_text])
	return "\n".join(lines)

func inventory_summary() -> String:
	return "Xu: %d | %d loại vật phẩm | %s" % [coins, inventory.size(), equipped_weapon]

func take_damage(amount: int) -> void:
	if invulnerable_timer > 0.0:
		return
	var actual_damage := maxi(1, amount - defense - equipment_defense)
	hp = maxi(0, hp - actual_damage)
	invulnerable_timer = 0.8
	stats_changed.emit()
	if hp <= 0:
		hp = max_hp
		ki = max_ki
		global_position = Vector2(190, 565)
		stats_changed.emit()

func gain_exp(amount: int) -> void:
	exp_points += amount
	var needed := level * 100
	while exp_points >= needed:
		exp_points -= needed
		level += 1
		strength += 2
		defense += 1
		potential += 5
		hp = max_hp
		ki = max_ki
		_refresh_equipment_stats()
		needed = level * 100
	stats_changed.emit()

func spend_potential(stat_name: String, points: int) -> bool:
	if points <= 0 or potential < points:
		return false
	potential -= points
	match stat_name:
		"hp":
			potential_hp_bonus += points * 5
			hp = mini(max_hp + points * 5, hp + points * 5)
		"ki":
			potential_ki_bonus += points * 5
			ki = mini(max_ki + points * 5, ki + points * 5)
		"strength":
			strength += points
		"defense":
			defense += points
		_:
			potential += points
			return false
	_refresh_equipment_stats()
	stats_changed.emit()
	return true
