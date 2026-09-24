extends SceneTree
## Headless test entrypoint. Exits non-zero on the first red contract.

var failures: Array[String] = []
var checks := 0
var test_root: Node

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
	if root.get_node_or_null("GameState") == null:
		# `--script` normally loads project autoloads; this guard keeps the test useful in editor runs.
		var state_script = load("res://scripts/core/game_state.gd")
		var state: Node = state_script.new()
		state.name = "GameState"
		root.add_child(state)
	test_root = Node.new()
	test_root.name = "TestFixtures"
	root.add_child(test_root)
	var reporter := Callable(self, "report")
	EchofangGameplayTests.test_movement_constants(reporter)
	EchofangGameplayTests.test_ability_resources(reporter)
	EchofangGameplayTests.test_damage_and_iframes(reporter, test_root)
	EchofangGameplayTests.test_save_load(reporter)
	EchofangGameplayTests.test_ability_state_actions(reporter, test_root)
	await _scene_transition_smoke()
	await _hub_sixty_second_smoke()
	if failures.is_empty():
		print("ALL TESTS PASS — %d checks" % checks)
		quit(0)
	else:
		print("TESTS FAILED — %d failures / %d checks" % [failures.size(), checks])
		quit(1)

func _scene_transition_smoke() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	report.call(scene != null, "main scene loads")
	if scene == null:
		return
	var instance := scene.instantiate()
	root.add_child(instance)
	await physics_frame
	report.call(instance.get_node_or_null("World") != null, "world node exists after transition")
	report.call(instance.get_node_or_null("HUD") != null, "HUD node exists after transition")	
	instance.queue_free()
	await process_frame

func _hub_sixty_second_smoke() -> void:
	GameState.reset_run()
	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		return
	var instance := scene.instantiate()
	root.add_child(instance)
	await physics_frame
	# 60 frames at 60x time scale is exactly one simulated minute while CI remains quick.
	Engine.time_scale = 60.0
	for frame in 60:
		await physics_frame
	Engine.time_scale = 1.0
	report.call(instance.get_node_or_null("World/Player") != null, "hub smoke keeps player alive for 60 simulated seconds")
	instance.queue_free()
	await process_frame
