extends CharacterBody2D
## Tunable, deterministic CharacterBody2D controller.
## All timing is measured in seconds inside _physics_process (60 Hz in project settings).

signal attack_landed(target: Node2D, pogo: bool)
signal attack_started(direction: Vector2, combo_step: int)
signal ability_used(id: StringName)
signal hurt_started
signal died
signal footsteps

@export_category("Feel")
@export_range(0.0, 0.3, 0.001) var coyote_time := 0.120
@export_range(0.0, 0.3, 0.001) var jump_buffer_time := 0.150
@export var run_speed := 345.0
@export var acceleration_time := 0.060
@export var deceleration_time := 0.040
@export var jump_velocity := -610.0
@export_range(0.1, 1.0, 0.01) var early_release_factor := 0.50
@export var gravity := 1550.0
@export var corner_correction := 8.0
@export var wall_slide_speed := 160.0
@export var wall_jump_speed := 475.0
@export var wall_jump_angle := 52.0

@export_category("Combat")
@export var attack_active_time := 0.105
@export var attack_recovery_time := 0.16
@export var combo_window := 0.28
@export var pogo_velocity := -735.0
@export var damage_invulnerability := 0.60

@export_category("Fang Dash")
@export var dash_speed := 980.0
@export var dash_duration := 0.150
@export var dash_cooldown := 0.650

var facing := 1.0
var coyote_left := 0.0
var jump_buffer_left := 0.0
var dash_left := 0.0
var dash_cooldown_left := 0.0
var invulnerable_left := 0.0
var attack_left := 0.0
var attack_recovery_left := 0.0
var combo_left := 0.0
var combo_step := 0
var wall_jump_lock_left := 0.0
var wall_cling := false
var was_on_floor := false
var is_dashing := false
var is_dead := false
var is_hurt := false
var hit_stop_left := 0.0
var current_action := &"idle"
var last_input := Vector2.RIGHT
var requested_virtual_actions: Dictionary = {}
var dash_direction := Vector2.RIGHT
var afterimages: Array[Dictionary] = []
var fx_time := 0.0

func _state():
	return get_tree().root.get_node_or_null("GameState")

func _ready() -> void:
	add_to_group("player")
	queue_redraw()

func _physics_process(delta: float) -> void:
	fx_time += delta
	if hit_stop_left > 0.0:
		hit_stop_left -= delta
		queue_redraw()
		return
	if is_dead:
		return
	coyote_left = maxf(0.0, coyote_left - delta)
	jump_buffer_left = maxf(0.0, jump_buffer_left - delta)
	dash_cooldown_left = maxf(0.0, dash_cooldown_left - delta)
	invulnerable_left = maxf(0.0, invulnerable_left - delta)
	attack_recovery_left = maxf(0.0, attack_recovery_left - delta)
	combo_left = maxf(0.0, combo_left - delta)
	wall_jump_lock_left = maxf(0.0, wall_jump_lock_left - delta)
	if combo_left <= 0.0 and attack_left <= 0.0:
		combo_step = 0
	if Input.is_action_just_pressed(&"jump") or _virtual_just_pressed(&"jump"):
		jump_buffer_left = jump_buffer_time
	if Input.is_action_just_pressed(&"attack") or _virtual_just_pressed(&"attack"):
		_start_attack()
	if Input.is_action_just_pressed(&"dash") or _virtual_just_pressed(&"dash"):
		_start_dash()
	if Input.is_action_just_pressed(&"ability_1") or _virtual_just_pressed(&"ability_1"):
		_use_ability(&"echo_needle")
	if Input.is_action_just_pressed(&"ability_2") or _virtual_just_pressed(&"ability_2"):
		_use_ability(&"umbral_pulse")
	if is_dashing:
		_process_dash(delta)
	if not is_dashing:
		_process_ground_movement(delta)
		_process_jump_and_walls(delta)
		_process_combat(delta)
	move_and_slide()
	_process_landing()
	queue_redraw()

