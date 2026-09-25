extends Node
## Temporary launch isolation probe.

func _ready() -> void:
	print("ECHOFANG BOOTSTRAP READY")
	get_tree().quit(0)
