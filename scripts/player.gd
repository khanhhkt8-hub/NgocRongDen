extends CharacterBody2D

signal stats_changed(hp: int, max_hp: int, exp_points: int, level: int)

const ENERGY_BALL = preload("res://scenes/EnergyBall.tscn")
@export var move_speed: float = 300.0
@export var jump_velocity: float = -560.0
@export var max_hp: int = 100
@export var attack_cooldown: float = 0.35

var hp: int = 100
var exp_points: int = 0
var level: int = 1
var facing: int = 1
var attack_timer: float = 0.0
var invulnerable_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
    hp = max_hp
    add_to_group("player")
    stats_changed.emit(hp, max_hp, exp_points, level)

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
    invulnerable_timer = maxf(0.0, invulnerable_timer - delta)
    if Input.is_action_just_pressed("attack"):
        fire_energy()
    move_and_slide()

func fire_energy() -> void:
    if attack_timer > 0.0:
        return
    attack_timer = attack_cooldown
    var shot = ENERGY_BALL.instantiate()
    shot.direction = facing
    shot.global_position = global_position + Vector2(34.0 * facing, -12.0)
    get_tree().current_scene.add_child(shot)

func take_damage(amount: int) -> void:
    if invulnerable_timer > 0.0:
        return
    hp = maxi(0, hp - amount)
    invulnerable_timer = 0.8
    stats_changed.emit(hp, max_hp, exp_points, level)
    if hp <= 0:
        hp = max_hp
        global_position = Vector2(190, 565)
        stats_changed.emit(hp, max_hp, exp_points, level)

func gain_exp(amount: int) -> void:
    exp_points += amount
    var needed := level * 100
    while exp_points >= needed:
        exp_points -= needed
        level += 1
        max_hp += 10
        hp = max_hp
        needed = level * 100
    stats_changed.emit(hp, max_hp, exp_points, level)
