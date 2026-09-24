class_name EchofangHUD
extends CanvasLayer

var health_label: Label
var motes_label: Label
var room_label: Label
var biome_label: Label
var ability_label: Label
var objective_label: Label
var toast_label: Label
var boss_panel: ColorRect
var boss_bar: ColorRect
var title_label: Label
var title_timer := 5.5

func _ready() -> void:
	layer = 20
	_build_ui()
	var world := get_parent().get_node_or_null("World") as EchofangWorld
	if world != null:
		world.room_changed.connect(_on_room_changed)
		world.toast_requested.connect(show_toast)
		world.boss_state_changed.connect(_on_boss_state)
	_on_room_changed(2, "GLOAMROOT", "Lantern Hub")
	GameState.health_changed.connect(_on_health_changed)
	GameState.motes_changed.connect(_on_motes_changed)
	GameState.ability_unlocked.connect(_on_ability_unlocked)
	_refresh()

func _process(delta: float) -> void:
	if title_timer > 0.0:
		title_timer -= delta
		title_label.modulate.a = clampf(title_timer * 1.2, 0.0, 1.0)
	if toast_label.modulate.a > 0.0:
		toast_label.modulate.a = maxf(0.0, toast_label.modulate.a - delta * 0.24)

func _style_label(label: Label, size: int, color: Color) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _make_label(parent: Node, text: String, position: Vector2, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	_style_label(label, size, color)
	parent.add_child(label)
	return label

func _build_ui() -> void:
	var root := Control.new()
	root.name = "SafeArea"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 44)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var top_strip := ColorRect.new()
	top_strip.position = Vector2(0, 0)
	top_strip.size = Vector2(1280, 76)
	top_strip.color = Color(0.025, 0.035, 0.08, 0.78)
	top_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top_strip)
	health_label = _make_label(root, "MASKS  ◇◇◇◇◇", Vector2(24, 16), 21, Color(0.98, 0.78, 0.42))
	motes_label = _make_label(root, "MOTES  000", Vector2(24, 44), 14, Color(0.67, 0.78, 0.96))
	room_label = _make_label(root, "02  LANTERN HUB", Vector2(400, 16), 18, Color(0.88, 0.93, 1.0))
	biome_label = _make_label(root, "GLOAMROOT", Vector2(400, 44), 13, Color(0.45, 0.86, 0.80))
	ability_label = _make_label(root, "ECHO NEEDLE  [Z]     FANG DASH [C]     WINGS [SPACE]     PULSE [V]", Vector2(690, 22), 12, Color(0.72, 0.80, 0.96))
	ability_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ability_label.size = Vector2(540, 38)
	objective_label = _make_label(root, "FOLLOW THE HUMMING GLYPH", Vector2(24, 636), 14, Color(0.80, 0.86, 0.98))
	toast_label = _make_label(root, "", Vector2(310, 592), 18, Color(0.95, 0.77, 0.36))
	toast_label.size = Vector2(650, 42)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.modulate.a = 0.0
	# Small title card makes the hub a reachable front door rather than a silent test scene.
	title_label = _make_label(root, "E C H O F A N G\nTHE KINGDOM REMEMBERS", Vector2(390, 240), 30, Color(0.86, 0.94, 1.0))
	title_label.size = Vector2(500, 100)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Boss bar is hidden until the arena room.
	boss_panel = ColorRect.new()
	boss_panel.position = Vector2(390, 92)
	boss_panel.size = Vector2(500, 18)
	boss_panel.color = Color(0.05, 0.03, 0.11, 0.9)
	boss_panel.visible = false
	root.add_child(boss_panel)
	boss_bar = ColorRect.new()
	boss_bar.position = Vector2(3, 3)
	boss_bar.size = Vector2(494, 12)
	boss_bar.color = Color(0.72, 0.38, 1.0)
	boss_panel.add_child(boss_bar)
	var boss_name := _make_label(root, "THE PALE CHOIR", Vector2(390, 113), 12, Color(0.85, 0.72, 1.0))
	boss_name.size = Vector2(500, 26)
	boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Always-visible input legend for keyboard and controller players.
	var legend := _make_label(root, "A/D MOVE   SPACE JUMP   X ATTACK / POGO   C DASH   Z ECHO   V UMBRA", Vector2(260, 676), 12, Color(0.46, 0.56, 0.74))
	legend.size = Vector2(760, 24)
	legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _refresh() -> void:
	_on_health_changed(GameState.health, GameState.MAX_HEALTH)
	_on_motes_changed(GameState.motes)
	_on_ability_unlocked(&"")

func _on_health_changed(current: int, maximum: int) -> void:
	if health_label == null:
		return
	var masks := ""
	for index in maximum:
		masks += "◇" if index >= current else "◆"
	health_label.text = "MASKS  %s" % masks

func _on_motes_changed(amount: int) -> void:
	if motes_label != null:
		motes_label.text = "MOTES  %03d" % amount

func _on_room_changed(number: int, biome: String, room_name: String) -> void:
	if room_label == null:
		return
	room_label.text = "%02d  %s" % [number, room_name.to_upper()]
	biome_label.text = biome
	objective_label.text = "REACH THE CHOIR ARENA" if number >= 17 else "FOLLOW THE HUMMING GLYPH"

func _on_ability_unlocked(_id: StringName) -> void:
	if ability_label == null:
		return
	var parts: Array[String] = []
	parts.append("ECHO" if GameState.has_ability(&"echo_needle") else "ECHO —")
	parts.append("DASH" if GameState.has_ability(&"fang_dash") else "DASH —")
	parts.append("WINGS" if GameState.has_ability(&"wraith_wings") else "WINGS —")
	parts.append("PULSE" if GameState.has_ability(&"umbral_pulse") else "PULSE —")
	parts.append("CLING" if GameState.has_ability(&"wall_cling") else "CLING —")
	ability_label.text = "  ".join(parts)

func show_toast(message: String, color := Color(0.95, 0.77, 0.36)) -> void:
	if toast_label == null:
		return
	toast_label.text = message
	toast_label.add_theme_color_override("font_color", color)
	toast_label.modulate.a = 1.0

func _on_boss_state(current: int, phase: int) -> void:
	if boss_panel == null:
		return
	boss_panel.visible = phase > 0 and current > 0
	boss_bar.size.x = 494.0 * clampf(float(current) / 24.0, 0.0, 1.0)
