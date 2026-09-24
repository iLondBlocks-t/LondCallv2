extends SceneTree
## Runtime boot probe used by CI: instantiate the actual main scene, tick one frame, exit.

func _initialize() -> void:
	call_deferred("_boot")

func _boot() -> void:
	print("BOOT PROBE: loading main scene")
	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		quit(1)
		return
	var instance := scene.instantiate()
	if instance == null:
		quit(1)
		return
	root.add_child(instance)
	print("BOOT PROBE: main scene entered tree")
	await process_frame
	print("BOOT PROBE: one frame completed")
	instance.free()
	quit(0)
