extends SceneTree
## Runtime boot probe used by CI: instantiate the actual main scene, tick one frame, exit.

func _initialize() -> void:
	print("BOOT PROBE: loading main scene")
	var scene = load("res://scenes/main.tscn")
	print("BOOT PROBE: scene loaded=", scene != null, " can_instantiate=", scene != null and scene.can_instantiate())
	var player_scene = load("res://scenes/player.tscn")
	print("BOOT PROBE: player scene loaded=", player_scene != null, " can_instantiate=", player_scene != null and player_scene.can_instantiate())
	if scene == null or not scene.can_instantiate():
		quit(1)
		return
	var instance = scene.instantiate()
	if instance == null:
		quit(1)
		return
	root.add_child(instance)
	print("BOOT PROBE: main scene entered tree")
	instance.free()
	print("BOOT PROBE: main scene freed")
	quit(0)
