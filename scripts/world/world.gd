class_name EchofangWorld
extends Node2D
## Authored 24-cell slice: collision, room graph, gates, enemies, ambient painting.

signal room_changed(room_number: int, biome: String, room_name: String)
signal toast_requested(message: String, color: Color)
signal boss_state_changed(health: int, phase: int)

const ROOM_WIDTH := 1280.0
const ROOM_COUNT := 24
const WORLD_WIDTH := ROOM_WIDTH * ROOM_COUNT
const GROUND_Y := 550.0

var player: EchofangPlayer
var gates: Array[Dictionary] = []
var current_room := -1
var current_biome := ""
var room_names := [
	"Gloamroot Landing", "Lantern Hub", "Rootwell Lift", "Mosswalk", "Husk Cellar", "Forgotten Niche",
	"Dash Chasm", "Moss Gate", "Tide Steps", "Glassworks", "Wraith Shaft", "Blackwater",
	"Mote Vault", "Needle Mural", "Flooded Shortcut", "Choir Antechamber", "Index of Ash", "Scriptorium",
	"Umbral Lock", "Echo Alcove", "Hanging Stacks", "Parity Hall", "Pale Door", "Choir Arena"
]
var ability_labels := {
	&"echo_needle": ["Echo Needle", Color(0.72, 0.38, 1.0)],
	&"fang_dash": ["Fang Dash", Color(0.32, 0.93, 0.93)],
	&"wraith_wings": ["Wraith Wings", Color(0.77, 0.86, 1.0)],
	&"umbral_pulse": ["Umbral Pulse", Color(0.36, 0.16, 0.82)],
	&"wall_cling": ["Wall Cling", Color(0.95, 0.66, 0.31)],
}
var ambient_time := 0.0
var death_timer := 0.0
var boss: EchofangEnemy

func _ready() -> void:
	if not GameState.expedition_started:
		GameState.reset_run()
	_build_atmosphere()
	_build_collision()
	_spawn_player()
	_spawn_pickups()
	_spawn_secrets()
	_spawn_enemies()
	GameState.ability_unlocked.connect(_on_ability_unlocked)
	queue_redraw()

func _build_atmosphere() -> void:
	var wash := CanvasModulate.new()
	wash.name = "DeepBlueCanvasModulate"
	wash.color = Color(0.56, 0.64, 0.88, 1.0)
	add_child(wash)
	var rim_light := PointLight2D.new()
	rim_light.name = "PlayerRimLight"
	rim_light.energy = 0.0 # The silhouette renderer owns the crisp rim; this is the runtime light hook.
	add_child(rim_light)

func _build_collision() -> void:
	for room in ROOM_COUNT:
		_add_box("Ground_%02d" % (room + 1), Vector2(room * ROOM_WIDTH + ROOM_WIDTH * 0.5, GROUND_Y + 65.0), Vector2(ROOM_WIDTH, 130.0))
		# A staggered one-way ledge in each cell creates pogo and wing routes.
		_add_platform(Vector2(room * ROOM_WIDTH + 360.0, 410.0 + float(room % 3) * 25.0), Vector2(230.0, 22.0))
		_add_platform(Vector2(room * ROOM_WIDTH + 820.0, 335.0 + float(room % 2) * 35.0), Vector2(190.0, 22.0))
	_add_gate(3300.0, &"fang_dash", "FANG CHASM")
	_add_gate(8700.0, &"wraith_wings", "WRAITH SHAFT")
	_add_gate(14200.0, &"umbral_pulse", "UMBRAL LOCK")
	_add_gate(19200.0, &"wall_cling", "ARCHIVE WALLS")

