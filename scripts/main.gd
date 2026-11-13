extends Node2D

var status_label: Label
var hint_label: Label
var zone_label: Label
var quest_label: Label
var message_label: Label
var inventory_label: Label
var inventory_panel: PanelContainer
var inventory_content: VBoxContainer
var inventory_message: Label
var upgrade_slot_select: OptionButton
var player_ref: Node
const MOBILE_CONTROLS = preload("res://scripts/mobile_controls.gd")
const WORLD_SYSTEM = preload("res://scripts/world_system.gd")

func _ready() -> void:
	_build_environment()
	_build_hud()
	var world = WORLD_SYSTEM.new()
	world.name = "WorldSystem"
	add_child(world)
	world.world_status_changed.connect(_on_world_status_changed)
	world.zone_changed.connect(_on_zone_changed)
	var mobile_controls = MOBILE_CONTROLS.new()
	mobile_controls.name = "MobileControls"
	add_child(mobile_controls)
	player_ref = get_node_or_null("Player")
	if player_ref:
		player_ref.stats_changed.connect(_on_stats_changed)
		player_ref.inventory_changed.connect(_on_inventory_changed)
		_on_stats_changed()
		_on_inventory_changed()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_toggle"):
		_toggle_inventory()
		get_viewport().set_input_as_handled()

func _build_environment() -> void:
	var sky := Polygon2D.new()
	sky.name = "Sky"
	sky.polygon = PackedVector2Array([Vector2(0, 0), Vector2(3200, 0), Vector2(3200, 660), Vector2(0, 660)])
	sky.color = Color(0.07, 0.12, 0.22, 1)
	add_child(sky)
	move_child(sky, 0)
	var ground_visual := Polygon2D.new()
	ground_visual.name = "GroundVisual"
	ground_visual.polygon = PackedVector2Array([Vector2(-160, 0), Vector2(3360, 0), Vector2(3360, 90), Vector2(-160, 90)])
	ground_visual.position = Vector2(0, 660)
	ground_visual.color = Color(0.18, 0.29, 0.25, 1)
	add_child(ground_visual)
	var sun := Polygon2D.new()
	sun.polygon = _circle_points(42, 32)
	sun.position = Vector2(2550, 135)
	sun.color = Color(1.0, 0.72, 0.32, 1)
	add_child(sun)

func _circle_points(radius: float, count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	status_label = Label.new()
	status_label.position = Vector2(24, 18)
	status_label.add_theme_font_size_override("font_size", 20)
	status_label.add_theme_color_override("font_color", Color.WHITE)
	layer.add_child(status_label)
	zone_label = Label.new()
	zone_label.position = Vector2(24, 142)
	zone_label.add_theme_font_size_override("font_size", 20)
	zone_label.add_theme_color_override("font_color", Color(0.60, 0.92, 1.0))
	layer.add_child(zone_label)
	quest_label = Label.new()
	quest_label.position = Vector2(24, 172)
	quest_label.add_theme_font_size_override("font_size", 18)
	quest_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.48))
	layer.add_child(quest_label)
	message_label = Label.new()
	message_label.position = Vector2(24, 204)
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
	layer.add_child(message_label)
	inventory_label = Label.new()
	inventory_label.position = Vector2(24, 238)
	inventory_label.add_theme_font_size_override("font_size", 16)
	inventory_label.add_theme_color_override("font_color", Color(0.70, 1.0, 0.76))
	layer.add_child(inventory_label)
	hint_label = Label.new()
	hint_label.position = Vector2(24, 670)
	hint_label.text = "A/D: Di chuyen    SPACE: Nhay    J: Danh    K: Chuong KI    E: Tuong tac    I: Tui do"
	if OS.has_feature("mobile"):
		hint_label.text = "Dung nut cam ung de di chuyen va chien dau. Nhan TUI DO de xem trang bi."
	hint_label.add_theme_font_size_override("font_size", 15)
	hint_label.add_theme_color_override("font_color", Color(0.75, 0.88, 1))
	layer.add_child(hint_label)
	var title := Label.new()
	title.position = Vector2(950, 24)
	title.text = "NGOC RONG DEN"
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color(0.35, 0.88, 1))
	layer.add_child(title)
	_build_inventory_panel(layer)