func _process_ground_movement(delta: float) -> void:
	var axis := Input.get_axis(&"move_left", &"move_right")
	if absf(axis) < 0.01:
		axis = float(_virtual_axis())
	if absf(axis) > 0.05:
		facing = signf(axis)
		last_input = Vector2(axis, 0.0)
	var target := axis * run_speed
	var response := deceleration_time
	if absf(axis) > 0.05:
		response = acceleration_time
	var rate := run_speed / maxf(0.001, response)
	velocity.x = move_toward(velocity.x, target, rate * delta)
	if absf(velocity.x) > 8.0:
		current_action = &"run"
	elif is_on_floor():
		current_action = &"idle"
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_floor():
		coyote_left = coyote_time

func _process_jump_and_walls(_delta: float) -> void:
	var touching_wall := is_on_wall() and absf(velocity.x) > 4.0
	wall_cling = touching_wall and _state().has_ability(&"wall_cling") and not is_on_floor() and Input.get_axis(&"move_left", &"move_right") != 0.0
	if wall_cling:
		velocity.y = minf(velocity.y, wall_slide_speed)
		current_action = &"wall_cling"
	if jump_buffer_left > 0.0:
		if is_on_floor() or coyote_left > 0.0:
			_do_jump(false)
		elif wall_cling:
			_do_wall_jump()
		elif _state().has_ability(&"wraith_wings") and not has_used_air_jump():
			_do_jump(true)
	if not Input.is_action_pressed(&"jump") and velocity.y < jump_velocity * early_release_factor:
		velocity.y = jump_velocity * early_release_factor
	if is_on_floor() and velocity.y >= 0.0:
		air_jump_available = true

var air_jump_available := true
func has_used_air_jump() -> bool:
	return not air_jump_available

func _do_jump(is_wing_jump: bool) -> void:
	jump_buffer_left = 0.0
	coyote_left = 0.0
	velocity.y = jump_velocity
	if is_wing_jump:
		velocity.y *= 0.92
		air_jump_available = false
		current_action = &"wing_jump"
	if not is_wing_jump:
		current_action = &"jump_rise"
	_fx_burst(Color(0.72, 0.86, 1.0), 5)

func _do_wall_jump() -> void:
	jump_buffer_left = 0.0
	wall_jump_lock_left = 0.13
	var away := -signf(get_wall_normal().x)
	velocity = Vector2(away * wall_jump_speed * cos(deg_to_rad(wall_jump_angle)), -wall_jump_speed * sin(deg_to_rad(wall_jump_angle)))
	facing = away
	air_jump_available = true
	current_action = &"wall_jump"
	_fx_burst(Color(0.95, 0.66, 0.31), 7)

func _process_combat(delta: float) -> void:
	if attack_left > 0.0:
		attack_left -= delta
		if attack_left <= 0.0:
			attack_recovery_left = attack_recovery_time
		return
	if attack_recovery_left > 0.0:
		current_action = &"attack_recover"

func _start_attack() -> void:
	if attack_recovery_left > 0.0 or is_dashing:
		return
	if combo_left > 0.0:
		combo_step = mini(combo_step + 1, 3)
	if combo_left <= 0.0:
		combo_step = 1
	combo_left = combo_window
	attack_left = attack_active_time
	current_action = &"attack_%d" % combo_step
	var aim := _attack_direction()
	attack_started.emit(aim, combo_step)
	var did_pogo := aim.y > 0.5 and not is_on_floor()
	var hit_target := _find_attack_target(aim, did_pogo)
	if hit_target != null:
		if did_pogo:
			velocity.y = pogo_velocity
			air_jump_available = true
			attack_landed.emit(hit_target, true)
		if not did_pogo:
			attack_landed.emit(hit_target, false)
			_state().add_umbra(1)
			hit_stop_left = 0.045
			_fx_burst(Color(0.98, 0.78, 0.35), 10)

func _attack_direction() -> Vector2:
	var vertical := Input.get_axis(&"move_up", &"move_down")
	if absf(vertical) > 0.4:
		return Vector2(0.0, signf(vertical))
	return Vector2(facing, 0.0)

