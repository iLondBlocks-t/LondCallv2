class_name EchofangGameplayTests
extends RefCounted
## Small, deterministic test helpers used by tests/run_tests.gd.

static func test_movement_constants(report: Callable) -> void:
	var player_script = load("res://scripts/player/player.gd")
	var player := player_script.new() as EchofangPlayer
	report.call(is_equal_approx(player.coyote_time, 0.120), "coyote time is 120ms")
	report.call(is_equal_approx(player.jump_buffer_time, 0.150), "jump buffer is 150ms")
	report.call(is_equal_approx(player.acceleration_time, 0.060), "acceleration is 60ms")
	report.call(is_equal_approx(player.deceleration_time, 0.040), "deceleration is 40ms")
	report.call(is_equal_approx(player.dash_duration, 0.150), "dash duration is 150ms")
	player.free()

static func test_ability_resources(report: Callable) -> void:
	var expected := ["fang_dash", "wraith_wings", "wall_cling", "echo_needle", "umbral_pulse"]
	for id in expected:
		var resource = load("res://resources/abilities/%s.tres" % id)
		report.call(resource != null, "%s resource loads" % id)
		if resource != null:
			report.call(resource.ability_id == StringName(id), "%s resource id" % id)
	GameState.reset_run()
	for id in expected:
		GameState.unlock_ability(StringName(id))
		report.call(GameState.has_ability(StringName(id)), "%s transitions to unlocked" % id)

static func test_damage_and_iframes(report: Callable, parent: Node) -> void:
	GameState.reset_run()
	var player := preload("res://scripts/player/player.gd").new() as EchofangPlayer
	parent.add_child(player)
	player.take_damage(1, Vector2.RIGHT)
	report.call(GameState.health == GameState.MAX_HEALTH - 1, "damage removes one mask")
	player.take_damage(1, Vector2.RIGHT)
	report.call(GameState.health == GameState.MAX_HEALTH - 1, "i-frames reject immediate repeat damage")
	player.free()

static func test_save_load(report: Callable) -> void:
	GameState.reset_run()
	GameState.unlock_ability(&"fang_dash")
	GameState.add_motes(37)
	GameState.last_safe_position = Vector2(1234.0, 482.0)
	report.call(GameState.save_game(), "save writes JSON")
	GameState.reset_run()
	report.call(GameState.load_game(), "load reads JSON")
	report.call(GameState.has_ability(&"fang_dash"), "save/load persists ability")
	report.call(GameState.motes == 37, "save/load persists Motes")
	report.call(GameState.last_safe_position.is_equal_approx(Vector2(1234.0, 482.0)), "save/load persists position")

static func test_ability_state_actions(report: Callable, parent: Node) -> void:
	GameState.reset_run()
	GameState.unlock_ability(&"fang_dash")
	var player := preload("res://scripts/player/player.gd").new() as EchofangPlayer
	parent.add_child(player)
	player._start_dash()
	report.call(player.is_dashing, "Fang Dash enters dash state")
	report.call(player.invulnerable_left > 0.0, "Fang Dash grants i-frames")
	player.queue_free()
