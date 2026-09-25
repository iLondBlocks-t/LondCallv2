extends Node
## Defers the authored world one frame so Godot has initialized project autoloads first.

func _ready() -> void:
	call_deferred("_start_expedition")

func _start_expedition() -> void:
	var result := get_tree().change_scene_to_file("res://scenes/main.tscn")
	if result != OK:
		push_error("Echofang bootstrap could not change to the main scene: %s" % result)
