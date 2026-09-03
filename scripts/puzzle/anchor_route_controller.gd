class_name AnchorRouteController
extends Node3D

const CANDIDATE_SEGMENTS: Array[int] = [21, 27, 33]
const CORRECT_CANDIDATE_INDEX := 1
const REQUIRED_WORLD_STATE := 3
const SHUTTER_DEPTH := 3.2
const HANDLE_INWARD_OFFSET := 6.5
const MIN_PASSAGE_CLEARANCE := 1.0
const POCKET_OUTER_RADIUS := 37.75
const ROUTE_CROSSING_RADIUS := 36.35
const ROUTE_ANGLE_TOLERANCE := deg_to_rad(4.6)
const FEEDBACK_DURATION := 2.2

var route_unlocked: bool = false
var route_open: bool = false
var route_crossed: bool = false
var radial_clearance: float = 0.0
var shutters: Array[AnchorableSpatialTarget] = []
var correct_shutter: AnchorableSpatialTarget

var _arena: TestArena
var _director: TransformationDirector
var _world_state: WorldStateController
var _operator_system: OperatorSystem
var _objective_manager: ObjectiveManager
var _player: PlayerController
var _puzzle_exit: PuzzleExit
var _correct_angle: float = 0.0
var _hidden_boundary_segment: AnimatableBody3D
var _relation_echo: Node3D
var _relation_trace: MeshInstance3D
var _echo_material: StandardMaterial3D
var _feedback_elapsed: float = 0.0
var _feedback_active: bool = false
var _configured: bool = false


