extends Node
## Launch isolation probe.

func _ready() -> void:
	call_deferred("_start_expedition")

func _start_expedition() -> void:
	var probe := CharacterBody2D.new()
	probe.set_script(load("res://scripts/player/player.gd"))
	add_child(probe)
