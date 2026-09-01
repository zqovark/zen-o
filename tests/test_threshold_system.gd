extends SceneTree

var _failures: Array[String] = []
var _entered: Array[int] = []
var _exited: Array[int] = []


func _initialize() -> void:
	_run_tests.call_deferred()


func _run_tests() -> void:
	var system := ZenoThresholdSystem.new()
	root.add_child(system)
	system.set_physics_process(false)
	system.threshold_entered.connect(func(index: int) -> void: _entered.append(index))
	system.threshold_exited.connect(func(index: int) -> void: _exited.append(index))

	_test_forward_boundaries(system)
	_test_reverse_boundaries(system)
	_test_hysteresis(system)
	_test_rapid_reversal(system)
	_test_world_state_authority()
	_test_transformation_determinism()
	_test_arena_composition()

	if _failures.is_empty():
		print("PASS: thresholds, state authority, arena composition, reversal, and drift")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _test_forward_boundaries(system: ZenoThresholdSystem) -> void:
	system.reset()
	_entered.clear()
	_exited.clear()
	system.sample_distance(13.99)
	_expect(system.current_threshold == 0, "Threshold 1 fired below its boundary")
	system.sample_distance(14.0)
	_expect(system.current_threshold == 1, "Threshold 1 did not fire at 50%")
	system.sample_distance(14.1)
	_expect(_entered == [1], "Threshold 1 fired more than once")
	system.sample_distance(21.0)
	system.sample_distance(24.5)
	_expect(_entered == [1, 2, 3], "Forward thresholds were not emitted in order")


func _test_reverse_boundaries(system: ZenoThresholdSystem) -> void:
	system.sample_distance(24.49)
	_expect(_exited.is_empty(), "Threshold 3 ignored reverse hysteresis")
	system.sample_distance(24.2)
	system.sample_distance(20.7)
	system.sample_distance(13.7)
	_expect(_exited == [3, 2, 1], "Reverse thresholds were not emitted in order")
	_expect(system.current_threshold == 0, "Reverse traversal did not restore state 0")


func _test_hysteresis(system: ZenoThresholdSystem) -> void:
	system.reset()
	_entered.clear()
	_exited.clear()
	for distance in [13.99, 14.0, 13.99, 14.01, 13.98, 14.02]:
		system.sample_distance(distance)
	_expect(_entered == [1], "Oscillation near threshold duplicated entry")
	_expect(_exited.is_empty(), "Oscillation inside hysteresis caused an exit")


func _test_rapid_reversal(system: ZenoThresholdSystem) -> void:
	system.reset()
	_entered.clear()
	_exited.clear()
	system.sample_distance(25.0)
	system.sample_distance(0.0)
	_expect(_entered == [1, 2, 3], "A rapid outward crossing skipped a state")
	_expect(_exited == [3, 2, 1], "A rapid inward crossing skipped a state")
	_expect(system.current_threshold == 0, "Rapid reversal corrupted current threshold")


func _test_world_state_authority() -> void:
	var controller := WorldStateController.new()
	root.add_child(controller)
	controller.on_threshold_entered(1)
	controller.on_threshold_entered(2)
	controller.on_threshold_entered(3)
	_expect(controller.current_state == 3, "World state did not follow forward thresholds")
	controller.on_threshold_exited(3)
	controller.on_threshold_exited(2)
	controller.on_threshold_exited(1)
	_expect(controller.current_state == 0, "World state did not follow reverse thresholds")
	_expect(controller.previous_state == 1, "World state lost its previous state")


func _test_transformation_determinism() -> void:
	var arena := TestArena.new()
	root.add_child(arena)
	var director := TransformationDirector.new()
	root.add_child(director)
	director.configure(arena)
	var transformable_nodes := arena.get_transformable_nodes()
	var expected_states: Array[Dictionary] = []
	for state in 4:
		director.apply_state_immediately(state)
		var positions: Array[Vector3] = []
		var scales: Array[Vector3] = []
		for node in transformable_nodes:
			positions.append(node.position)
			scales.append(node.scale)
		expected_states.append({"positions": positions, "scales": scales})
	var base_positions: Array[Vector3] = []
	base_positions.assign(expected_states[0]["positions"])

	for _cycle_index in 5:
		for state in [1, 2, 3, 2, 1, 0]:
			director.apply_state_immediately(state)
			var expected: Dictionary = expected_states[state]
			for index in transformable_nodes.size():
				_expect(
					transformable_nodes[index].position.is_equal_approx(expected["positions"][index]),
					"Repeated traversal accumulated position drift in state %d" % state
				)
				_expect(
					transformable_nodes[index].scale.is_equal_approx(expected["scales"][index]),
					"Repeated traversal accumulated scale drift in state %d" % state
				)

	# Reversing an incomplete interpolation must begin from the rendered pose.
	director.transition_to_state(0, 3)
	director._physics_process(0.2)
	var position_before_reversal := transformable_nodes[0].position
	director.transition_to_state(3, 0)
	_expect(
		transformable_nodes[0].position.is_equal_approx(position_before_reversal),
		"Rapid reversal introduced a transform jump"
	)
	director._physics_process(director.transition_duration)
	_expect(
		transformable_nodes[0].position.is_equal_approx(base_positions[0]),
		"Rapid reversal did not resolve to the exact base pose"
	)

	# Target previews must never alter live presentation or collision roots.
	var preview := SpatialStatePreview.new()
	root.add_child(preview)
	preview.configure(arena, director)
	var position_before_preview := transformable_nodes[0].position
	preview.cycle_preview()
	preview.cycle_preview()
	_expect(
		transformable_nodes[0].position.is_equal_approx(position_before_preview),
		"Debug state preview mutated runtime geometry"
	)


func _test_arena_composition() -> void:
	var arena := TestArena.new()
	root.add_child(arena)
	var near_count := 0
	var mid_count := 0
	var outer_count := 0
	for node in arena.get_transformable_nodes():
		match String(node.get_meta("zeno_layer", "")):
			"near":
				near_count += 1
				var base_position: Vector3 = node.get_meta("base_position")
				_expect(
					minf(absf(base_position.x), absf(base_position.z)) > 5.0,
					"A growing near cluster obstructs a cardinal travel lane"
				)
			"mid":
				mid_count += 1
			"outer":
				outer_count += 1
				var has_visible_wall := false
				var has_wall_collision := false
				var wall_collision: CollisionShape3D
				for child in node.get_children():
					has_visible_wall = has_visible_wall or child is MeshInstance3D
					has_wall_collision = has_wall_collision or child is CollisionShape3D
					if child is CollisionShape3D:
						wall_collision = child
				_expect(
					has_visible_wall and has_wall_collision,
					"Outer boundary presentation and collision do not share a root"
				)
				if is_instance_valid(wall_collision):
					var collision_box := wall_collision.shape as BoxShape3D
					var found_matching_mesh := false
					for child in node.get_children():
						if child is MeshInstance3D and child.mesh is BoxMesh:
							var mesh_box := child.mesh as BoxMesh
							if (
								child.position.is_equal_approx(wall_collision.position)
								and mesh_box.size.is_equal_approx(collision_box.size)
							):
								found_matching_mesh = true
					_expect(found_matching_mesh, "Outer wall mesh and collision are misaligned")
	_expect(near_count == 4, "Near layer does not contain four readable clusters")
	_expect(mid_count == 12, "Mid layer does not contain twelve repeated gates")
	_expect(outer_count == arena.boundary_segments, "Outer wall segment count is incomplete")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