func configure(
	arena: TestArena,
	director: TransformationDirector,
	world_state: WorldStateController,
	operator_system: OperatorSystem,
	objective_manager: ObjectiveManager,
	player: PlayerController,
	puzzle_exit: PuzzleExit
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
	_puzzle_exit = puzzle_exit
	_build_route()
	_connect_events()


func _process(delta: float) -> void:
	if not _configured:
		return
	_update_relation_feedback(delta)
	_evaluate_route()


func _connect_events() -> void:
	_objective_manager.fragment_collected_signal.connect(_unlock_route)
	_world_state.world_state_changed.connect(_on_world_state_changed)


func _unlock_route() -> void:
	if route_unlocked:
		return
	route_unlocked = true
	for shutter in shutters:
		shutter.set_anchor_eligible(true)


func _evaluate_route() -> void:
	if not is_instance_valid(correct_shutter) or not is_instance_valid(_hidden_boundary_segment):
		return
	radial_clearance = _calculate_radial_clearance()
	var next_open := (
		route_unlocked
		and _operator_system.active_anchor == correct_shutter
		and _world_state.current_state == REQUIRED_WORLD_STATE
		and not _director.transition_active
		and radial_clearance >= MIN_PASSAGE_CLEARANCE
	)
	route_open = next_open
	if route_open and not _objective_manager.route_opened:
		_objective_manager.on_route_opened()
	if route_open and not route_crossed and _player_has_crossed_route():
		route_crossed = true
		_objective_manager.on_route_traversed()


func _calculate_radial_clearance() -> float:
	var gap_radius := _flat_radius(_hidden_boundary_segment.global_position)
	var shutter_radius := _flat_radius(correct_shutter.global_position)
	var gap_inner_edge := gap_radius - 0.36 * _hidden_boundary_segment.scale.z
	var shutter_outer_edge := shutter_radius + SHUTTER_DEPTH * 0.5 * correct_shutter.scale.z
	return gap_inner_edge - shutter_outer_edge


func _player_has_crossed_route() -> bool:
	var flat_position := Vector3(_player.global_position.x, 0.0, _player.global_position.z)
	if flat_position.length() < ROUTE_CROSSING_RADIUS:
		return false
	var player_angle := atan2(flat_position.x, flat_position.z)
	return absf(wrapf(player_angle - _correct_angle, -PI, PI)) <= ROUTE_ANGLE_TOLERANCE


func _on_world_state_changed(_previous: int, current: int) -> void:
	var active_target := _operator_system.active_anchor
	if (
		is_instance_valid(active_target)
		and shutters.has(active_target)
		and current != active_target.anchored_state
	):
		_show_relation_feedback(active_target, current)
	else:
		_hide_relation_feedback()


func _build_route() -> void:
	var normal_material := _make_material(Color(0.48, 0.5, 0.61), Color.BLACK)
	var eligible_material := _make_material(Color(0.2, 0.72, 0.72), Color(0.04, 0.34, 0.34), 1.25)
	var anchored_material := _make_material(Color(0.96, 0.68, 0.2), Color(0.72, 0.34, 0.04), 2.0)
	var pocket_material := _make_material(Color(0.3, 0.32, 0.4), Color.BLACK)
	var clue_material := _make_material(Color(0.18, 0.28, 0.23), Color(0.02, 0.07, 0.04), 0.35)
	var notch_material := _make_material(Color(0.76, 0.58, 0.24), Color(0.22, 0.11, 0.02), 0.55)
	_echo_material = _make_material(Color(0.7, 0.86, 1.0, 0.24), Color(0.2, 0.5, 0.8), 1.5)
	_echo_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_echo_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	for candidate_index in CANDIDATE_SEGMENTS.size():
		var segment_index := CANDIDATE_SEGMENTS[candidate_index]
		var angle := TAU * float(segment_index) / float(_arena.boundary_segments)
		var boundary_segment := _arena.get_boundary_segment(segment_index)
		_arena.set_boundary_segment_enabled(segment_index, false)
		var shutter := _build_shutter(
			candidate_index,
			angle,
			normal_material,
			eligible_material,
			anchored_material
		)
		shutters.append(shutter)
		_build_capture_notch(angle, notch_material)
		_build_pocket(angle, candidate_index == CORRECT_CANDIDATE_INDEX, pocket_material, clue_material)
		if candidate_index == CORRECT_CANDIDATE_INDEX:
			correct_shutter = shutter
			_correct_angle = angle
			_hidden_boundary_segment = boundary_segment

	_build_relation_feedback()
	_place_exit()


func _build_shutter(
	candidate_index: int,
	angle: float,
	normal: Material,
	eligible: Material,
	anchored: Material
) -> AnchorableSpatialTarget:
	var shutter := AnchorableSpatialTarget.new()
	shutter.name = "BoundaryShutter%02d" % candidate_index
	shutter.target_id = "BOUNDARY_SHUTTER_%02d" % candidate_index
	shutter.position = _radial_position(_arena.base_boundary_radius, angle)
	shutter.rotation.y = angle
	add_child(shutter)

	var width := _arena.get_boundary_segment_width()
	var door := _add_box_mesh(
		shutter,
		Vector3(width, 2.8, SHUTTER_DEPTH),
		Vector3(0.0, 1.4, 0.0),
		normal
	)
	shutter.register_visual(door)
	_add_box_collision(
		shutter,
		Vector3(width, 2.8, SHUTTER_DEPTH),
		Vector3(0.0, 1.4, 0.0)
	)

	for side in [-1.0, 1.0]:
		var rail := _add_box_mesh(
			shutter,
			Vector3(0.12, 0.12, HANDLE_INWARD_OFFSET),
			Vector3(side * 1.12, 2.5, -HANDLE_INWARD_OFFSET * 0.5),
			normal
		)
		shutter.register_visual(rail)
	var handle := _add_box_mesh(
		shutter,
		Vector3(0.72, 2.6, 0.72),
		Vector3(0.0, 1.3, -HANDLE_INWARD_OFFSET),
		normal
	)
	shutter.register_visual(handle)
	_add_box_collision(
		shutter,
		Vector3(0.82, 2.8, 0.82),
		Vector3(0.0, 1.4, -HANDLE_INWARD_OFFSET)
	)

	var eligible_indicator := _build_indicator(
		shutter,
		"EligibleRelationRing",
		eligible,
		1.02,
		1.1
	)
	var anchored_indicator := _build_indicator(
		shutter,
		"AnchorInvariantRings",
		anchored,
		0.88,
		1.02
	)
	var second_ring := TorusMesh.new()
	second_ring.inner_radius = 1.14
	second_ring.outer_radius = 1.21
	second_ring.rings = 24
	second_ring.ring_segments = 8
	second_ring.material = anchored
	_add_mesh(anchored_indicator, second_ring, Vector3.ZERO)

	shutter.configure(_operator_system, _world_state)
	shutter.configure_presentation(
		normal,
		eligible,
		anchored,
		eligible_indicator,
		anchored_indicator
	)
	shutter.set_anchor_eligible(false)
	_arena.register_transformable(shutter, "outer")
	return shutter


func _build_indicator(
	parent: Node3D,
	indicator_name: String,
	material: Material,
	inner_radius: float,
	outer_radius: float
) -> Node3D:
	var indicator := Node3D.new()
	indicator.name = indicator_name
	indicator.position = Vector3(0.0, 1.3, -HANDLE_INWARD_OFFSET)
	indicator.rotation.x = PI * 0.5
	indicator.visible = false
	parent.add_child(indicator)
	var torus := TorusMesh.new()
	torus.inner_radius = inner_radius
	torus.outer_radius = outer_radius
	torus.rings = 24
	torus.ring_segments = 8
	torus.material = material
	_add_mesh(indicator, torus, Vector3.ZERO)
	return indicator


func _build_capture_notch(angle: float, material: Material) -> void:
	var state_one_radius := _arena.base_boundary_radius * 1.12
	var notch_root := Node3D.new()
	notch_root.name = "StateOneCaptureNotch"
	notch_root.position = _radial_position(state_one_radius, angle)
	notch_root.rotation.y = angle
	add_child(notch_root)
	for side in [-1.0, 1.0]:
		_add_box_mesh(
			notch_root,
			Vector3(0.12, 0.035, 1.15),
			Vector3(side * 2.18, 0.035, 0.0),
			material
		)


func _build_pocket(angle: float, is_destination: bool, material: Material, clue: Material) -> void:
	var state_three_radius := _arena.base_boundary_radius * 1.28
	var inner_radius := state_three_radius - 0.8
	var pocket_depth := POCKET_OUTER_RADIUS - inner_radius
	var pocket_center := (POCKET_OUTER_RADIUS + inner_radius) * 0.5
	var state_three_width := _arena.get_boundary_segment_width() * 1.16
	var half_width := state_three_width * 0.5 + 0.18
	var pocket := StaticBody3D.new()
	pocket.name = "RoutePocket"
	pocket.position = _radial_position(pocket_center, angle)
	pocket.rotation.y = angle
	add_child(pocket)
	for side in [-1.0, 1.0]:
		_add_box(
			pocket,
			Vector3(0.3, 3.2, pocket_depth + 0.5),
			Vector3(side * half_width, 1.6, 0.0),
			material
		)
	_add_box(
		pocket,
		Vector3(state_three_width + 0.65, 3.2, 0.3),
		Vector3(0.0, 1.6, POCKET_OUTER_RADIUS - pocket_center),
		material
	)
	if is_destination:
		var destination := Node3D.new()
		destination.name = "DestinationSilhouette"
		destination.position = Vector3(0.0, 1.55, POCKET_OUTER_RADIUS - pocket_center - 0.2)
		destination.rotation.x = PI * 0.5
		pocket.add_child(destination)
		for radius in [0.72, 1.02, 1.32]:
			var ring := TorusMesh.new()
			ring.inner_radius = radius
			ring.outer_radius = radius + 0.055
			ring.rings = 24
			ring.ring_segments = 8
			ring.material = clue
			_add_mesh(destination, ring, Vector3.ZERO)


func _build_relation_feedback() -> void:
	_relation_echo = Node3D.new()
	_relation_echo.name = "BoundaryRelationEcho"
	_relation_echo.visible = false
	add_child(_relation_echo)
	var echo_box := BoxMesh.new()
	echo_box.size = Vector3(_arena.get_boundary_segment_width(), 2.8, SHUTTER_DEPTH)
	echo_box.material = _echo_material
	_add_mesh(_relation_echo, echo_box, Vector3(0.0, 1.4, 0.0))

	var trace_mesh := BoxMesh.new()
	trace_mesh.size = Vector3(0.055, 0.055, 1.0)
	trace_mesh.material = _echo_material
	_relation_trace = _add_mesh(self, trace_mesh, Vector3.ZERO)
	_relation_trace.name = "BoundaryPreservedRelationTrace"
	_relation_trace.visible = false


func _show_relation_feedback(target: AnchorableSpatialTarget, world_state: int) -> void:
	var expected_position := _director.get_target_position_for_state(target, world_state)
	var expected_scale := _director.get_target_scale_for_state(target, world_state)
	_relation_echo.position = expected_position
	_relation_echo.rotation = target.rotation
	_relation_echo.scale = expected_scale
	var actual_marker := target.position + Vector3(0.0, 1.4 * target.scale.y, 0.0)
	var expected_marker := expected_position + Vector3(0.0, 1.4 * expected_scale.y, 0.0)
	var distance := actual_marker.distance_to(expected_marker)
	_relation_trace.position = (actual_marker + expected_marker) * 0.5
	_relation_trace.scale = Vector3(1.0, 1.0, distance)
	if distance > 0.02:
		_relation_trace.look_at(to_global(expected_marker), Vector3.UP)
	_relation_echo.visible = true
	_relation_trace.visible = distance > 0.02
	_feedback_elapsed = 0.0
	_feedback_active = true
	_set_echo_alpha(0.26)


func _update_relation_feedback(delta: float) -> void:
	if not _feedback_active:
		return
	_feedback_elapsed += delta
	var fade := clampf((_feedback_elapsed - 1.15) / (FEEDBACK_DURATION - 1.15), 0.0, 1.0)
	_set_echo_alpha(lerpf(0.26, 0.0, fade))
	if _feedback_elapsed >= FEEDBACK_DURATION:
		_hide_relation_feedback()


func _hide_relation_feedback() -> void:
	_feedback_active = false
	if is_instance_valid(_relation_echo):
		_relation_echo.visible = false
	if is_instance_valid(_relation_trace):
		_relation_trace.visible = false


func _set_echo_alpha(alpha: float) -> void:
	var color := _echo_material.albedo_color
	color.a = alpha
	_echo_material.albedo_color = color


func _place_exit() -> void:
	_puzzle_exit.global_position = _radial_position(POCKET_OUTER_RADIUS - 0.4, _correct_angle) + Vector3(0.0, 1.5, 0.0)


func _radial_position(radius: float, angle: float) -> Vector3:
	return Vector3(sin(angle) * radius, 0.0, cos(angle) * radius)


func _flat_radius(position: Vector3) -> float:
	return Vector2(position.x, position.z).length()


func _add_box(
	parent: Node3D,
	size: Vector3,
	local_position: Vector3,
	material: Material
) -> void:
	_add_box_mesh(parent, size, local_position, material)
	_add_box_collision(parent, size, local_position)


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
	material.roughness = 0.5
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material