func _find_attack_target(aim: Vector2, pogo: bool) -> Node2D:
	var best: Node2D = null
	var best_distance := 104.0
	for candidate in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(candidate) or not candidate.has_method("receive_hit"):
			continue
		var offset: Vector2 = candidate.global_position - global_position
		if offset.length() > best_distance:
			continue
		if pogo and offset.y < 4.0:
			continue
		if not pogo and aim.x != 0.0 and signf(offset.x) != signf(aim.x):
			continue
		best = candidate
		best_distance = offset.length()
	return best

func _start_dash() -> void:
	if not _state().has_ability(&"fang_dash") or dash_cooldown_left > 0.0 or is_dashing:
		return
	var aim := Vector2(Input.get_axis(&"move_left", &"move_right"), Input.get_axis(&"move_up", &"move_down"))
	if aim.length_squared() < 0.1:
		aim = Vector2(facing, 0.0)
	if not _state().has_ability(&"dash_8way"):
		aim.y = 0.0
	dash_direction = aim.normalized()
	is_dashing = true
	dash_left = dash_duration
	dash_cooldown_left = dash_cooldown
	invulnerable_left = dash_duration + 0.03
	current_action = &"dash"
	_fx_burst(Color(0.32, 0.93, 0.93), 12)
	ability_used.emit(&"fang_dash")

func _process_dash(delta: float) -> void:
	dash_left -= delta
	velocity = dash_direction * dash_speed
	afterimages.push_front({"position": global_position, "life": 0.22})
	if afterimages.size() > 8:
		afterimages.pop_back()
	for image in afterimages:
		image["life"] = float(image.get("life", 0.0)) - delta
	if dash_left <= 0.0:
		is_dashing = false
		velocity = dash_direction * run_speed * 0.55
		current_action = &"idle"

func take_damage(amount: int, from: Vector2 = Vector2.ZERO) -> void:
	if is_dead or invulnerable_left > 0.0:
		return
	var died_now: bool = bool(_state().damage(amount))
	invulnerable_left = damage_invulnerability
	is_hurt = true
	current_action = &"hurt"
	var knockback_direction := -facing
	if from.x != 0.0:
		knockback_direction = -signf(from.x)
	velocity = Vector2(260.0 * knockback_direction, -240.0)
	hurt_started.emit()
	hit_stop_left = 0.05
	_fx_burst(Color(1.0, 0.28, 0.40), 9)
	if died_now:
		_die()

func _die() -> void:
	is_dead = true
	current_action = &"death"
	_state().begin_death(global_position)
	died.emit()

func revive_at(position: Vector2) -> void:
	global_position = position
	velocity = Vector2.ZERO
	is_dead = false
	is_hurt = false
	invulnerable_left = 1.0
	current_action = &"idle"

func _process_landing() -> void:
	if is_on_floor() and not was_on_floor:
		if absf(velocity.y) > 450.0:
			current_action = &"land_hard"
		if absf(velocity.y) <= 450.0:
			current_action = &"land_soft"
		_fx_burst(Color(0.66, 0.72, 0.90), 7)
		footsteps.emit()
	was_on_floor = is_on_floor()
	if not is_on_floor() and velocity.y > 20.0:
		current_action = &"fall"

func _use_ability(id: StringName) -> void:
	if not _state().has_ability(id):
		return
	if id == &"echo_needle":
		current_action = &"echo_needle"
		ability_used.emit(id)
		_fx_burst(Color(0.72, 0.38, 1.0), 14)
		for glyph in get_tree().get_nodes_in_group("secret_glyph"):
			if glyph.has_method("reveal"):
				glyph.reveal()
	elif id == &"umbral_pulse" and _state().spend_umbra(3):
		current_action = &"umbral_pulse"
		ability_used.emit(id)
		_fx_burst(Color(0.36, 0.16, 0.82), 13)
		var bolt := preload("res://scripts/combat/umbral_bolt.gd").new()
		bolt.global_position = global_position + Vector2(facing * 28.0, -8.0)
		bolt.direction = Vector2(facing, 0.0)
		get_parent().add_child(bolt)

