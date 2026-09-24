extends SceneTree
## Runtime boot probe used by CI: instantiate the actual main scene, tick one frame, exit.

func _initialize() -> void:
	print("BOOT PROBE: loading main scene")
	var scene = load("res://scenes/main.tscn")
	print("BOOT PROBE: scene loaded=", scene != null)
	var player_scene = load("res://scenes/player.tscn")
	print("BOOT PROBE: player scene loaded=", player_scene != null)
	if scene == null:
		quit(1)
		return
	var instance = scene.instantiate()
	print("BOOT PROBE: instance created=", instance != null)
	if instance == null:
		quit(1)
		return
	root.add_child(instance)
	print("BOOT PROBE: main scene entered tree")
	instance.free()
	print("BOOT PROBE: main scene freed")
	quit(0)
