class_name EchofangCamera
extends Camera2D

@export var follow_speed := 7.0
@export var look_ahead := 110.0
@export var vertical_offset := -55.0
var shake_time := 0.0
var shake_strength := 0.0
var target: Node2D

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = follow_speed
	limit_left = 0
	limit_top = 0
	limit_right = 30720
	limit_bottom = 720
	target = get_parent() as Node2D

func _process(delta: float) -> void:
	if target == null:
		return
	var desired := Vector2(target.global_position.x + target.velocity.x * 0.18 + signf(target.facing) * look_ahead, target.global_position.y + vertical_offset)
	global_position = global_position.lerp(desired, 1.0 - exp(-follow_speed * delta))
	if shake_time > 0.0:
		shake_time -= delta
		position += Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

func shake(strength := 4.0, duration := 0.12) -> void:
	shake_strength = maxf(shake_strength, strength)
	shake_time = maxf(shake_time, duration)
