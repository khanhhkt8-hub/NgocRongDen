extends Node2D

var status_label: Label
var hint_label: Label
const MOBILE_CONTROLS = preload("res://scripts/mobile_controls.gd")

func _ready() -> void:
    _build_environment()
    _build_hud()
    var mobile_controls = MOBILE_CONTROLS.new()
    mobile_controls.name = "MobileControls"
    add_child(mobile_controls)
    var player = get_node_or_null("Player")
    if player:
        player.stats_changed.connect(_on_stats_changed)
        _on_stats_changed(player.hp, player.max_hp, player.exp_points, player.level)

func _build_environment() -> void:
    var sky := Polygon2D.new()
    sky.polygon = PackedVector2Array(Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 660), Vector2(0, 660))
    sky.color = Color(0.07, 0.12, 0.22, 1)
    add_child(sky)
    move_child(sky, 0)

    var ground_visual := Polygon2D.new()
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
    status_label.add_theme_font_size_override("font_size", 24)
    status_label.add_theme_color_override("font_color", Color(1, 1, 1))
    layer.add_child(status_label)

    hint_label = Label.new()
    hint_label.position = Vector2(24, 62)
    hint_label.text = "A/D: Di chuyển    SPACE: Nhảy    J: Bắn năng lượng"
    if OS.has_feature("mobile"):
        hint_label.text = "Dùng các nút cảm ứng ở hai góc màn hình để điều khiển"
    hint_label.add_theme_font_size_override("font_size", 18)
    hint_label.add_theme_color_override("font_color", Color(0.75, 0.88, 1))
    layer.add_child(hint_label)

    var title := Label.new()
    title.position = Vector2(950, 24)
    title.text = "NGỌC RỒNG ĐEN"
    title.add_theme_font_size_override("font_size", 25)
    title.add_theme_color_override("font_color", Color(0.35, 0.88, 1))
    layer.add_child(title)

func _on_stats_changed(hp: int, max_hp: int, exp_points: int, level: int) -> void:
    if is_instance_valid(status_label):
        status_label.text = "HP: %d/%d     Cấp: %d     EXP: %d/%d" % [hp, max_hp, level, exp_points, level * 100]
