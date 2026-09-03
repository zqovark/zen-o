extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	_run_tests.call_deferred()


func _run_tests() -> void:
	_test_operator_semantics()
	_test_objective_flow()
	await _test_complete_spatial_solution()
	await create_timer(0.5).timeout

	if _failures.is_empty():
		print("PASS: ANCHOR semantics, impossible relation, puzzle completion, and reset")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _test_operator_semantics() -> void:
	var operator := OperatorSystem.new()
	root.add_child(operator)
	var first_target := AnchorableSpatialTarget.new()
	var second_target := AnchorableSpatialTarget.new()
	root.add_child(first_target)
	root.add_child(second_target)
	_expect(not operator.apply_anchor(first_target, 1), "ANCHOR applied before acquisition")
	_expect(operator.acquire_anchor(), "ANCHOR acquisition failed")
	_expect(not operator.acquire_anchor(), "ANCHOR was acquired twice")
	_expect(operator.apply_anchor(first_target, 1), "ANCHOR did not apply")
	_expect(first_target.is_anchored and first_target.anchored_state == 1, "Target did not preserve State 1")
	_expect(operator.apply_anchor(first_target, 2), "Re-anchoring the same target was prevented")
	_expect(first_target.anchored_state == 2, "Re-anchoring did not replace the saved relation")
	_expect(operator.apply_anchor(second_target, 1), "A new eligible target could not replace the active anchor")
	_expect(not first_target.is_anchored, "Previous active target was not released")
	_expect(second_target.is_anchored, "Replacement target was not anchored")
	operator.reset()
	_expect(not operator.anchor_acquired, "Operator reset retained acquisition")
	_expect(not operator.is_anchor_active(), "Operator reset retained an active anchor")
	first_target.free()
	second_target.free()
	operator.free()


func _test_objective_flow() -> void:
	var objective := ObjectiveManager.new()
	root.add_child(objective)
	_expect(not objective.exit_active, "Exit began active")
	_expect(not objective.try_collect_fragment(true), "Fragment collected before learning the law")
	objective.on_world_state_changed(0, 2)
	_expect(
		objective.current_objective == ObjectiveManager.ObjectiveState.LEARN_LAW,
		"ANCHOR appeared before the complete four-state law was demonstrated"
	)
	objective.on_world_state_changed(2, 3)
	_expect(
		objective.current_objective == ObjectiveManager.ObjectiveState.DISCOVER_ANCHOR,
		"Reaching State 3 did not reveal ANCHOR"
	)
	objective.on_anchor_acquired()
	objective.on_anchor_applied(null, 2)
	_expect(
		objective.current_objective == ObjectiveManager.ObjectiveState.ANCHOR_TARGET,
		"Wrong-state anchoring advanced the puzzle"
	)
	objective.on_anchor_applied(null, 1)
	_expect(not objective.try_collect_fragment(false), "Fragment ignored invalid alignment")
	_expect(objective.try_collect_fragment(true), "Valid Fragment collection failed")
	_expect(not objective.try_collect_fragment(true), "Fragment collected twice")
	_expect(objective.fragment_collected, "Fragment collection was not recorded")
	_expect(not objective.exit_active, "Fragment bypassed the reusable ANCHOR route")
	_expect(objective.on_route_opened(), "A valid preserved boundary relation did not open the route")
	_expect(not objective.on_route_opened(), "The route opened twice")
	_expect(objective.on_route_traversed(), "Traversing the opened route did not activate the Exit")
	_expect(not objective.on_route_traversed(), "The route was traversed twice")
	_expect(objective.try_complete_run(), "Active Exit did not complete the run")
	_expect(not objective.try_complete_run(), "Run completed twice")
	objective.reset()
	_expect(
		objective.current_objective == ObjectiveManager.ObjectiveState.LEARN_LAW,
		"Objective reset did not restore initial state"
	)
	_expect(
		not objective.fragment_collected
		and not objective.route_opened
		and not objective.route_traversed
		and not objective.exit_active,
		"Objective reset retained completion flags"
	)
	objective.free()


