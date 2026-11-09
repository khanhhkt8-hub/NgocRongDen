extends Area2D

@export var speed: float = 650.0
@export var damage: int = 20
var direction: int = 1
var lifetime: float = 2.0

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    global_position.x += speed * float(direction) * delta
    lifetime -= delta
    if lifetime <= 0.0:
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        return
    if body.has_method("take_hit"):
        body.take_hit(damage)
    queue_free()
