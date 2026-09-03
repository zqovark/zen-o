class_name AnchorPuzzleController
extends Node3D

const PUZZLE_ANGLE := deg_to_rad(22.5)
const GATE_BASE_RADIUS := 17.0
const RECEIVER_BASE_RADIUS := 15.158333
const ALIGNMENT_TOLERANCE := 0.12
const RESISTANCE_FEEDBACK_DURATION := 2.2

var alignment_error: float = INF
var fragment_collectible: bool = false
var resistance_feedback_active: bool = false

var anchor_target: AnchorableSpatialTarget
var receiver_root: Node3D
var anchor_pickup: AnchorPickup
var fragment: PuzzleFragment
var puzzle_exit: PuzzleExit

var _arena: TestArena
var _director: TransformationDirector
var _world_state: WorldStateController
var _operator_system: OperatorSystem
var _objective_manager: ObjectiveManager
var _player: PlayerController
var _interaction_controller: InteractionController
var _audio: PuzzleAudio
var _completion_label: Label
var _resistance_ghost: Node3D
var _resistance_trace: MeshInstance3D
var _resistance_material: StandardMaterial3D
var _resistance_feedback_elapsed: float = 0.0
var _configured: bool = false


func configure(
	arena: TestArena,
	director: TransformationDirector,
	world_state: WorldStateController,
	operator_system: OperatorSystem,
	objective_manager: ObjectiveManager,
	player: PlayerController,
	interaction_controller: InteractionController
) -> void:
	if _configured:
		return
	_configured = true
	_arena = arena
	_director = director
	_world_state = world_state
	_operator_system = operator_system
	_objective_manager = objective_manager
	_player = player
	_interaction_controller = interaction_controller

	_audio = PuzzleAudio.new()
	_audio.name = "PuzzleAudio"
	add_child(_audio)
	_build_puzzle_geometry()
	_create_completion_overlay()
	_connect_events()


func _process(delta: float) -> void:
	if not _configured or not is_instance_valid(anchor_target) or not is_instance_valid(receiver_root):
		return
	_update_resistance_feedback(delta)
	var offset := anchor_target.global_position - receiver_root.global_position
	offset.y = 0.0
	alignment_error = offset.length()
	fragment_collectible = (
		_world_state.current_state == 2
		and _operator_system.active_anchor == anchor_target
		and _operator_system.anchored_state == 1
		and alignment_error <= ALIGNMENT_TOLERANCE
		and not _director.transition_active
		and not _objective_manager.fragment_collected
		and _objective_manager.current_objective == ObjectiveManager.ObjectiveState.REACH_FRAGMENT
	)
	fragment.set_collectible(fragment_collectible)


func try_collect_fragment() -> bool:
	return _objective_manager.try_collect_fragment(fragment_collectible)


func try_complete_run() -> bool:
	return _objective_manager.try_complete_run()


func _connect_events() -> void:
	_world_state.world_state_changed.connect(_objective_manager.on_world_state_changed)
	_world_state.world_state_changed.connect(_on_world_state_changed)
	_operator_system.anchor_applied.connect(_on_anchor_applied)
	_objective_manager.anchor_pickup_revealed.connect(_on_anchor_pickup_revealed)
	_objective_manager.fragment_collected_signal.connect(_on_fragment_collected)
	_objective_manager.exit_activated_signal.connect(_on_exit_activated)
	_objective_manager.run_completed.connect(_on_run_completed)


func _on_world_state_changed(_previous: int, current: int) -> void:
	if _operator_system.is_anchor_active():
		if current != _operator_system.anchored_state:
			_audio.play_cue("anchor_resist")
			if _operator_system.active_anchor == anchor_target:
				_show_resistance_feedback(current)
			else:
				_hide_resistance_feedback()
		else:
			_hide_resistance_feedback()


func _on_anchor_pickup_revealed() -> void:
	anchor_pickup.set_available()
	_audio.play_cue("anchor_revealed")


func _on_anchor_applied(target: AnchorableSpatialTarget, state: int) -> void:
	_objective_manager.on_anchor_applied(target, state)
	_audio.play_cue("anchor_applied")


func _on_fragment_collected() -> void:
	fragment.collect()
	_audio.play_cue("fragment")


func _on_exit_activated() -> void:
	puzzle_exit.set_active(true)
	_audio.play_cue("exit")