func _test_complete_spatial_solution() -> void:
	var arena := TestArena.new()
	var director := TransformationDirector.new()
	var world_state := WorldStateController.new()
	var operator := OperatorSystem.new()
	var objective := ObjectiveManager.new()
	var interaction := InteractionController.new()
	var player := PlayerController.new()
	var puzzle := AnchorPuzzleController.new()
	root.add_child(arena)
	root.add_child(director)
	root.add_child(world_state)
	root.add_child(operator)
	root.add_child(objective)
	root.add_child(interaction)
	root.add_child(puzzle)

	puzzle.configure(arena, director, world_state, operator, objective, player, interaction)
	director.configure(arena)
	world_state.world_state_changed.connect(director.transition_to_state)
	operator.anchor_resolution_changed.connect(director.refresh_current_state)
	director.apply_state_immediately(0)

	var base_position: Vector3 = puzzle.anchor_target.get_meta("base_position")
	var base_scale: Vector3 = puzzle.anchor_target.get_meta("base_scale")
	var normal_mid := _find_normal_mid_target(arena, puzzle.anchor_target)

	# No unmodified world state can stabilize the Fragment.
	for normal_state in [0, 1, 2, 3]:
		world_state.set_state(normal_state)
		director.apply_state_immediately(normal_state)
		puzzle._process(0.0)
		_expect(not puzzle.fragment_collectible, "Normal State %d exposed the Fragment" % normal_state)

	# Reaching State 3 first completes the invariant lesson and reveals ANCHOR.
	world_state.set_state(3)
	director.apply_state_immediately(3)
	puzzle._process(0.0)
	_expect(puzzle.anchor_pickup.available, "Completing the four-state lesson did not reveal ANCHOR")
	_expect(
		puzzle.anchor_pickup.get_node("AnchorRevealRings").visible,
		"ANCHOR reveal lacked geometric feedback"
	)

	# Normal State 2 leaves the gate and receiver visibly misaligned.
	world_state.set_state(2)
	director.apply_state_immediately(2)
	puzzle._process(0.0)
	_expect(puzzle.alignment_error > 0.9, "Normal State 2 progression accidentally aligned the puzzle")
	_expect(not puzzle.fragment_collectible, "Fragment became reachable without ANCHOR")
	var normal_mid_state_two_position := normal_mid.position

	_expect(puzzle.anchor_pickup.interact(puzzle), "ANCHOR pickup interaction failed")
	_expect(operator.anchor_acquired, "Pickup did not grant ANCHOR")
	_expect(
		puzzle.anchor_target.get_node("EligibleRelationRing").visible,
		"Eligible ANCHOR target lacked a distinct relation marker"
	)

	# Retreat to State 1, preserve the gate's relation, then advance to State 2.
	world_state.set_state(1)
	await _advance_director(director, director.transition_duration)
	var normal_mid_state_one_position := normal_mid.position
	_expect(puzzle.anchor_target.interact(puzzle), "Eligible gate rejected ANCHOR")
	await _advance_director(director, director.transition_duration)
	var anchored_position := puzzle.anchor_target.position
	var anchored_scale := puzzle.anchor_target.scale
	_expect(
		puzzle.anchor_target.get_node("AnchorInvariantRings").visible,
		"Applied ANCHOR lacked its invariant marker"
	)
	world_state.set_state(2)
	_expect(puzzle.resistance_feedback_active, "Anchored gate did not signal resistance")
	var relation_echo := puzzle.get_node("UnanchoredRelationEcho") as Node3D
	_expect(relation_echo.visible, "The gate's normal State-2 relation was not visualized")
	_expect(
		relation_echo.position.is_equal_approx(director.get_target_position_for_state(puzzle.anchor_target, 2)),
		"Resistance echo did not show the deterministic unanchored target"
	)
	_expect(
		not arena.get_transformable_nodes().has(relation_echo),
		"Presentation-only resistance echo entered spatial target resolution"
	)
	_expect(
		relation_echo.find_children("*", "CollisionObject3D", true, false).is_empty(),
		"Presentation-only resistance echo introduced gameplay collision"
	)
	await _advance_director(director, director.transition_duration)
	puzzle._process(0.0)
	_expect(puzzle.anchor_target.position.is_equal_approx(anchored_position), "Anchored gate followed State 2 position")
	_expect(puzzle.anchor_target.scale.is_equal_approx(anchored_scale), "Anchored gate followed State 2 scale")
	_expect(not normal_mid.position.is_equal_approx(normal_mid_state_one_position), "Normal mid landmark ignored State 2")
	_expect(normal_mid.position.is_equal_approx(normal_mid_state_two_position), "Normal mid landmark did not restore State 2")
	_expect(puzzle.alignment_error <= AnchorPuzzleController.ALIGNMENT_TOLERANCE, "Cross-state relation did not align")
	_expect(puzzle.fragment_collectible, "Intended ANCHOR sequence did not expose the Fragment")
	_expect(
		puzzle.fragment.get_node("StabilizedRelationRings").visible,
		"Valid cross-state alignment lacked stabilization feedback"
	)

	# Forward, backward, and rapid reversal keep the exception stable.
	for state in [3, 2, 1, 0, 1, 2]:
		world_state.set_state(state)
		await _advance_director(director, director.transition_duration)
		_expect(puzzle.anchor_target.position.is_equal_approx(anchored_position), "Anchored position drifted across traversal")
		_expect(puzzle.anchor_target.scale.is_equal_approx(anchored_scale), "Anchored scale drifted across traversal")
	world_state.set_state(3)
	await _advance_director(director, 0.2)
	world_state.set_state(2)
	await _advance_director(director, director.transition_duration)
	_expect(puzzle.anchor_target.position.is_equal_approx(anchored_position), "Rapid reversal corrupted ANCHOR")
	puzzle._process(0.0)

	_expect(puzzle.try_collect_fragment(), "Aligned Fragment could not be collected")
	_expect(not puzzle.try_collect_fragment(), "Fragment could be collected twice")
	_expect(not objective.exit_active and not puzzle.puzzle_exit.active, "Fragment bypassed the route puzzle")
	_expect(objective.on_route_opened(), "Route opening was rejected after Fragment collection")
	_expect(objective.on_route_traversed(), "Route traversal did not unlock the Exit")
	_expect(objective.exit_active and puzzle.puzzle_exit.active, "Route traversal did not unlock the Exit")
	_expect(
		puzzle.puzzle_exit.get_node("ExitActivationBeacon").visible,
		"Active Exit lacked a spatially visible beacon"
	)
	_expect(puzzle.puzzle_exit.interact(puzzle), "Active Exit did not complete the run")
	_expect(objective.current_objective == ObjectiveManager.ObjectiveState.RUN_COMPLETE, "Run did not complete")
	_expect(not player.input_enabled and not interaction.enabled, "Completion did not freeze gameplay input")

	# Neither anchoring nor traversal may rewrite immutable bases.
	_expect(puzzle.anchor_target.get_meta("base_position") == base_position, "ANCHOR mutated base_position")
	_expect(puzzle.anchor_target.get_meta("base_scale") == base_scale, "ANCHOR mutated base_scale")
	_expect(normal_mid.position.is_equal_approx(normal_mid_state_two_position), "Normal mid layer stopped resolving normally")

	operator.reset()
	objective.reset()
	_expect(not operator.anchor_acquired and not operator.is_anchor_active(), "Restart reset retained ANCHOR")
	_expect(not objective.fragment_collected and not objective.exit_active, "Restart reset retained puzzle completion")
	puzzle.free()
	director.free()
	arena.free()
	world_state.free()
	operator.free()
	objective.free()
	interaction.free()
	player.free()


func _advance_director(_director: TransformationDirector, delta: float) -> void:
	await create_timer(delta + 0.05).timeout


func _find_normal_mid_target(arena: TestArena, excluded: Node3D) -> Node3D:
	for node in arena.get_transformable_nodes():
		if node != excluded and String(node.get_meta("zeno_layer", "")) == "mid":
			return node
	return null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
