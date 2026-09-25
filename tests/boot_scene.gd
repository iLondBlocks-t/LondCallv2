extends SceneTree
## Optional diagnostic for the same deferred scene transition used by the project entrypoint.

func _initialize() -> void:
	call_deferred("_boot")

func _boot() -> void:
	var result := change_scene_to_file("res://scenes/main.tscn")
	if result != OK:
		push_error("Main scene transition failed: %s" % result)
		quit(1)
		return
	call_deferred("_finish")

func _finish() -> void:
	print("BOOT PROBE: main scene entered")
	quit(0)