func _on_run_completed() -> void:
	_player.set_input_enabled(false)
	_interaction_controller.enabled = false
	_completion_label.visible = true
	_audio.play_cue("complete")


func _build_puzzle_geometry() -> void:
	var target_normal := _make_material(Color(0.19, 0.22, 0.27), Color(0.0, 0.0, 0.0))
	var target_eligible := _make_material(Color(0.24, 0.78, 0.72), Color(0.06, 0.42, 0.36), 1.4)
	var target_anchored := _make_material(Color(0.96, 0.68, 0.2), Color(0.72, 0.34, 0.04), 2.0)
	var receiver_material := _make_material(Color(0.47, 0.3, 0.7), Color(0.16, 0.06, 0.35), 1.0)
	var resistance_material := _make_material(Color(0.7, 0.86, 1.0, 0.24), Color(0.2, 0.5, 0.8), 1.5)
	resistance_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	resistance_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var dormant_material := _make_material(Color(0.12, 0.13, 0.17), Color(0.0, 0.0, 0.0))
	var anchor_material := _make_material(Color(0.92, 0.76, 0.28), Color(0.7, 0.38, 0.04), 2.2)
	var fragment_material := _make_material(Color(0.32, 0.12, 0.38), Color(0.08, 0.01, 0.12), 0.6)
	var fragment_active := _make_material(Color(0.95, 0.38, 0.88), Color(0.7, 0.08, 0.58), 2.4)
	var exit_active := _make_material(Color(0.42, 0.96, 0.58), Color(0.08, 0.72, 0.28), 2.2)

	_build_anchor_target(target_normal, target_eligible, target_anchored)
	_build_resistance_feedback(resistance_material)
	_build_receiver(receiver_material, fragment_material, fragment_active)
	_build_anchor_pickup(dormant_material, anchor_material)
	_build_exit(dormant_material, exit_active)


func _build_anchor_target(normal: Material, eligible: Material, anchored: Material) -> void:
	anchor_target = AnchorableSpatialTarget.new()
	anchor_target.name = "AnchorableStateGate"
	anchor_target.target_id = "STATE_GATE"
	anchor_target.position = _radial_position(GATE_BASE_RADIUS)
	anchor_target.rotation.y = PUZZLE_ANGLE
	add_child(anchor_target)

	for side in [-1.0, 1.0]:
		var visual := _add_box_mesh(
			anchor_target,
			Vector3(0.58, 3.8, 0.72),
			Vector3(side * 1.55, 1.9, 0.0),
			normal
		)
		anchor_target.register_visual(visual)
		_add_box_collision(
			anchor_target,
			Vector3(0.58, 3.8, 0.72),
			Vector3(side * 1.55, 1.9, 0.0)
		)
	var lintel := _add_box_mesh(
		anchor_target,
		Vector3(3.68, 0.42, 0.72),
		Vector3(0.0, 3.8, 0.0),
		normal
	)
	anchor_target.register_visual(lintel)

	var eligible_indicator := Node3D.new()
	eligible_indicator.name = "EligibleRelationRing"
	eligible_indicator.position.y = 1.9
	eligible_indicator.rotation.x = PI * 0.5
	eligible_indicator.visible = false
	anchor_target.add_child(eligible_indicator)
	var eligible_torus := TorusMesh.new()
	eligible_torus.inner_radius = 1.98
	eligible_torus.outer_radius = 2.06
	eligible_torus.rings = 32
	eligible_torus.ring_segments = 10
	eligible_torus.material = eligible
	_add_mesh(eligible_indicator, eligible_torus, Vector3.ZERO)

	var indicator := Node3D.new()
	indicator.name = "AnchorInvariantRings"
	indicator.position.y = 1.9
	indicator.rotation.x = PI * 0.5
	indicator.visible = false
	anchor_target.add_child(indicator)
	var torus := TorusMesh.new()
	torus.inner_radius = 1.75
	torus.outer_radius = 1.88
	torus.rings = 32
	torus.ring_segments = 12
	torus.material = anchored
	_add_mesh(indicator, torus, Vector3.ZERO)
	var outer_torus := TorusMesh.new()
	outer_torus.inner_radius = 2.02
	outer_torus.outer_radius = 2.1
	outer_torus.rings = 32
	outer_torus.ring_segments = 10
	outer_torus.material = anchored
	_add_mesh(indicator, outer_torus, Vector3.ZERO)

	anchor_target.configure(_operator_system, _world_state)
	anchor_target.configure_presentation(normal, eligible, anchored, eligible_indicator, indicator)
	_arena.register_transformable(anchor_target, "mid")


