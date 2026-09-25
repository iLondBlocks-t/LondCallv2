extends Node
## Defers the authored world one frame so Godot has initialized project autoloads first.
## This also makes Android and headless launches use the same deterministic entry path.

var world_instance: Node

func _ready() -> void:
	call_deferred("_start_expedition")

func _start_expedition() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		push_error("Echofang bootstrap could not load the main scene")
		return
	world_instance = scene.instantiate()
	if world_instance == null:
		push_error("Echofang bootstrap could not instantiate the main scene")
		return
	world_instance.name = "EchofangWorldRoot"
	add_child(world_instance)
