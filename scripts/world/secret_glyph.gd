extends Node2D

var revealed := false
var opened := false
var pulse := 0.0
var secret_label := "SECRET"

func setup(label: String) -> void:
	secret_label = label
	add_to_group("secret_glyph")
	queue_redraw()

func reveal() -> void:
	revealed = true
	opened = true
	queue_redraw()

func _process(delta: float) -> void:
	pulse += delta
	queue_redraw()

func _draw() -> void:
	var tint := Color(0.72, 0.38, 1.0, 0.75 if revealed else 0.20)
	draw_circle(Vector2.ZERO, 34.0 + sin(pulse * 4.0) * 2.0, Color(tint, 0.07))
	draw_arc(Vector2.ZERO, 23.0, pulse, pulse + PI * 1.6, 18, tint, 3.0)
	draw_line(Vector2(-9, 0), Vector2(0, -12), tint, 3.0)
	draw_line(Vector2(0, -12), Vector2(12, 4), tint, 3.0)
	if revealed:
		draw_string(ThemeDB.fallback_font, Vector2(-52, 52), secret_label, HORIZONTAL_ALIGNMENT_CENTER, 104, 12, Color(0.84, 0.70, 1.0, 0.9))
