extends Node2D

# Procedural placeholder fighter animation. This keeps the prototype readable
# until original sprite sheets are integrated.
var phase := 0.0
var hit_flash := 0.0

func _process(delta: float) -> void:
	var fighter := get_parent()
	if not is_instance_valid(fighter):
		return
	scale.x = -1.0 if fighter.facing < 0 else 1.0
	phase += delta * (8.0 if absf(fighter.velocity.x) > 12.0 and fighter.is_on_floor() else 2.2)
	hit_flash = maxf(0.0, hit_flash - delta)
	queue_redraw()

func _draw() -> void:
	var fighter := get_parent()
	if not is_instance_valid(fighter):
		return
	var moving := absf(fighter.velocity.x) > 12.0 and fighter.is_on_floor()
	var airborne := not fighter.is_on_floor()
	var attacking := fighter.melee_timer > 0.25
	var casting := fighter.attack_timer > 0.15
	var step := sin(phase) * (11.0 if moving else 1.5)
	var bob := absf(sin(phase)) * 3.0 if moving else 0.0
	var skin := Color("#f2bd91")
	var hair := Color("#171c2b")
	var gi := Color("#18a7d2")
	var gi_shadow := Color("#08749f")
	var trim := Color("#f6e7c7")
	var belt := Color("#e9b83e")
	var dark := Color("#20283b")
	var boot := Color("#e8e9ed")
	if fighter.invulnerable_timer > 0.0 and int(fighter.invulnerable_timer * 18.0) % 2 == 0:
		gi = Color("#ffffff")
		skin = Color("#ffffff")
	draw_circle(Vector2(0, 1), 24.0, Color(0.0, 0.0, 0.0, 0.22))
	# Legs and boots
	var left_leg := Vector2(-8.0, -20.0 + bob)
	var right_leg := Vector2(8.0, -20.0 + bob)
	if airborne:
		left_leg.y += 4.0
		right_leg.y -= 3.0
	elif moving:
		left_leg.x -= step * 0.55
		right_leg.x += step * 0.55
		left_leg.y += absf(step) * 0.16
		right_leg.y += absf(step) * 0.16
	_line(Vector2(-5, -31 + bob), left_leg, dark, 9.0)
	_line(left_leg, left_leg + Vector2(-2, 17), gi_shadow, 10.0)
	_line(Vector2(5, -31 + bob), right_leg, dark, 9.0)
	_line(right_leg, right_leg + Vector2(2, 17), gi, 10.0)
	draw_rect(Rect2(left_leg.x - 7, left_leg.y + 11, 15, 7), boot, true)
	draw_rect(Rect2(right_leg.x - 7, right_leg.y + 11, 15, 7), boot, true)
	# Torso, gi panels, belt
	draw_colored_polygon(PackedVector2Array([Vector2(-14, -57 + bob), Vector2(13, -57 + bob), Vector2(17, -29 + bob), Vector2(9, -20 + bob), Vector2(-10, -20 + bob), Vector2(-17, -29 + bob)]), gi)
	draw_colored_polygon(PackedVector2Array([Vector2(0, -55 + bob), Vector2(13, -57 + bob), Vector2(17, -29 + bob), Vector2(9, -20 + bob), Vector2(1, -23 + bob)]), gi_shadow)
	_line(Vector2(-9, -53 + bob), Vector2(0, -30 + bob), trim, 2.5)
	draw_rect(Rect2(-12, -30 + bob, 24, 5), belt, true)
	draw_circle(Vector2(0, -27 + bob), 3.0, Color("#fff1b5"))
	# Arms; the attack pose extends toward the facing direction.
	var shoulder := Vector2(13.0, -51 + bob)
	var hand := Vector2(25.0, -37 + bob)
	if attacking:
		hand = Vector2(39.0, -49 + bob)
	elif casting:
		hand = Vector2(30.0, -62 + bob)
	elif moving:
		hand += Vector2(-step * 0.45, step * 0.12)
	_line(Vector2(-13, -50 + bob), Vector2(-22, -37 + bob) + Vector2(step * 0.3, 0), gi_shadow, 8.0)
	draw_circle(Vector2(-22, -37 + bob) + Vector2(step * 0.3, 0), 5.0, skin)
	_line(shoulder, hand, gi, 9.0)
	draw_circle(hand, 5.2, skin)
	# Neck and face
	draw_rect(Rect2(-5, -66 + bob, 10, 12), skin, true)
	draw_circle(Vector2(0, -76 + bob), 13.0, skin)
	draw_colored_polygon(PackedVector2Array([Vector2(-13, -78 + bob), Vector2(-12, -91 + bob), Vector2(-4, -99 + bob), Vector2(2, -92 + bob), Vector2(7, -98 + bob), Vector2(13, -88 + bob), Vector2(12, -77 + bob), Vector2(5, -83 + bob), Vector2(0, -80 + bob), Vector2(-6, -83 + bob)]), hair)
	draw_circle(Vector2(4, -76 + bob), 1.5, dark)
	draw_line(Vector2(7, -70 + bob), Vector2(11, -70 + bob), Color("#9d4f48"), 1.5)
	# Wrist wrap and small energy aura while charging.
	draw_line(hand + Vector2(-3, -2), hand + Vector2(3, 2), trim, 2.0)
	if casting:
		draw_arc(hand + Vector2(8, -3), 15.0 + sin(phase * 2.0) * 2.0, 0.0, TAU, 32, Color(0.25, 0.85, 1.0, 0.8), 3.0, true)

func _line(a: Vector2, b: Vector2, color: Color, width: float) -> void:
	draw_line(a, b, color, width, true)
