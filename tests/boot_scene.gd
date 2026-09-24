extends SceneTree
## Runtime boot probe used by CI: instantiate the actual main scene, tick one frame, exit.

func _initialize() -> void:
	print("BOOT PROBE: loading main scene")
	var scene = load("res://scenes/main.tscn")
	if scene == null:
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
