extends CharacterBody2D

@export var move_speed: float = 105.0
@export var max_hp: int = 40
@export var contact_damage: int = 10

var hp: int = 40
var attack_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
    hp = max_hp

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta
    var players := get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        var player = players[0]
        var distance: float = global_position.distance_to(player.global_position)
        if distance > 48.0:
            velocity.x = signf(player.global_position.x - global_position.x) * move_speed
        else:
            velocity.x = 0.0
            attack_timer -= delta
            if attack_timer <= 0.0:
                player.take_damage(contact_damage)
                attack_timer = 1.0
    move_and_slide()

func take_hit(damage: int) -> void:
    hp -= damage
    if hp <= 0:
        var players := get_tree().get_nodes_in_group("player")
        if players.size() > 0:
            players[0].gain_exp(25)
        hp = max_hp
        global_position = Vector2(randf_range(650.0, 1100.0), 565.0)
