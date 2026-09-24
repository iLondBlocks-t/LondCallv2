class_name EchofangEnemy
extends Node2D
## One compact enemy contract powers eight archetypes and the three-phase Choir boss.

signal defeated(enemy: Node2D, motes: int)
signal telegraph_started(enemy: Node2D, duration: float)

@export var enemy_type := "rootling"
@export var max_health := 3
@export var motes_reward := 3
@export var move_speed := 45.0
@export var contact_damage := 1
@export var is_boss := false

var health := 3
var home_position := Vector2.ZERO
var target: Node2D
var action_time := 0.0
var attack_cooldown := 0.8
var telegraph_left := 0.0
var attack_left := 0.0
var hurt_flash := 0.0
var defeated_state := false
var phase := 1
var orbit_angle := 0.0
var fx_time := 0.0

func _state():
	return get_tree().root.get_node_or_null("GameState")

func setup(kind: String, position_in_world: Vector2, boss := false) -> void:
	enemy_type = kind
	global_position = position_in_world
	home_position = global_position
	is_boss = boss
	if is_boss:
		max_health = 24
		motes_reward = 60
		move_speed = 65.0
		contact_damage = 2
	else:
		match enemy_type:
			"rootling":
				max_health = 3; motes_reward = 3; move_speed = 42.0
			"sporeback":
				max_health = 5; motes_reward = 6; move_speed = 28.0
			"lantern_mite":
				max_health = 2; motes_reward = 4; move_speed = 70.0
			"glasswing":
				max_health = 3; motes_reward = 5; move_speed = 92.0
			"gallery_sentry":
				max_health = 4; motes_reward = 7; move_speed = 15.0
			"tide_crawler":
				max_health = 4; motes_reward = 5; move_speed = 110.0
			"archive_wisp":
				max_health = 3; motes_reward = 8; move_speed = 44.0
			"choir_knight":
				max_health = 8; motes_reward = 12; move_speed = 53.0
	health = max_health
	add_to_group("enemies")
	queue_redraw()

func _ready() -> void:
	if health <= 0:
		health = max_health
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	if defeated_state:
		return
	fx_time += delta
	action_time += delta
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	telegraph_left = maxf(0.0, telegraph_left - delta)
	hurt_flash = maxf(0.0, hurt_flash - delta)
	target = get_tree().get_first_node_in_group("player") as Node2D
	if target == null or target.is_dead:
		queue_redraw()
		return
	var distance := global_position.distance_to(target.global_position)
	if telegraph_left <= 0.0 and attack_cooldown <= 0.0 and distance < (240.0 if is_boss else 150.0):
		_begin_attack()
	if telegraph_left <= 0.0:
		_perform_pattern(delta, distance)
	if distance < (52.0 if is_boss else 32.0) and attack_left <= 0.0:
		attack_left = 0.9
		target.take_damage(contact_damage, target.global_position - global_position)
	queue_redraw()

func _begin_attack() -> void:
	telegraph_left = 0.4
	attack_cooldown = 1.15 if not is_boss else 1.55
	telegraph_started.emit(self, telegraph_left)

func _perform_pattern(delta: float, distance: float) -> void:
	if target == null:
		return
	var to_target := (target.global_position - global_position).normalized()
	if is_boss:
		phase = 1 + int((max_health - health) / 8)
		if phase == 1:
			global_position.x += sin(action_time * 1.7) * delta * 30.0
		elif phase == 2:
			global_position.x += to_target.x * move_speed * delta * 0.45
			if fmod(action_time, 2.3) < 0.03:
				_emit_boss_shard_ring()
		else:
			orbit_angle += delta * 1.4
			global_position += Vector2(cos(orbit_angle), sin(orbit_angle) * 0.35) * delta * 42.0
		return
	match enemy_type:
		"rootling", "choir_knight":
			global_position.x += signf(to_target.x) * move_speed * delta
		"sporeback":
			global_position.x += sin(action_time * 0.8) * move_speed * delta * 0.35
		"lantern_mite":
			global_position += Vector2(to_target.x, sin(action_time * 5.0) * 0.55) * move_speed * delta
		"glasswing":
			global_position += to_target * move_speed * delta * (1.7 if fmod(action_time, 2.0) < 0.4 else 0.2)
		"gallery_sentry":
			if distance < 210.0:
				global_position.x -= to_target.x * move_speed * delta
		"tide_crawler":
			global_position.x += to_target.x * move_speed * delta
		"archive_wisp":
			global_position += Vector2(cos(action_time), sin(action_time * 1.7)) * move_speed * delta

