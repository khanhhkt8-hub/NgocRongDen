extends Area2D

@export var item_id: String = "dong_xu"
@export var display_name: String = "Dong xu"
@export var amount: int = 1
var lifetime := 25.0
var bob_time := 0.0
var base_y := 0.0

func _ready() -> void:
    add_to_group("loot")
    collision_layer = 0
    collision_mask = 1
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 24.0
    shape.shape = circle
    add_child(shape)
    var icon := Polygon2D.new()
    icon.name = "Icon"
    icon.polygon = PackedVector2Array([Vector2(0, -15), Vector2(13, 0), Vector2(0, 15), Vector2(-13, 0)])
    icon.color = _item_color()
    add_child(icon)
    body_entered.connect(_on_body_entered)
    base_y = position.y

func _process(delta: float) -> void:
    lifetime -= delta
    bob_time += delta
    position.y = base_y + sin(bob_time * 3.0) * 5.0
    if lifetime <= 0.0:
        queue_free()

func _item_color() -> Color:
    match item_id:
        "dong_xu":
            return Color(1.0, 0.78, 0.20)
        "tinh_thach":
            return Color(0.35, 0.85, 1.0)
        "da_nang_cap":
            return Color(0.75, 0.55, 1.0)
        "kiem_tan_thu":
            return Color(0.55, 1.0, 0.55)
        _:
            return Color.WHITE

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and body.has_method("collect_item"):
        body.collect_item(item_id, amount, display_name)
        queue_free()
