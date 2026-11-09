extends CharacterBody2D

signal stats_changed
signal inventory_changed

const ENERGY_BALL = preload("res://scenes/EnergyBall.tscn")
@export var move_speed: float = 300.0
@export var jump_velocity: float = -560.0
@export var attack_cooldown: float = 0.35
@export var melee_cooldown: float = 0.45

var max_hp: int = 120
var hp: int = 120
var max_ki: int = 100
var ki: int = 100
var strength: int = 12
var defense: int = 3
var potential: int = 0
var power: int = 1000
var exp_points: int = 0
var level: int = 1
var coins: int = 0
var inventory: Dictionary = {}
var equipped_weapon: String = "Chua co"
var weapon_bonus: int = 0
var facing: int = 1
var attack_timer: float = 0.0
var melee_timer: float = 0.0
var ki_regen_timer: float = 0.0
var invulnerable_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
    add_to_group("player")
    stats_changed.emit()
    inventory_changed.emit()

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
    melee_timer = maxf(0.0, melee_timer - delta)
    invulnerable_timer = maxf(0.0, invulnerable_timer - delta)
    ki_regen_timer += delta
    if ki_regen_timer >= 1.0:
        ki_regen_timer = 0.0
        ki = mini(max_ki, ki + 2)
        stats_changed.emit()
    if Input.is_action_just_pressed("attack"):
        melee_attack()
    if Input.is_action_just_pressed("ki_blast"):
        fire_energy()
    move_and_slide()

func melee_attack() -> void:
    if melee_timer > 0.0:
        return
    melee_timer = melee_cooldown
    for enemy in get_tree().get_nodes_in_group("enemies"):
        var offset: Vector2 = enemy.global_position - global_position
        if absf(offset.x) <= 78.0 and absf(offset.y) <= 72.0 and signf(offset.x) == float(facing):
            enemy.take_hit(strength + weapon_bonus + level * 2)

func fire_energy() -> void:
    if attack_timer > 0.0 or ki < 8:
        return
    attack_timer = attack_cooldown
    ki -= 8
    stats_changed.emit()
    var shot = ENERGY_BALL.instantiate()
    shot.direction = facing
    shot.damage = (strength + weapon_bonus) * 2 + level * 3
    shot.global_position = global_position + Vector2(34.0 * facing, -12.0)
    get_tree().current_scene.add_child(shot)

func collect_item(item_id: String, amount: int, display_name: String) -> void:
    match item_id:
        "dong_xu":
            coins += amount
        "kiem_tan_thu":
            inventory[item_id] = int(inventory.get(item_id, 0)) + amount
            equip_weapon("Kiem tan thu", 4)
        _:
            inventory[item_id] = int(inventory.get(item_id, 0)) + amount
    inventory_changed.emit()
    stats_changed.emit()

func equip_weapon(weapon_name: String, bonus: int) -> void:
    if bonus > weapon_bonus:
        equipped_weapon = weapon_name
        weapon_bonus = bonus
        power += bonus * 50
        stats_changed.emit()
        inventory_changed.emit()

func inventory_summary() -> String:
    return "Xu: %d | Tui do: %d loai | Vu khi: %s (+%d)" % [coins, inventory.size(), equipped_weapon, weapon_bonus]

func take_damage(amount: int) -> void:
    if invulnerable_timer > 0.0:
        return
    var actual_damage := maxi(1, amount - defense)
    hp = maxi(0, hp - actual_damage)
    invulnerable_timer = 0.8
    stats_changed.emit()
    if hp <= 0:
        hp = max_hp
        ki = max_ki
        global_position = Vector2(190, 565)
        stats_changed.emit()

func gain_exp(amount: int) -> void:
    exp_points += amount
    var needed := level * 100
    while exp_points >= needed:
        exp_points -= needed
        level += 1
        max_hp += 12
        max_ki += 8
        strength += 2
        defense += 1
        potential += 5
        power += 250
        hp = max_hp
        ki = max_ki
        needed = level * 100
    stats_changed.emit()

func spend_potential(stat_name: String, points: int) -> bool:
    if points <= 0 or potential < points:
        return false
    potential -= points
    match stat_name:
        "hp":
            max_hp += points * 5
            hp = mini(max_hp, hp + points * 5)
        "ki":
            max_ki += points * 5
            ki = mini(max_ki, ki + points * 5)
        "strength":
            strength += points
        "defense":
            defense += points
        _:
            potential += points
            return false
    power += points * 50
    stats_changed.emit()
    return true