func _add_box(label: String, center: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = label
	body.collision_layer = 1
	body.collision_mask = 2
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	shape_node.shape = shape
	body.position = center
	body.add_child(shape_node)
	add_child(body)
	return body

func _add_platform(center: Vector2, size: Vector2) -> void:
	var body := _add_box("OneWayPlatform", center, size)
	var shape_node := body.get_child(0) as CollisionShape2D
	shape_node.one_way_collision = true
	shape_node.one_way_collision_margin = 8.0

func _add_gate(x_position: float, needed: StringName, label: String) -> void:
	var body := _add_box("Gate_%s" % needed, Vector2(x_position, 330.0), Vector2(26.0, 440.0))
	gates.append({"body": body, "ability": needed, "label": label})

func _spawn_player() -> void:
	var player_scene := preload("res://scenes/player.tscn")
	player = player_scene.instantiate() as EchofangPlayer
	add_child(player)
	player.global_position = GameState.last_safe_position
	player.attack_landed.connect(_on_attack_landed)
	player.hurt_started.connect(_on_player_hurt)
	player.died.connect(_on_player_died)
	player.ability_used.connect(_on_player_ability_used)

func _spawn_pickups() -> void:
	_spawn_pickup(&"echo_needle", Vector2(630.0, 300.0))
	_spawn_pickup(&"fang_dash", Vector2(2150.0, 475.0))
	_spawn_pickup(&"wraith_wings", Vector2(10550.0, 300.0))
	_spawn_pickup(&"umbral_pulse", Vector2(15100.0, 475.0))
	_spawn_pickup(&"wall_cling", Vector2(19800.0, 300.0))

func _spawn_pickup(id: StringName, at: Vector2) -> void:
	if GameState.has_ability(id):
		return
	var pickup := preload("res://scripts/world/pickup.gd").new() as AbilityPickup
	var metadata: Array = ability_labels[id]
	pickup.setup(id, metadata[0], metadata[1])
	pickup.position = at
	add_child(pickup)

func _spawn_secrets() -> void:
	var secret_positions := [Vector2(2300.0, 445.0), Vector2(12200.0, 445.0), Vector2(17000.0, 445.0), Vector2(24700.0, 445.0)]
	for index in secret_positions.size():
		var glyph := preload("res://scripts/world/secret_glyph.gd").new() as SecretGlyph
		glyph.position = secret_positions[index]
		glyph.setup("SECRET %02d" % (index + 1))
		add_child(glyph)

func _spawn_enemies() -> void:
	var roster := [
		["rootling", 1160.0], ["sporeback", 2780.0], ["lantern_mite", 3900.0], ["glasswing", 4950.0],
		["tide_crawler", 6250.0], ["gallery_sentry", 7400.0], ["archive_wisp", 9300.0], ["choir_knight", 11300.0],
		["sporeback", 12800.0], ["gallery_sentry", 15500.0], ["glasswing", 16800.0], ["tide_crawler", 18100.0],
		["archive_wisp", 20400.0], ["choir_knight", 22100.0], ["gallery_sentry", 24200.0], ["sporeback", 26600.0],
	]
	for item in roster:
		_spawn_enemy(str(item[0]), float(item[1]), false)
	boss = _spawn_enemy("boss", WORLD_WIDTH - 340.0, true)

func _spawn_enemy(kind: String, x_position: float, is_boss: bool) -> EchofangEnemy:
	var enemy := preload("res://scripts/combat/enemy.gd").new() as EchofangEnemy
	add_child(enemy)
	enemy.setup(kind, Vector2(x_position, GROUND_Y - 30.0), is_boss)
	if is_boss:
		enemy.defeated.connect(_on_boss_defeated)
		enemy.telegraph_started.connect(_on_boss_telegraph)
	return enemy

func _physics_process(delta: float) -> void:
	ambient_time += delta
	if player == null:
		return
	for gate in gates:
		var body: StaticBody2D = gate.body
		var open := GameState.has_ability(StringName(gate.ability))
		body.collision_layer = 0 if open else 1
		body.collision_mask = 0 if open else 2
		body.modulate = Color(0.6, 0.9, 1.0, 0.12 if open else 0.82)
		if not open and absf(player.global_position.x - body.global_position.x) < 100.0:
			toast_requested.emit("%s — FIND THE ECHO" % gate.label, Color(1.0, 0.66, 0.31))
	var room := clampi(int(floor(player.global_position.x / ROOM_WIDTH)) + 1, 1, ROOM_COUNT)
	if room != current_room:
		current_room = room
		GameState.current_room = room
		current_biome = _biome_for_room(room)
		GameState.last_safe_position = player.global_position
		GameState.save_game()
		room_changed.emit(room, current_biome, room_names[room - 1])
	if GameState.recovery_motes > 0 and player.global_position.distance_to(GameState.recovery_position) < 48.0:
		var recovered := GameState.recover_corpse()
		toast_requested.emit("CORPSE RECOVERED  +%d MOTES" % recovered, Color(0.95, 0.77, 0.36))
	if player.is_dead:
		death_timer += delta
		if death_timer > 2.0:
			player.revive_at(GameState.last_safe_position)
			death_timer = 0.0
			toast_requested.emit("THE ECHO REMEMBERS.  TRY AGAIN.", Color(0.72, 0.38, 1.0))
	if boss != null and is_instance_valid(boss) and not boss.defeated_state and room >= ROOM_COUNT:
		boss_state_changed.emit(boss.health, boss.phase)
	else:
		boss_state_changed.emit(0, 0)
	queue_redraw()

func _biome_for_room(room: int) -> String:
	if room <= 8:
		return "GLOAMROOT"
	if room <= 16:
		return "SUNKEN GALLERIES"
	return "MOONLESS ARCHIVE"

func _on_ability_unlocked(id: StringName) -> void:
	var metadata: Array = ability_labels.get(id, [str(id), Color.WHITE])
	toast_requested.emit("%s AWAKENS" % metadata[0].to_upper(), metadata[1])
	GameState.save_game()

func _on_player_ability_used(id: StringName) -> void:
	if id == &"echo_needle":
		toast_requested.emit("THE HIDDEN REMEMBERS", Color(0.72, 0.38, 1.0))
	elif id == &"umbral_pulse":
		toast_requested.emit("UMBRA RELEASED", Color(0.36, 0.16, 0.82))

func _on_attack_landed(target: Node2D, pogo: bool) -> void:
	if target != null and target.has_method("receive_hit"):
		target.receive_hit(2 if pogo else 1, player.global_position)
		var camera := player.get_node_or_null("Camera") as EchofangCamera
		if camera != null:
			camera.shake(5.0 if pogo else 3.0, 0.10)

func _on_player_hurt() -> void:
	var camera := player.get_node_or_null("Camera") as EchofangCamera
	if camera != null:
		camera.shake(7.0, 0.15)

func _on_player_died() -> void:
	var camera := player.get_node_or_null("Camera") as EchofangCamera
	if camera != null:
		camera.shake(10.0, 0.3)

func _on_boss_telegraph(_enemy: Node2D, _duration: float) -> void:
	toast_requested.emit("ECHO NEEDLE: PARRY THE VIOLET MARK", Color(0.72, 0.38, 1.0))

func _on_boss_defeated(_enemy: Node2D, _motes: int) -> void:
	toast_requested.emit("THE PALE CHOIR FALLS — VERTICAL SLICE COMPLETE", Color(0.95, 0.77, 0.36))

func _draw() -> void:
	# Three parallax bands: moon-blue stone, muted roots, and drifting spores.
	draw_rect(Rect2(0, 0, WORLD_WIDTH, 720), Color(0.035, 0.047, 0.09, 1))
	for room in ROOM_COUNT:
		var x := float(room) * ROOM_WIDTH
		var biome := _biome_for_room(room + 1)
		var bg := Color(0.055, 0.075, 0.15, 1)
		if biome == "SUNKEN GALLERIES":
			bg = Color(0.035, 0.095, 0.16, 1)
		elif biome == "MOONLESS ARCHIVE":
			bg = Color(0.085, 0.055, 0.14, 1)
		draw_rect(Rect2(x, 0, ROOM_WIDTH, 720), bg)
		# Large parallax arches.
		for arch in 3:
			var arch_x := x + 120.0 + arch * 420.0 + sin(ambient_time * 0.12 + room) * 18.0
			draw_arc(Vector2(arch_x, 520), 235.0 + arch * 18.0, PI, TAU, 24, Color(0.12, 0.16, 0.29, 0.32), 28.0)
		# root/pipe silhouettes
		draw_line(Vector2(x + 50, 105 + arch * 30), Vector2(x + 320, 240 + arch * 22), Color(0.10, 0.18, 0.25, 0.55), 15.0)
		draw_line(Vector2(x + 820, 100 + arch * 22), Vector2(x + 1040, 330), Color(0.15, 0.10, 0.25, 0.58), 10.0)
		if room % 2 == 0:
			draw_circle(Vector2(x + 210, 190 + sin(ambient_time * 0.7 + room) * 9.0), 3.0, Color(0.45, 0.92, 0.86, 0.62))
			draw_circle(Vector2(x + 980, 250 + sin(ambient_time * 0.8 + room) * 11.0), 2.0, Color(0.76, 0.38, 1.0, 0.64))
		# room card / biome marker
		draw_string(ThemeDB.fallback_font, Vector2(x + 32, 62), "%02d  %s" % [room + 1, room_names[room]], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.64, 0.72, 0.90, 0.62))
	# ground shelf and glowing seam
	draw_rect(Rect2(0, GROUND_Y, WORLD_WIDTH, 170), Color(0.025, 0.035, 0.075, 1))
	for seam in range(0, int(WORLD_WIDTH), 80):
		draw_line(Vector2(seam, GROUND_Y), Vector2(seam + 40, GROUND_Y), Color(0.16, 0.25, 0.40, 0.36), 2.0)
	# Gate glyphs show the rule before the collision is encountered.
	for gate in gates:
		var body: StaticBody2D = gate.body
		var open := GameState.has_ability(StringName(gate.ability))
		var color := Color(0.32, 0.93, 0.93, 0.24 if open else 0.88)
		draw_line(Vector2(body.position.x, 110), Vector2(body.position.x, 540), color, 5.0)
		draw_string(ThemeDB.fallback_font, Vector2(body.position.x - 100, 118), str(gate.label), HORIZONTAL_ALIGNMENT_CENTER, 200, 13, color)