func set_virtual_action(action: StringName, pressed: bool) -> void:
	requested_virtual_actions[action] = pressed
	if pressed and action == &"jump":
		jump_buffer_left = jump_buffer_time

func _virtual_just_pressed(action: StringName) -> bool:
	return bool(requested_virtual_actions.get(action, false))

func _virtual_axis() -> float:
	return float(requested_virtual_actions.get(&"move_right", false)) - float(requested_virtual_actions.get(&"move_left", false))

func _fx_burst(color: Color, count: int) -> void:
	# The renderer is deliberately light: particles are simple points, deterministic in headless CI.
	for index in count:
		afterimages.append({"position": global_position + Vector2(randf_range(-8.0, 8.0), randf_range(-12.0, 12.0)), "life": 0.18 + index * 0.01, "color": color})

func _draw() -> void:
	# Warm rim-light under the silhouette.
	draw_circle(Vector2(0, -10), 28.0 + sin(fx_time * 3.0) * 2.0, Color(0.18, 0.66, 0.72, 0.08))
	for image in afterimages:
		var local_position: Vector2 = to_local(image.position)
		var life := float(image.get("life", 0.0))
		var tint: Color = image.get("color", Color(0.32, 0.93, 0.93, 0.0))
		tint.a = clampf(life * 2.6, 0.0, 0.42)
		draw_circle(local_position, 11.0 * clampf(life * 5.0, 0.15, 1.0), tint)
	var bob_rate := 3.0
	if current_action == &"run":
		bob_rate = 7.0
	var bob_height := 0.0
	if current_action != &"jump_rise":
		bob_height = 2.0
	var bob := sin(fx_time * bob_rate) * bob_height
	var scale_y := 1.0
	if current_action.begins_with("land"):
		scale_y = 0.88
	var facing_sign := facing
	# Cloak and body form a readable insect-knight silhouette.
	draw_ellipse(Vector2(0, 10 + bob), Vector2(20, 23 * scale_y), Color(0.055, 0.075, 0.15, 1))
	draw_colored_polygon(PackedVector2Array([Vector2(-18, 3), Vector2(-28, 32), Vector2(0, 23), Vector2(26, 32), Vector2(17, 3)]), Color(0.08, 0.12, 0.25, 1))
	draw_circle(Vector2(0, -16 + bob), 16.0, Color(0.86, 0.92, 0.96, 1))
	draw_circle(Vector2(0, -15 + bob), 13.0, Color(0.10, 0.14, 0.27, 1))
	# antennae / mask highlights
	draw_line(Vector2(-7, -26 + bob), Vector2(-13, -39 + bob), Color(0.76, 0.84, 0.94, 1), 2.0)
	draw_line(Vector2(7, -26 + bob), Vector2(13, -39 + bob), Color(0.76, 0.84, 0.94, 1), 2.0)
	draw_circle(Vector2(-6, -16 + bob), 2.8, Color(0.38, 0.94, 0.91, 1))
	draw_circle(Vector2(6, -16 + bob), 2.8, Color(0.38, 0.94, 0.91, 1))
	if current_action.begins_with("attack"):
		var slash_color := Color(1.0, 0.82, 0.38, 0.9)
		var slash_start := Vector2(10 * facing_sign, -2)
		var slash_start_angle := 2.25
		var slash_end_angle := 4.45
		if facing_sign > 0:
			slash_start_angle = -1.1
			slash_end_angle = 1.1
		draw_arc(slash_start, 38.0, slash_start_angle, slash_end_angle, 16, slash_color, 5.0)
	if current_action == &"echo_needle":
		for radius in [25.0, 37.0, 49.0]:
			draw_arc(Vector2(0, -10), radius + sin(fx_time * 8.0) * 3.0, 0.0, TAU, 32, Color(0.72, 0.38, 1.0, 0.5), 2.0)
	if current_action == &"umbral_pulse":
		draw_circle(Vector2(27 * facing_sign, -10), 9.0 + sin(fx_time * 12.0) * 2.0, Color(0.36, 0.16, 0.82, 0.85))

# Godot's draw API does not have draw_ellipse; keep the style in one helper.
func draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in 24:
		var angle := TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
