extends SceneTree

func _initialize() -> void:
	var paths := [
		"res://scripts/core/game_state.gd",
		"res://scripts/abilities/ability_resource.gd",
		"res://scripts/player/player.gd",
		"res://scripts/world/world.gd",
		"res://scripts/world/camera_follow.gd",
		"res://scripts/world/pickup.gd",
		"res://scripts/world/secret_glyph.gd",
		"res://scripts/combat/enemy.gd",
		"res://scripts/combat/shard.gd",
		"res://scripts/combat/umbral_bolt.gd",
		"res://scripts/ui/hud.gd",
		"res://scripts/ui/touch_controls.gd",
		"res://tests/test_gameplay.gd",
		"res://tests/boot_scene.gd",
	]
	var valid := true
	for path in paths:
		var loaded = load(path)
		print("SCRIPT LOAD ", path, ": ", loaded)
		if loaded == null:
			valid = false
	if not valid:
		quit(1)
		return
	var player_scene = load("res://scenes/player.tscn") as PackedScene
	print("PLAYER SCENE LOAD: ", player_scene)
	if player_scene == null:
		quit(1)
		return
	var player_instance = player_scene.instantiate()
	print("PLAYER SCENE INSTANCE: ", player_instance)
	if player_instance == null:
		quit(1)
		return
	player_instance.free()
	var main_scene = load("res://scenes/main.tscn") as PackedScene
	print("MAIN SCENE LOAD: ", main_scene)
	if main_scene == null:
		quit(1)
		return
	var instance = main_scene.instantiate()
	print("MAIN SCENE INSTANCE: ", instance)
	if instance == null:
		quit(1)
		return
	instance.free()
	quit(0)