func _emit_boss_shard_ring() -> void:
	# The world listens to this group event through the same contact/telegraph contract.
	for index in 8:
		var shard := preload("res://scripts/combat/shard.gd").new()
		shard.global_position = global_position
		shard.direction = Vector2.from_angle(TAU * float(index) / 8.0)
		get_parent().add_child(shard)

func receive_hit(amount: int, source: Vector2 = Vector2.ZERO) -> void:
	if defeated_state:
		return
	health -= maxi(1, amount)
	hurt_flash = 0.12
	if source != Vector2.ZERO:
		global_position += (global_position - source).normalized() * 4.0
	if health <= 0:
		defeated_state = true
		_state().add_motes(motes_reward)
		_state().add_umbra(1)
		defeated.emit(self, motes_reward)
		queue_free()

func _draw() -> void:
	var tint := Color(0.66, 0.30, 0.49, 1)
	match enemy_type:
		"rootling": tint = Color(0.30, 0.72, 0.60, 1)
		"sporeback": tint = Color(0.86, 0.58, 0.31, 1)
		"lantern_mite": tint = Color(0.98, 0.77, 0.29, 1)
		"glasswing": tint = Color(0.42, 0.83, 0.92, 1)
		"gallery_sentry": tint = Color(0.57, 0.36, 0.92, 1)
		"tide_crawler": tint = Color(0.28, 0.55, 0.86, 1)
		"archive_wisp": tint = Color(0.76, 0.48, 0.94, 1)
		"choir_knight": tint = Color(0.72, 0.72, 0.80, 1)
		"boss": tint = Color(0.94, 0.45, 0.74, 1)
	if is_boss:
		var ring_color := Color(0.72, 0.38, 1.0, 0.16 if telegraph_left <= 0.0 else 0.55)
		draw_circle(Vector2.ZERO, 92.0 + sin(fx_time * 2.0) * 4.0, ring_color)
		draw_arc(Vector2.ZERO, 80.0, -PI * 0.75, PI * 0.75, 24, Color(0.95, 0.66, 0.31, 0.7), 3.0)
		draw_circle(Vector2.ZERO, 43.0, Color(0.09, 0.05, 0.17, 1))
		draw_circle(Vector2(0, -5), 33.0, tint)
		draw_line(Vector2(-25, -18), Vector2(-10, -30), Color(0.98, 0.85, 0.94, 1), 5.0)
		draw_line(Vector2(25, -18), Vector2(10, -30), Color(0.98, 0.85, 0.94, 1), 5.0)
	else:
		draw_circle(Vector2(0, 5), 17.0, Color(0.05, 0.07, 0.13, 1))
		draw_colored_polygon(PackedVector2Array([Vector2(-16, 10), Vector2(-22, 24), Vector2(0, 17), Vector2(22, 24), Vector2(16, 10)]), tint)
		draw_circle(Vector2(0, -5), 12.0, tint)
		draw_circle(Vector2(-5, -6), 2.0, Color(0.96, 0.98, 1, 1))
		draw_circle(Vector2(5, -6), 2.0, Color(0.96, 0.98, 1, 1))
	if telegraph_left > 0.0:
		var progress := 1.0 - telegraph_left / 0.4
		draw_arc(Vector2.ZERO, 28.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 20, Color(1.0, 0.38, 0.48, 0.95), 4.0)
		# A 0.4s telegraph is intentionally visible before attack.