func _build_resistance_feedback(material: StandardMaterial3D) -> void:
	_resistance_material = material
	_resistance_ghost = Node3D.new()
	_resistance_ghost.name = "UnanchoredRelationEcho"
	_resistance_ghost.visible = false
	add_child(_resistance_ghost)
	for side in [-1.0, 1.0]:
		_add_box_mesh(
			_resistance_ghost,
			Vector3(0.58, 3.8, 0.72),
			Vector3(side * 1.55, 1.9, 0.0),
			material
		)
	_add_box_mesh(
		_resistance_ghost,
		Vector3(3.68, 0.42, 0.72),
		Vector3(0.0, 3.8, 0.0),
		material
	)

	var trace_mesh := BoxMesh.new()
	trace_mesh.size = Vector3(0.055, 0.055, 1.0)
	trace_mesh.material = material
	_resistance_trace = _add_mesh(self, trace_mesh, Vector3.ZERO)
	_resistance_trace.name = "PreservedRelationTrace"
	_resistance_trace.visible = false


func _build_receiver(
	receiver_material: Material,
	fragment_material: Material,
	fragment_active: Material
) -> void:
	receiver_root = Node3D.new()
	receiver_root.name = "StateTwoReceiver"
	receiver_root.position = _radial_position(RECEIVER_BASE_RADIUS)
	receiver_root.rotation.y = PUZZLE_ANGLE
	add_child(receiver_root)

	var torus := TorusMesh.new()
	torus.inner_radius = 1.12
	torus.outer_radius = 1.3
	torus.rings = 32
	torus.ring_segments = 12
	torus.material = receiver_material
	var receiver_ring := _add_mesh(receiver_root, torus, Vector3(0.0, 1.9, 0.0))
	receiver_ring.rotation.x = PI * 0.5
	for side in [-1.0, 1.0]:
		_add_box_mesh(
			receiver_root,
			Vector3(0.22, 4.6, 0.22),
			Vector3(side * 2.15, 2.3, 0.0),
			receiver_material
		)

	fragment = PuzzleFragment.new()
	fragment.name = "Fragment"
	fragment.position = Vector3(0.0, 1.9, 0.0)
	receiver_root.add_child(fragment)
	var fragment_mesh := SphereMesh.new()
	fragment_mesh.radius = 0.42
	fragment_mesh.height = 0.84
	fragment_mesh.radial_segments = 20
	fragment_mesh.rings = 12
	fragment_mesh.material = fragment_material
	var fragment_visual := _add_mesh(fragment, fragment_mesh, Vector3.ZERO)
	var fragment_collision := CollisionShape3D.new()
	var fragment_shape := SphereShape3D.new()
	fragment_shape.radius = 0.5
	fragment_collision.shape = fragment_shape
	fragment.add_child(fragment_collision)
	fragment.configure(self, fragment_visual, fragment_collision, fragment_material, fragment_active)
	var stability_indicator := Node3D.new()
	stability_indicator.name = "StabilizedRelationRings"
	stability_indicator.visible = false
	fragment.add_child(stability_indicator)
	for rotation_axis in [Vector3.ZERO, Vector3(PI * 0.5, 0.0, 0.0)]:
		var stability_torus := TorusMesh.new()
		stability_torus.inner_radius = 0.64
		stability_torus.outer_radius = 0.71
		stability_torus.rings = 24
		stability_torus.ring_segments = 8
		stability_torus.material = fragment_active
		var ring := _add_mesh(stability_indicator, stability_torus, Vector3.ZERO)
		ring.rotation = rotation_axis
	fragment.configure_feedback(stability_indicator)
	_arena.register_transformable(receiver_root, "outer")


