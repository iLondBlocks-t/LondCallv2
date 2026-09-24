extends SceneTree

func _initialize() -> void:
	var player_script = load("res://scripts/player/player.gd")
	var world_script = load("res://scripts/world/world.gd")
	print("PLAYER SCRIPT LOAD: ", player_script)
	print("WORLD SCRIPT LOAD: ", world_script)
	if player_script == null or world_script == null:
		quit(1)
		return
	quit(0)
