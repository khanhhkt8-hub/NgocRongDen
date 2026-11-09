extends Node2D

var status_label: Label
var hint_label: Label
var zone_label: Label
var quest_label: Label
var message_label: Label
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
    var player = get_node_or_null("Player")
    if player:
        player.stats_changed.connect(_on_stats_changed)
        _on_stats_changed()

func _build_environment() -> void:
    var sky := Polygon2D.new()
    sky.name = "Sky"
    sky.polygon = PackedVector2Array(Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 660), Vector2(0, 660))
    sky.color = Color(0.07, 0.12, 0.22, 1)
    add_child(sky)
    move_child(sky, 0)
    var ground_visual := Polygon2D.new()
    ground_visual.name = "GroundVisual"
    ground_visual.polygon = PackedVector2Array(Vector2(-160, 0), Vector2(1440, 0), Vector2(1440, 90), Vector2(-160, 90))
    ground_visual.position = Vector2(0, 660)
    ground_visual.color = Color(0.18, 0.29, 0.25, 1)
    add_child(ground_visual)
    var sun := Polygon2D.new()
    sun.polygon = _circle_points(42, 32)
    sun.position = Vector2(1060, 135)
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
    hint_label = Label.new()
    hint_label.position = Vector2(24, 670)
    hint_label.text = "A/D: Di chuyen    SPACE: Nhay    J: Danh    K: Chuong KI    E: Tuong tac"
    if OS.has_feature("mobile"):
        hint_label.text = "Dung nut cam ung de di chuyen va chien dau. Den gan NPC de tuong tac."
    hint_label.add_theme_font_size_override("font_size", 15)
    hint_label.add_theme_color_override("font_color", Color(0.75, 0.88, 1))
    layer.add_child(hint_label)
    var title := Label.new()
    title.position = Vector2(950, 24)
    title.text = "NGOC RONG DEN"
    title.add_theme_font_size_override("font_size", 25)
    title.add_theme_color_override("font_color", Color(0.35, 0.88, 1))
    layer.add_child(title)

func _on_stats_changed() -> void:
    var player = get_node_or_null("Player")
    if not player or not is_instance_valid(status_label):
        return
    status_label.text = "HP %d/%d    KI %d/%d\nCap %d    Suc manh %d    Tan cong %d    Giap %d\nTiem nang: %d    EXP: %d/%d" % [
        player.hp, player.max_hp, player.ki, player.max_ki,
        player.level, player.power, player.strength, player.defense,
        player.potential, player.exp_points, player.level * 100
    ]

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
