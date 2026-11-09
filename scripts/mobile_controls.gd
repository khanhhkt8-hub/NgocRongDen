extends Node

var layer: CanvasLayer

func _ready() -> void:
    if not OS.has_feature("mobile"):
        return
    layer = CanvasLayer.new()
    layer.name = "MobileControlsLayer"
    add_child(layer)
    _add_hold_button("◀", Vector2(34, -118), Vector2(112, 88), "move_left")
    _add_hold_button("▶", Vector2(158, -118), Vector2(112, 88), "move_right")
    _add_tap_button("NHẢY", Vector2(-372, -118), Vector2(108, 88), "jump")
    _add_tap_button("ĐÁNH", Vector2(-252, -118), Vector2(108, 88), "attack")
    _add_tap_button("CHƯỞNG", Vector2(-132, -118), Vector2(120, 88), "ki_blast")
    _add_tap_button("NÓI / NHẬN Q", Vector2(-132, -218), Vector2(120, 78), "interact")

func _add_hold_button(caption: String, offset: Vector2, button_size: Vector2, action: String) -> void:
    var button := _make_button(caption, button_size)
    button.anchor_left = 0.0
    button.anchor_right = 0.0
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0
    button.offset_left = offset.x
    button.offset_right = offset.x + button_size.x
    button.offset_top = offset.y
    button.offset_bottom = offset.y + button_size.y
    layer.add_child(button)
    button.button_down.connect(func(): Input.action_press(action))
    button.button_up.connect(func(): Input.action_release(action))
    button.tree_exiting.connect(func(): Input.action_release(action))

func _add_tap_button(caption: String, offset: Vector2, button_size: Vector2, action: String) -> void:
    var button := _make_button(caption, button_size)
    button.anchor_left = 1.0
    button.anchor_right = 1.0
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0
    button.offset_left = offset.x
    button.offset_right = offset.x + button_size.x
    button.offset_top = offset.y
    button.offset_bottom = offset.y + button_size.y
    layer.add_child(button)
    button.button_down.connect(func(): Input.action_press(action))
    button.button_up.connect(func(): Input.action_release(action))
    button.tree_exiting.connect(func(): Input.action_release(action))

func _make_button(caption: String, button_size: Vector2) -> Button:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = button_size
    button.add_theme_font_size_override("font_size", 21)
    button.add_theme_color_override("font_color", Color.WHITE)
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    button.add_theme_color_override("font_pressed_color", Color(0.6, 0.9, 1.0))
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.04, 0.12, 0.22, 0.72)
    normal.border_color = Color(0.35, 0.78, 1.0, 0.9)
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(18)
    button.add_theme_stylebox_override("normal", normal)
    var pressed := normal.duplicate()
    pressed.bg_color = Color(0.12, 0.38, 0.55, 0.92)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("hover", normal)
    button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    return button