func _build_inventory_panel(layer: CanvasLayer) -> void:
	inventory_panel = PanelContainer.new()
	inventory_panel.position = Vector2(650, 55)
	inventory_panel.size = Vector2(590, 610)
	inventory_panel.custom_minimum_size = Vector2(590, 610)
	inventory_panel.visible = false
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.055, 0.10, 0.96)
	style.border_color = Color(0.35, 0.75, 1.0, 1)
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	inventory_panel.add_theme_stylebox_override("panel", style)
	layer.add_child(inventory_panel)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	inventory_panel.add_child(root)
	var header := HBoxContainer.new()
	root.add_child(header)
	var title := Label.new()
	title.text = "TÚI ĐỒ & TRANG BỊ"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 23)
	header.add_child(title)
	var close := Button.new()
	close.text = "ĐÓNG"
	close.pressed.connect(func(): inventory_panel.visible = false)
	header.add_child(close)
	var equipment_title := Label.new()
	equipment_title.text = "TRANG BỊ ĐANG MẶC"
	equipment_title.add_theme_color_override("font_color", Color(0.55, 0.88, 1))
	root.add_child(equipment_title)
	var equipment_label := Label.new()
	equipment_label.name = "EquipmentLabel"
	equipment_label.add_theme_font_size_override("font_size", 15)
	root.add_child(equipment_label)
	var upgrade_title := Label.new()
	upgrade_title.text = "CƯỜNG HÓA TRANG BỊ"
	upgrade_title.add_theme_color_override("font_color", Color(1.0, 0.72, 0.42))
	root.add_child(upgrade_title)
	var upgrade_row := HBoxContainer.new()
	root.add_child(upgrade_row)
	upgrade_slot_select = OptionButton.new()
	upgrade_slot_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for slot_name in ["Vũ khí", "Áo", "Quần", "Găng", "Giày", "Rada"]:
		upgrade_slot_select.add_item(slot_name)
	upgrade_row.add_child(upgrade_slot_select)
	var upgrade_button := Button.new()
	upgrade_button.text = "NÂNG CẤP"
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	upgrade_row.add_child(upgrade_button)
	var shop_title := Label.new()
	shop_title.text = "CỬA HÀNG — mua vật phẩm bằng xu"
	shop_title.add_theme_color_override("font_color", Color(0.55, 1.0, 0.70))
	root.add_child(shop_title)
	var shop_row := HBoxContainer.new()
	root.add_child(shop_row)
	for shop_item in [{"id": "binh_hp_nho", "label": "Đậu HP 30"}, {"id": "binh_ki_nho", "label": "Nước KI 30"}, {"id": "da_nang_cap", "label": "Đá 80"}, {"id": "tinh_thach", "label": "Thạch 180"}]:
		var buy_button := Button.new()
		buy_button.text = shop_item["label"]
		buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_button.pressed.connect(_on_buy_item_pressed.bind(String(shop_item["id"])))
		shop_row.add_child(buy_button)
	var item_title := Label.new()
	item_title.text = "VẬT PHẨM TRONG TÚI — chạm để trang bị / sử dụng"
	item_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.45))
	root.add_child(item_title)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 220)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)
	inventory_content = VBoxContainer.new()
	inventory_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inventory_content)
	inventory_message = Label.new()
	inventory_message.text = "Vật phẩm nguyên liệu sẽ được dùng trong hệ thống nâng cấp ở bước tiếp theo."
	inventory_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(inventory_message)
	_refresh_inventory_panel()

