extends Node
## Launch isolation probe.

func _ready() -> void:
	call_deferred("_start_expedition")

func _start_expedition() -> void:
	var result := get_tree().change_scene_to_file("res://scenes/player.tscn")
	if result != OK:
		push_error("Echofang bootstrap could not change to the player scene: %s" % result)
