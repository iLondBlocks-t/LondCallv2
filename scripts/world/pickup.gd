extends Area2D

var ability_id: StringName
var display_name := ""
var color := Color.WHITE
var pulse := 0.0
var collected := false

func _state():
	return get_tree().root.get_node_or_null("GameState")

func setup(id: StringName, label: String, tint: Color) -> void:
	ability_id = id
	display_name = label
	color = tint
	monitoring = true
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 48.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _process(delta: float) -> void:
	pulse += delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if collected or not body.is_in_group("player"):
		return
	collected = true
	_state().unlock_ability(ability_id)
	queue_free()

func _draw() -> void:
	var radius := 25.0 + sin(pulse * 3.0) * 3.0
	draw_circle(Vector2.ZERO, radius + 12.0, Color(color, 0.08))
	draw_arc(Vector2.ZERO, radius + 8.0, pulse, pulse + PI * 1.55, 20, Color(color, 0.72), 2.0)
	draw_circle(Vector2.ZERO, radius, Color(0.07, 0.08, 0.17, 0.92))
	draw_circle(Vector2.ZERO, 10.0, color)
	draw_string(ThemeDB.fallback_font, Vector2(-64, 55), display_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 128, 13, Color(0.84, 0.90, 1.0, 0.9))