func _toggle_inventory() -> void:
	if inventory_panel:
		inventory_panel.visible = not inventory_panel.visible
		if inventory_panel.visible:
			_refresh_inventory_panel()

func _refresh_inventory_panel() -> void:
	if not inventory_content or not is_instance_valid(player_ref):
		return
	for child in inventory_content.get_children():
		child.queue_free()
	var equipment_label = inventory_panel.find_child("EquipmentLabel", true, false)
	if equipment_label:
		equipment_label.text = player_ref.get_equipment_summary()
	var entries: Array = player_ref.get_inventory_entries()
	if entries.is_empty():
		var empty := Label.new()
		empty.text = "Túi đồ đang trống. Hãy tiêu diệt quái để tìm vật phẩm."
		inventory_content.add_child(empty)
	for entry in entries:
		var item_data: Dictionary = entry["data"]
		var item_id := String(entry["id"])
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 54)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var item_button := Button.new()
		item_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_button.text = "%s  x%d\n%s" % [item_data["name"], entry["count"], item_data.get("description", "")]
		item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		item_button.add_theme_font_size_override("font_size", 15)
		item_button.pressed.connect(_on_inventory_item_pressed.bind(item_id))
		row.add_child(item_button)
		var sell_button := Button.new()
		sell_button.text = "BÁN 1"
		sell_button.custom_minimum_size = Vector2(76, 0)
		sell_button.pressed.connect(_on_sell_item_pressed.bind(item_id))
		row.add_child(sell_button)
		inventory_content.add_child(row)
	inventory_label.text = player_ref.inventory_summary()


func _on_buy_item_pressed(item_id: String) -> void:
	if not is_instance_valid(player_ref):
		return
	inventory_message.text = player_ref.buy_item(item_id, 1)
	_refresh_inventory_panel()

func _on_sell_item_pressed(item_id: String) -> void:
	if not is_instance_valid(player_ref):
		return
	inventory_message.text = player_ref.sell_item(item_id, 1)
	_refresh_inventory_panel()

func _on_upgrade_pressed() -> void:
	if not is_instance_valid(player_ref):
		return
	var slots := ["weapon", "body", "pants", "gloves", "boots", "head"]
	var slot: String = slots[upgrade_slot_select.selected]
	inventory_message.text = player_ref.upgrade_equipped(slot)
	_refresh_inventory_panel()

func _on_inventory_item_pressed(item_id: String) -> void:
	var result: String = player_ref.item_action(item_id)
	inventory_message.text = result
	_refresh_inventory_panel()

func _on_stats_changed() -> void:
	if not player_ref or not is_instance_valid(status_label):
		return
	status_label.text = "HP %d/%d    KI %d/%d\nCap %d    Suc manh %d    Tan cong %d    Giap %d\nTiem nang: %d    EXP: %d/%d" % [
		player_ref.hp, player_ref.max_hp, player_ref.ki, player_ref.max_ki,
		player_ref.level, player_ref.power, player_ref.strength + player_ref.weapon_bonus, player_ref.defense + player_ref.equipment_defense,
		player_ref.potential, player_ref.exp_points, player_ref.level * 100
	]

func _on_inventory_changed() -> void:
	if player_ref and is_instance_valid(inventory_label):
		inventory_label.text = player_ref.inventory_summary()
		if inventory_panel and inventory_panel.visible:
			_refresh_inventory_panel()

func _on_world_status_changed(zone_name: String, quest_text: String, message: String) -> void:
	if is_instance_valid(zone_label):
		zone_label.text = "Khu vuc: " + zone_name
		quest_label.text = quest_text
		message_label.text = message

func _on_zone_changed(_zone_index: int) -> void:
	var world = get_node_or_null("WorldSystem")
	if not world:
		return
	var zone: Dictionary = world.get_zone_data()
	var sky = get_node_or_null("Sky")
	var ground = get_node_or_null("GroundVisual")
	if sky:
		sky.color = zone["sky"]
	if ground:
		ground.color = zone["ground"]