func _build_anchor_pickup(dormant: Material, available: Material) -> void:
	anchor_pickup = AnchorPickup.new()
	anchor_pickup.name = "AnchorAcquisition"
	anchor_pickup.position = _radial_position(-6.5) + Vector3(0.0, 1.15, 0.0)
	add_child(anchor_pickup)
	var pickup_mesh := SphereMesh.new()
	pickup_mesh.radius = 0.62
	pickup_mesh.height = 1.24
	pickup_mesh.radial_segments = 8
	pickup_mesh.rings = 6
	pickup_mesh.material = dormant
	var pickup_visual := _add_mesh(anchor_pickup, pickup_mesh, Vector3.ZERO)
	var pickup_collision := CollisionShape3D.new()
	var pickup_shape := SphereShape3D.new()
	pickup_shape.radius = 0.78
	pickup_collision.shape = pickup_shape
	anchor_pickup.add_child(pickup_collision)
	anchor_pickup.configure(
		_operator_system,
		_objective_manager,
		_audio,
		pickup_visual,
		pickup_collision,
		dormant,
		available
	)
	var reveal_indicator := Node3D.new()
	reveal_indicator.name = "AnchorRevealRings"
	reveal_indicator.visible = false
	anchor_pickup.add_child(reveal_indicator)
	for ring_rotation in [Vector3.ZERO, Vector3(PI * 0.5, 0.0, 0.0)]:
		var reveal_torus := TorusMesh.new()
		reveal_torus.inner_radius = 0.92
		reveal_torus.outer_radius = 1.0
		reveal_torus.rings = 24
		reveal_torus.ring_segments = 8
		reveal_torus.material = available
		var reveal_ring := _add_mesh(reveal_indicator, reveal_torus, Vector3.ZERO)
		reveal_ring.rotation = ring_rotation
	var reveal_beam := CylinderMesh.new()
	reveal_beam.top_radius = 0.045
	reveal_beam.bottom_radius = 0.045
	reveal_beam.height = 5.2
	reveal_beam.radial_segments = 10
	reveal_beam.material = available
	_add_mesh(reveal_indicator, reveal_beam, Vector3(0.0, 2.1, 0.0))
	var reveal_light := OmniLight3D.new()
	reveal_light.name = "AnchorRevealLight"
	reveal_light.light_color = Color(1.0, 0.72, 0.24)
	reveal_light.omni_range = 7.0
	reveal_light.shadow_enabled = false
	reveal_light.light_energy = 0.0
	anchor_pickup.add_child(reveal_light)
	anchor_pickup.configure_feedback(reveal_indicator, reveal_light)


func _build_exit(dormant: Material, active: Material) -> void:
	puzzle_exit = PuzzleExit.new()
	puzzle_exit.name = "Exit"
	puzzle_exit.position = Vector3(-3.2, 1.5, 0.0)
	puzzle_exit.rotation.z = PI * 0.5
	add_child(puzzle_exit)
	var exit_torus := TorusMesh.new()
	exit_torus.inner_radius = 0.86
	exit_torus.outer_radius = 1.04
	exit_torus.rings = 32
	exit_torus.ring_segments = 12
	exit_torus.material = dormant
	var exit_visual := _add_mesh(puzzle_exit, exit_torus, Vector3.ZERO)
	exit_visual.rotation.x = PI * 0.5
	puzzle_exit.register_visual(exit_visual)
	var exit_collision := CollisionShape3D.new()
	var exit_shape := SphereShape3D.new()
	exit_shape.radius = 0.75
	exit_collision.shape = exit_shape
	puzzle_exit.add_child(exit_collision)
	puzzle_exit.configure(self, dormant, active)
	puzzle_exit.register_collision(exit_collision)
	var activation_root := Node3D.new()
	activation_root.name = "ExitActivationBeacon"
	activation_root.rotation.z = -puzzle_exit.rotation.z
	activation_root.visible = false
	puzzle_exit.add_child(activation_root)
	var beacon_mesh := CylinderMesh.new()
	beacon_mesh.top_radius = 0.07
	beacon_mesh.bottom_radius = 0.07
	beacon_mesh.height = 7.0
	beacon_mesh.radial_segments = 12
	beacon_mesh.material = active
	_add_mesh(activation_root, beacon_mesh, Vector3(0.0, 3.1, 0.0))
	for height in [1.2, 3.2, 5.2]:
		var beacon_torus := TorusMesh.new()
		beacon_torus.inner_radius = 0.48
		beacon_torus.outer_radius = 0.55
		beacon_torus.rings = 24
		beacon_torus.ring_segments = 8
		beacon_torus.material = active
		_add_mesh(activation_root, beacon_torus, Vector3(0.0, height, 0.0))
	var activation_light := OmniLight3D.new()
	activation_light.name = "ExitActivationLight"
	activation_light.position.y = 1.4
	activation_light.light_color = Color(0.42, 1.0, 0.58)
	activation_light.omni_range = 8.0
	activation_light.shadow_enabled = false
	activation_light.light_energy = 0.0
	activation_root.add_child(activation_light)
	puzzle_exit.configure_feedback(activation_root, activation_light)


