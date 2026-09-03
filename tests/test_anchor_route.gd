extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	_run_test.call_deferred()


func _run_test() -> void:
	var arena := TestArena.new()
	var director := TransformationDirector.new()
	var world_state := WorldStateController.new()
	var operator := OperatorSystem.new()
	var objective := ObjectiveManager.new()
	var interaction := InteractionController.new()
	var player := load("res://scenes/player/player.tscn").instantiate() as PlayerController
	var puzzle := AnchorPuzzleController.new()
	var route := AnchorRouteController.new()
	root.add_child(arena)
	root.add_child(director)
	root.add_child(world_state)
	root.add_child(operator)
	root.add_child(objective)
	root.add_child(interaction)
	root.add_child(player)
	root.add_child(puzzle)
	root.add_child(route)

	puzzle.configure(arena, director, world_state, operator, objective, player, interaction)
	route.configure(arena, director, world_state, operator, objective, player, puzzle.puzzle_exit)
	director.configure(arena)
	world_state.world_state_changed.connect(director.transition_to_state)
	operator.anchor_resolution_changed.connect(director.refresh_current_state)
	director.apply_state_immediately(0)

	_expect(route.shutters.size() == 3, "Route did not provide multiple ANCHOR candidates")
	_expect(not route.route_unlocked, "Reusable route began unlocked")
	_expect(not objective.exit_active, "Exit began active")
	operator.acquire_anchor()
	for shutter in route.shutters:
		_expect(not shutter.anchor_eligible, "Boundary shutter became eligible before the Fragment")
		_expect(not shutter.can_interact(), "Locked boundary shutter advertised an interaction")
		_expect(not shutter.interact(player), "Locked boundary shutter accepted ANCHOR")

	objective.current_objective = ObjectiveManager.ObjectiveState.REACH_FRAGMENT
	_expect(objective.try_collect_fragment(true), "Test setup could not collect the first Fragment")
	_expect(route.route_unlocked, "Fragment did not reveal the reusable ANCHOR route")
	for shutter in route.shutters:
		_expect(shutter.anchor_eligible, "Fragment did not enable every route candidate")

	# The State-1 handle is reachable from just inside the reverse threshold;
	# its State-0 position is deliberately outside interaction range.
	world_state.set_state(1)
	director.apply_state_immediately(1)
	var state_one_handle := route.correct_shutter.to_global(
		Vector3(0.0, 1.4, -AnchorRouteController.HANDLE_INWARD_OFFSET)
	)
	var state_one_player_position := _radial_position(20.75, route.correct_shutter.rotation.y) + Vector3(0.0, 1.0, 0.0)
	_expect(
		state_one_handle.distance_to(state_one_player_position) <= interaction.interaction_distance,
		"Correct State-1 capture point is not physically interactable"
	)
	world_state.set_state(0)
	director.apply_state_immediately(0)
	var state_zero_handle := route.correct_shutter.to_global(
		Vector3(0.0, 1.4, -AnchorRouteController.HANDLE_INWARD_OFFSET)
	)
	var state_zero_player_position := _radial_position(13.99, route.correct_shutter.rotation.y) + Vector3(0.0, 1.0, 0.0)
	_expect(
		state_zero_handle.distance_to(state_zero_player_position) > interaction.interaction_distance,
		"State 0 accidentally allows the intended shutter capture"
	)

	# Preserving the wrong lane changes space but cannot create the destination route.
	world_state.set_state(1)
	director.apply_state_immediately(1)
	var wrong_shutter := route.shutters[0]
	_expect(operator.apply_anchor(wrong_shutter, 1), "Wrong route candidate could not be tested")
	world_state.set_state(3)
	director.apply_state_immediately(3)
	route._process(0.0)
	_expect(not route.route_open, "Wrong boundary shutter opened the destination route")
	_expect(not objective.route_opened, "Wrong boundary shutter advanced the objective")

	# Capturing the correct shutter too late leaves less than player clearance.
	world_state.set_state(2)
	director.apply_state_immediately(2)
	_expect(operator.apply_anchor(route.correct_shutter, 2), "Correct shutter rejected a wrong-state experiment")
	world_state.set_state(3)
	director.apply_state_immediately(3)
	route._process(0.0)
	_expect(route.radial_clearance < AnchorRouteController.MIN_PASSAGE_CLEARANCE, "State-2 capture unexpectedly cleared the wall")
	_expect(not route.route_open, "Late ANCHOR capture opened the route")

	# Retreat to State 1, preserve the correct relation, then cross two states.
	world_state.set_state(1)
	director.apply_state_immediately(1)
	_expect(operator.apply_anchor(route.correct_shutter, 1), "Correct State-1 shutter capture failed")
	director.apply_state_immediately(1)
	var anchored_position := route.correct_shutter.position
	var anchored_scale := route.correct_shutter.scale
	var base_position: Vector3 = route.correct_shutter.get_meta("base_position")
	var base_scale: Vector3 = route.correct_shutter.get_meta("base_scale")
	world_state.set_state(2)
	director.apply_state_immediately(2)
	_expect(not route.route_open, "Route opened before the second deliberate transition")
	world_state.set_state(3)
	_expect(route.get_node("BoundaryRelationEcho").visible, "Boundary shutter resistance lacked a relation echo")
	director.apply_state_immediately(3)
	route._process(0.0)
	_expect(route.correct_shutter.position.is_equal_approx(anchored_position), "Route ANCHOR did not preserve position")
	_expect(route.correct_shutter.scale.is_equal_approx(anchored_scale), "Route ANCHOR did not preserve scale")
	_expect(route.radial_clearance >= AnchorRouteController.MIN_PASSAGE_CLEARANCE, "State-1 relation did not create physical clearance")
	_expect(route.route_open and objective.route_opened, "Preserved relation did not open the route")
	_expect(objective.current_objective == ObjectiveManager.ObjectiveState.TRAVERSE_ROUTE, "Route opening did not advance the objective")

	# Reversal remains deterministic and does not mutate immutable targets.
	for state in [2, 1, 2, 3]:
		world_state.set_state(state)
		director.apply_state_immediately(state)
		route._process(0.0)
		_expect(route.correct_shutter.position.is_equal_approx(anchored_position), "Route shutter drifted during reversal")
		_expect(route.correct_shutter.scale.is_equal_approx(anchored_scale), "Route shutter scale drifted during reversal")
	_expect(route.correct_shutter.get_meta("base_position") == base_position, "Route feedback mutated base_position")
	_expect(route.correct_shutter.get_meta("base_scale") == base_scale, "Route feedback mutated base_scale")

	# Exit activation requires physically crossing the opened boundary pocket.
	_expect(not objective.exit_active and not puzzle.puzzle_exit.active, "Exit activated before route traversal")
	player.global_position = _radial_position(36.6, route.correct_shutter.rotation.y) + Vector3(0.0, 1.0, 0.0)
	route._process(0.0)
	_expect(route.route_crossed, "Crossing the opened boundary route was not detected")
	_expect(objective.exit_active and puzzle.puzzle_exit.active, "Route traversal did not activate the Exit")
	_expect(puzzle.puzzle_exit.interact(player), "Traversed route could not complete the run")
	_expect(objective.current_objective == ObjectiveManager.ObjectiveState.RUN_COMPLETE, "Extended run did not complete")

	await create_timer(0.55).timeout
	for node in [route, puzzle, interaction, objective, operator, world_state, director, arena, player]:
		if is_instance_valid(node):
			node.queue_free()
	await process_frame
	await process_frame
	if _failures.is_empty():
		print("PASS: reusable ANCHOR selection, capture timing, route clearance, reversal, and completion")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _radial_position(radius: float, angle: float) -> Vector3:
	return Vector3(sin(angle) * radius, 0.0, cos(angle) * radius)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
