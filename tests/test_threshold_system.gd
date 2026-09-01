extends SceneTree

var _failures: Array[String] = []
var _entered: Array[int] = []
var _exited: Array[int] = []


func _initialize() -> void:
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

	if _failures.is_empty():
		print("PASS: ZenoThresholdSystem boundaries, reversal, and hysteresis")
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
	director.apply_state_immediately(3)
	var transformable_nodes := arena.get_transformable_nodes()
	var expected_positions: Array[Vector3] = []
	var expected_scales: Array[Vector3] = []
	for node in transformable_nodes:
		expected_positions.append(node.position)
		expected_scales.append(node.scale)

	director.apply_state_immediately(0)
	director.apply_state_immediately(2)
	director.apply_state_immediately(3)
	for index in transformable_nodes.size():
		_expect(
			transformable_nodes[index].position.is_equal_approx(expected_positions[index]),
			"State reconstruction accumulated position drift"
		)
		_expect(
			transformable_nodes[index].scale.is_equal_approx(expected_scales[index]),
			"State reconstruction accumulated scale drift"
		)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
