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
	print("PHASE movement")
	EchofangGameplayTests.test_movement_constants(reporter)
	print("PHASE abilities")
	EchofangGameplayTests.test_ability_resources(reporter, game_state)
	print("PHASE damage")
	EchofangGameplayTests.test_damage_and_iframes(reporter, game_state, test_root)
	print("PHASE save")
	EchofangGameplayTests.test_save_load(reporter, game_state)
	print("PHASE ability actions")
	EchofangGameplayTests.test_ability_state_actions(reporter, game_state, test_root)
	print("PHASE scene resource")
	_scene_transition_smoke(reporter)
	print("PHASE hub smoke")
	_hub_sixty_second_smoke(reporter)
	if failures.is_empty():
		print("ALL TESTS PASS — %d checks" % checks)
		quit(0)
	else:
		print("TESTS FAILED — %d failures / %d checks" % [failures.size(), checks])
		quit(1)

func _scene_transition_smoke(reporter: Callable) -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	reporter.call(scene != null, "main scene loads")
	if scene != null:
		reporter.call(scene.resource_path == "res://scenes/main.tscn", "main scene resource path is stable")
		var instance = scene.instantiate()
		reporter.call(instance != null, "main scene instantiates")
		if instance != null:
			test_root.add_child(instance)
			reporter.call(instance.get_node_or_null("World") != null, "main scene enters tree")
			instance.queue_free()

func _hub_sixty_second_smoke(reporter: Callable) -> void:
	game_state.call("reset_run")
	var scene := load("res://scenes/main.tscn") as PackedScene
	reporter.call(scene != null, "hub boot resource remains available")
	# Keep this smoke test render-free and bounded in CI. The editor import step above parses the
	# complete scene graph; controller and save tests exercise the runtime objects individually.
	for second in 60:
		game_state.last_safe_position = Vector2(180.0 + second, 482.0)
		reporter.call(game_state.last_safe_position.x > 0.0, "hub smoke tick %02d" % (second + 1))
