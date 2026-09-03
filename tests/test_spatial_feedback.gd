extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	_run_test.call_deferred()


func _run_test() -> void:
	var camera := Camera3D.new()
	var world_state := WorldStateController.new()
	var feedback := SpatialFeedbackController.new()
	camera.fov = 72.0
	root.add_child(camera)
	root.add_child(world_state)
	root.add_child(feedback)
	feedback.configure(
		camera,
		world_state,
		PackedFloat32Array([0.5, 0.75, 0.875]),
		28.0
	)

	_expect(feedback.get_child_count() == 4, "Spatial feedback did not create three seams and audio")
	for index in 3:
		var seam := feedback.get_node("SpatialSeam%d" % (index + 1)) as MeshInstance3D
		_expect(is_instance_valid(seam), "A threshold seam was missing")
		_expect(
			seam.find_children("*", "CollisionObject3D", true, false).is_empty(),
			"A presentation seam introduced collision"
		)

	world_state.set_state(1)
	_expect(feedback.cue_count == 1, "Forward threshold crossing produced no causal cue")
	_expect(feedback.last_cued_state == 1 and feedback.last_direction == 1, "Forward cue reported wrong state or direction")
	_expect(world_state.current_state == 1, "Presentation feedback mutated world state")
	await create_timer(0.75).timeout
	_expect(is_equal_approx(camera.fov, 72.0), "Threshold FOV response did not restore camera comfort")

	world_state.set_state(0)
	_expect(feedback.cue_count == 2, "Backward threshold crossing produced no causal cue")
	_expect(feedback.last_cued_state == 0 and feedback.last_direction == -1, "Backward cue reported wrong state or direction")
	_expect(world_state.current_state == 0, "Reverse feedback mutated world state")
	await create_timer(0.75).timeout

	feedback.queue_free()
	world_state.queue_free()
	camera.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PASS: visible threshold seams, directional cues, FOV recovery, and presentation isolation")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