func _show_resistance_feedback(world_state: int) -> void:
	if not is_instance_valid(anchor_target) or world_state == anchor_target.anchored_state:
		_hide_resistance_feedback()
		return
	var expected_position := _director.get_target_position_for_state(anchor_target, world_state)
	var expected_scale := _director.get_target_scale_for_state(anchor_target, world_state)
	_resistance_ghost.position = expected_position
	_resistance_ghost.rotation = anchor_target.rotation
	_resistance_ghost.scale = expected_scale

	var actual_marker := anchor_target.position + Vector3(0.0, 1.9 * anchor_target.scale.y, 0.0)
	var expected_marker := expected_position + Vector3(0.0, 1.9 * expected_scale.y, 0.0)
	var marker_distance := actual_marker.distance_to(expected_marker)
	_resistance_trace.position = (actual_marker + expected_marker) * 0.5
	_resistance_trace.scale = Vector3(1.0, 1.0, marker_distance)
	_resistance_trace.look_at(to_global(expected_marker), Vector3.UP)
	_resistance_ghost.visible = true
	_resistance_trace.visible = marker_distance > 0.02
	resistance_feedback_active = true
	_resistance_feedback_elapsed = 0.0
	_set_resistance_feedback_alpha(0.26)


func _update_resistance_feedback(delta: float) -> void:
	if not resistance_feedback_active:
		return
	_resistance_feedback_elapsed += delta
	var fade_progress := clampf(
		(_resistance_feedback_elapsed - 1.15) / (RESISTANCE_FEEDBACK_DURATION - 1.15),
		0.0,
		1.0
	)
	_set_resistance_feedback_alpha(lerpf(0.26, 0.0, fade_progress))
	if _resistance_feedback_elapsed >= RESISTANCE_FEEDBACK_DURATION:
		_hide_resistance_feedback()


func _hide_resistance_feedback() -> void:
	resistance_feedback_active = false
	if is_instance_valid(_resistance_ghost):
		_resistance_ghost.visible = false
	if is_instance_valid(_resistance_trace):
		_resistance_trace.visible = false


func _set_resistance_feedback_alpha(alpha: float) -> void:
	if not is_instance_valid(_resistance_material):
		return
	var color := _resistance_material.albedo_color
	color.a = alpha
	_resistance_material.albedo_color = color


func _create_completion_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	_completion_label = Label.new()
	_completion_label.text = "RUN COMPLETE\nR  —  RESTART"
	_completion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_completion_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_completion_label.set_anchors_preset(Control.PRESET_CENTER)
	_completion_label.position = Vector2(-180.0, -55.0)
	_completion_label.size = Vector2(360.0, 110.0)
	_completion_label.add_theme_color_override("font_color", Color(0.72, 1.0, 0.82))
	_completion_label.add_theme_color_override("font_outline_color", Color(0.01, 0.025, 0.02))
	_completion_label.add_theme_constant_override("outline_size", 8)
	_completion_label.add_theme_font_size_override("font_size", 26)
	_completion_label.visible = false
	layer.add_child(_completion_label)


func _radial_position(radius: float) -> Vector3:
	return Vector3(sin(PUZZLE_ANGLE) * radius, 0.0, cos(PUZZLE_ANGLE) * radius)


func _add_box_mesh(
	parent: Node3D,
	size: Vector3,
	local_position: Vector3,
	material: Material
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	return _add_mesh(parent, mesh, local_position)


func _add_box_collision(parent: Node3D, size: Vector3, local_position: Vector3) -> void:
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.position = local_position
	collision.shape = shape
	parent.add_child(collision)


func _add_mesh(parent: Node3D, mesh: Mesh, local_position: Vector3) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = local_position
	parent.add_child(instance)
	return instance


func _make_material(
	albedo: Color,
	emission: Color,
	emission_energy: float = 0.0
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.48
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material
