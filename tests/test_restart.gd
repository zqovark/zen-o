extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	_run_test.call_deferred()


func _run_test() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await scene_changed
	var first_scene := current_scene
	var operator: OperatorSystem = first_scene.get_node("Systems/OperatorSystem")
	var objective: ObjectiveManager = first_scene.get_node("Systems/ObjectiveManager")
	var world_state: WorldStateController = first_scene.get_node("Systems/WorldStateController")
	var puzzle: AnchorPuzzleController = first_scene.get_node("AnchorPuzzle")
	var player: PlayerController = first_scene.get_node("Player")

	operator.anchor_acquired = true
	operator.active_anchor = puzzle.anchor_target
	operator.anchored_state = 1
	puzzle.anchor_target.apply_anchor(1)
	world_state.current_state = 2
	objective.current_objective = ObjectiveManager.ObjectiveState.REACH_EXIT
	objective.fragment_collected = true
	objective.exit_active = true
	puzzle.fragment.collected = true
	puzzle.puzzle_exit.active = true
	player.global_position = Vector3(9.0, 1.0, 9.0)

	reload_current_scene()
	await scene_changed
	var reset_scene := current_scene
	var reset_operator: OperatorSystem = reset_scene.get_node("Systems/OperatorSystem")
	var reset_objective: ObjectiveManager = reset_scene.get_node("Systems/ObjectiveManager")
	var reset_world: WorldStateController = reset_scene.get_node("Systems/WorldStateController")
	var reset_threshold: ZenoThresholdSystem = reset_scene.get_node("Systems/ZenoThresholdSystem")
	var reset_puzzle: AnchorPuzzleController = reset_scene.get_node("AnchorPuzzle")
	var reset_player: PlayerController = reset_scene.get_node("Player")
	var reset_debug: DebugOverlay = reset_scene.get_node("DebugOverlay")
	var reset_visualizer: ThresholdVisualizer = reset_scene.get_node("ThresholdVisualizer")

	_expect(not reset_operator.anchor_acquired, "Scene restart retained ANCHOR acquisition")
	_expect(not reset_operator.is_anchor_active(), "Scene restart retained active ANCHOR")
	_expect(reset_world.current_state == 0, "Scene restart retained world state")
	_expect(reset_threshold.current_threshold == 0, "Scene restart retained threshold state")
	_expect(
		reset_objective.current_objective == ObjectiveManager.ObjectiveState.LEARN_LAW,
		"Scene restart retained objective state"
	)
	_expect(not reset_objective.fragment_collected, "Scene restart retained Fragment collection")
	_expect(not reset_objective.exit_active and not reset_puzzle.puzzle_exit.active, "Scene restart retained active Exit")
	_expect(not reset_puzzle.anchor_target.is_anchored, "Scene restart retained anchored target state")
	_expect(reset_puzzle.fragment.visible and not reset_puzzle.fragment.collected, "Scene restart did not restore Fragment")
	_expect(reset_player.global_position.is_equal_approx(Vector3(0.0, 1.0, 2.0)), "Scene restart did not restore player position")
	_expect(not reset_debug.debug_visible, "Restart exposed solution-spoiling diagnostics by default")
	_expect(not reset_visualizer.debug_visible, "Restart exposed threshold rings by default")
	reset_scene.queue_free()
	await process_frame

	if _failures.is_empty():
		print("PASS: deterministic full-scene restart")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
