class_name UmbralBolt
extends Node2D

var direction := Vector2.RIGHT
var speed := 620.0
var lifetime := 1.2
var age := 0.0

func _ready() -> void:
	add_to_group("projectiles")
	queue_redraw()

func _physics_process(delta: float) -> void:
	age += delta
	position += direction * speed * delta
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) < 38.0 and enemy.has_method("receive_hit"):
			enemy.receive_hit(2, global_position)
			queue_free()
			return
	if age >= lifetime:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var pulse := 1.0 + sin(age * 25.0) * 0.15
	draw_circle(Vector2.ZERO, 12.0 * pulse, Color(0.18, 0.07, 0.40, 0.32))
	draw_circle(Vector2.ZERO, 7.0 * pulse, Color(0.36, 0.16, 0.82, 0.9))
	draw_line(Vector2(-25, 0), Vector2(0, 0), Color(0.72, 0.38, 1.0, 0.55), 3.0)
