extends Node2D

signal world_status_changed(zone_name: String, quest_text: String, message: String)
signal zone_changed(zone_index: int)

const ZONES := [
    {"name": "THUNG LUNG BINH MINH", "sky": Color(0.10, 0.19, 0.30), "ground": Color(0.20, 0.36, 0.27), "enemy_hp": 40, "exp": 25, "enemy_speed": 95.0, "enemy_damage": 8, "enemy_color": Color(0.82, 0.24, 0.32), "enemy_title": "Tieu quai"},
    {"name": "RUNG CO MAY", "sky": Color(0.08, 0.24, 0.22), "ground": Color(0.24, 0.34, 0.20), "enemy_hp": 65, "exp": 40, "enemy_speed": 115.0, "enemy_damage": 13, "enemy_color": Color(0.28, 0.68, 0.35), "enemy_title": "Da thu"},
    {"name": "HOANG MAC DO", "sky": Color(0.30, 0.17, 0.12), "ground": Color(0.39, 0.27, 0.16), "enemy_hp": 90, "exp": 60, "enemy_speed": 130.0, "enemy_damage": 18, "enemy_color": Color(0.85, 0.52, 0.20), "enemy_title": "Sa mac chien binh"}
]
var zone_index := 0
var quest_active := false
var quest_complete := false
var quest_kills := 0
var portal_locked := false
var player: Node2D
var npc_position := Vector2(365, 565)
var portal_position := Vector2(2700, 565)
var status_message := "Den gap Nguoi dan duong va nhan E de nhan nhiem vu."

func _ready() -> void:
    player = get_tree().get_first_node_in_group("player")
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy.has_signal("defeated"):
            enemy.defeated.connect(_on_enemy_defeated)
    queue_redraw()
    _emit_status()

func _process(_delta: float) -> void:
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player")
        return
    if Input.is_action_just_pressed("interact") and player.global_position.distance_to(npc_position) < 125.0:
        _interact_with_npc()
    if player.global_position.x >= 2700.0 and not portal_locked:
        _travel_to_next_zone()

func _draw() -> void:
    draw_circle(npc_position + Vector2(0, -42), 25, Color(0.30, 0.78, 0.95))
    draw_circle(npc_position + Vector2(0, -72), 14, Color(0.95, 0.78, 0.58))
    draw_rect(Rect2(portal_position + Vector2(-18, -112), Vector2(36, 112)), Color(0.35, 0.78, 1.0, 0.30), true)
    draw_arc(portal_position + Vector2(0, -56), 24, PI, TAU, 32, Color(0.50, 0.88, 1.0), 5.0)
    draw_string(ThemeDB.fallback_font, npc_position + Vector2(-85, -105), "NGUOI DAN DUONG", HORIZONTAL_ALIGNMENT_CENTER, 170, 15, Color.WHITE)
    draw_string(ThemeDB.fallback_font, portal_position + Vector2(-65, -125), "CONG DICH CHUYEN", HORIZONTAL_ALIGNMENT_CENTER, 130, 14, Color.WHITE)

func _interact_with_npc() -> void:
    if not quest_active and not quest_complete:
        quest_active = true
        quest_kills = 0
        status_message = "Nhiem vu: Tieu diet 3 quai vat trong khu vuc!"
    elif quest_active and quest_kills >= 3:
        quest_active = false
        quest_complete = true
        status_message = "Hoan thanh! Nhan 150 EXP va 5 diem tiem nang."
        if is_instance_valid(player):
            player.gain_exp(150)
            player.potential += 5
            player.stats_changed.emit()
    elif quest_active:
        status_message = "Hay danh bai them %d quai vat nua!" % (3 - quest_kills)
    else:
        status_message = "Cam on chien binh! Nhiem vu tiep theo se som mo."
    _emit_status()

func _on_enemy_defeated() -> void:
    if quest_active and not quest_complete:
        quest_kills = mini(3, quest_kills + 1)
        status_message = "Da ha guc quai: %d/3" % quest_kills
        _emit_status()

func _travel_to_next_zone() -> void:
    portal_locked = true
    zone_index = (zone_index + 1) % ZONES.size()
    if is_instance_valid(player):
        player.global_position = Vector2(120, 565)
        player.velocity = Vector2.ZERO
    for enemy in get_tree().get_nodes_in_group("enemies"):
        enemy.global_position = Vector2(randf_range(950.0, 2450.0), 565.0)
        var zone: Dictionary = ZONES[zone_index]
        enemy.max_hp = int(zone["enemy_hp"])
        enemy.hp = enemy.max_hp
        enemy.exp_reward = int(zone["exp"])
        enemy.move_speed = float(zone["enemy_speed"])
        enemy.contact_damage = int(zone["enemy_damage"])
        enemy.enemy_title = String(zone["enemy_title"])
        var body = enemy.get_node_or_null("Body")
        if body:
            body.color = zone["enemy_color"]
    status_message = "Ban da den: %s" % ZONES[zone_index]["name"]
    zone_changed.emit(zone_index)
    _emit_status()
    await get_tree().create_timer(1.0).timeout
    portal_locked = false

func get_zone_data() -> Dictionary:
    return ZONES[zone_index]

func _emit_status() -> void:
    var zone: Dictionary = ZONES[zone_index]
    var quest_text := "Nhiem vu: Chua nhan"
    if quest_active:
        quest_text = "Nhiem vu: Ha quai %d/3" % quest_kills
    elif quest_complete:
        quest_text = "Nhiem vu: Da hoan thanh"
    world_status_changed.emit(String(zone["name"]), quest_text, status_message)
