extends SceneTree
## Headless test entrypoint. Exits non-zero on the first red contract.

var failures: Array[String] = []
var checks := 0
var test_root: Node
var game_state: Variant

func _initialize() -> void:
	call_deferred("_run")

func report(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS  ", description)
	else:
		failures.append(description)
		push_error("FAIL  " + description)

func _run() -> void:
	print("Echofang headless suite — deterministic contracts")
	game_state = root.get_node_or_null("GameState")
	if game_state == null:
		# `--script` normally loads project autoloads; this guard keeps the test useful in editor runs.
		var state_script = load("res://scripts/core/game_state.gd")
		game_state = state_script.new()
		game_state.name = "GameState"
		root.add_child(game_state)
	test_root = Node.new()
	test_root.name = "TestFixtures"
	root.add_child(test_root)
	var reporter := Callable(self, "report")
	EchofangGameplayTests.test_movement_constants(reporter)
	EchofangGameplayTests.test_ability_resources(reporter, game_state)
	EchofangGameplayTests.test_damage_and_iframes(reporter, game_state, test_root)
	EchofangGameplayTests.test_save_load(reporter, game_state)
	EchofangGameplayTests.test_ability_state_actions(reporter, game_state, test_root)
	_scene_transition_smoke()
	_hub_sixty_second_smoke()
	if failures.is_empty():
		print("ALL TESTS PASS — %d checks" % checks)
		quit(0)
	else:
		print("TESTS FAILED — %d failures / %d checks" % [failures.size(), checks])
		quit(1)

func _scene_transition_smoke() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	report(scene != null, "main scene loads")
	if scene == null:
		return
	var instance := scene.instantiate()
	root.add_child(instance)
	report(instance.get_node_or_null("World") != null, "world node exists after transition")
	report(instance.get_node_or_null("HUD") != null, "HUD node exists after transition")
	instance.free()

func _hub_sixty_second_smoke() -> void:
	game_state.call("reset_run")
	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		return
	var instance := scene.instantiate()
	root.add_child(instance)
	var world: Variant = instance.get_node("World")
	var player: Variant = world.get_node("Player")
	# Advance the real gameplay methods directly for 3,600 deterministic 60Hz ticks.
	# This is a one-minute simulation without making CI sleep for one minute.
	for frame in 3600:
		player._physics_process(1.0 / 60.0)
		for enemy in world.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(enemy) and enemy.has_method("_physics_process"):
				enemy._physics_process(1.0 / 60.0)
		world._physics_process(1.0 / 60.0)
	report(player != null and is_instance_valid(player), "hub smoke keeps player alive for 60 simulated seconds")
	instance.free()
