extends Node2D

var direction := Vector2.RIGHT
var speed := 230.0
var lifetime := 2.7
var age := 0.0

func _physics_process(delta: float) -> void:
	age += delta
	position += direction * speed * delta
	var player := get_tree().get_first_node_in_group("player")
	if player != null and global_position.distance_to(player.global_position) < 22.0:
		player.take_damage(1, direction)
		queue_free()
	if age > lifetime:
		queue_free()
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 8.0, Color(0.72, 0.38, 1.0, 0.45))
	draw_colored_polygon(PackedVector2Array([Vector2(12, 0), Vector2(0, 5), Vector2(-12, 0), Vector2(0, -5)]), Color(0.91, 0.72, 1.0, 0.95))
