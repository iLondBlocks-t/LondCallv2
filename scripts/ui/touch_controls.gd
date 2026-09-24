class_name EchofangTouchControls
extends CanvasLayer
## Landscape-safe touch overlay; the same InputMap actions feed keyboard, gamepad, and touch.

var root: Control
var button_style: StyleBoxFlat
var pressed_style: StyleBoxFlat

func _ready() -> void:
	print("ECHOFANG READY TOUCH")
	layer = 30
	_build_styles()
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 44)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_build_dpad()
	_build_action_buttons()

func _build_styles() -> void:
	button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.08, 0.15, 0.28, 0.48)
	button_style.border_color = Color(0.46, 0.85, 0.90, 0.35)
	button_style.set_border_width_all(2)
	button_style.corner_radius_top_left = 18
	button_style.corner_radius_top_right = 18
	button_style.corner_radius_bottom_left = 18
	button_style.corner_radius_bottom_right = 18
	pressed_style = button_style.duplicate()
	pressed_style.bg_color = Color(0.32, 0.93, 0.93, 0.62)
	pressed_style.border_color = Color(0.84, 1.0, 1.0, 0.92)

func _new_button(label: String, at: Vector2, size: Vector2, action: StringName, tint := Color(0.75, 0.90, 1.0)) -> Button:
	var button := Button.new()
	button.text = label
	button.position = at
	button.size = size
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", button_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", tint)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	root.add_child(button)
	button.button_down.connect(func() -> void:
		Input.action_press(action)
		Input.vibrate_handheld(18)
	)
	button.button_up.connect(func() -> void:
		Input.action_release(action)
	)
	return button

func _build_dpad() -> void:
	var base := ColorRect.new()
	base.position = Vector2(34, 470)
	base.size = Vector2(252, 188)
	base.color = Color(0.02, 0.04, 0.10, 0.14)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(base)
	_new_button("◀", Vector2(50, 526), Vector2(70, 64), &"move_left")
	_new_button("▶", Vector2(200, 526), Vector2(70, 64), &"move_right")
	_new_button("▲", Vector2(125, 480), Vector2(70, 64), &"move_up", Color(0.72, 0.82, 1.0))
	_new_button("▼", Vector2(125, 572), Vector2(70, 64), &"move_down", Color(0.72, 0.82, 1.0))

func _build_action_buttons() -> void:
	_new_button("JUMP", Vector2(1030, 472), Vector2(116, 72), &"jump", Color(0.80, 0.95, 1.0))
	_new_button("NAIL", Vector2(1160, 405), Vector2(86, 86), &"attack", Color(1.0, 0.82, 0.42))
	_new_button("DASH", Vector2(905, 560), Vector2(104, 64), &"dash", Color(0.32, 0.93, 0.93))
	_new_button("ECHO", Vector2(1030, 570), Vector2(104, 64), &"ability_1", Color(0.72, 0.38, 1.0))
	_new_button("UMBRA", Vector2(1160, 510), Vector2(86, 64), &"ability_2", Color(0.72, 0.48, 1.0))
