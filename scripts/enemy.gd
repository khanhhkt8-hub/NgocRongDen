extends CharacterBody2D

signal defeated

const LOOT_DROP = preload("res://scenes/LootDrop.tscn")
@export var move_speed: float = 105.0
@export var max_hp: int = 40
@export var contact_damage: int = 10
@export var exp_reward: int = 25
@export var enemy_title: String = "Quai thu"
var hp: int = 40
var attack_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
    hp = max_hp
    add_to_group("enemies")

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
        defeated.emit()
        var players := get_tree().get_nodes_in_group("player")
        if players.size() > 0:
            players[0].gain_exp(exp_reward)
        _drop_loot()
        hp = max_hp
        global_position = Vector2(randf_range(650.0, 1100.0), 565.0)

func _drop_loot() -> void:
    if randf() > 0.72:
        return
    var drop = LOOT_DROP.instantiate()
    var roll := randi_range(0, 99)
    if roll < 48:
        drop.item_id = "dong_xu"
        drop.display_name = "Dong xu"
        drop.amount = randi_range(3, 12)
    elif roll < 78:
        drop.item_id = "tinh_thach"
        drop.display_name = "Tinh thach"
        drop.amount = 1
    elif roll < 94:
        drop.item_id = "da_nang_cap"
        drop.display_name = "Da nang cap"
        drop.amount = 1
    else:
        drop.item_id = "kiem_tan_thu"
        drop.display_name = "Kiem tan thu"
        drop.amount = 1
    drop.global_position = global_position
    get_tree().current_scene.add_child(drop)
