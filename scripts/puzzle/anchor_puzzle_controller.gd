class_name AnchorPuzzleController
extends Node3D

const PUZZLE_ANGLE := deg_to_rad(22.5)
const GATE_BASE_RADIUS := 17.0
const RECEIVER_BASE_RADIUS := 14.875
const ALIGNMENT_TOLERANCE := 0.12

var alignment_error: float = INF
var fragment_collectible: bool = false

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


func _process(_delta: float) -> void:
	if not _configured or not is_instance_valid(anchor_target) or not is_instance_valid(receiver_root):
		return
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
	_objective_manager.anchor_pickup_revealed.connect(anchor_pickup.set_available)
	_objective_manager.fragment_collected_signal.connect(_on_fragment_collected)
	_objective_manager.exit_activated_signal.connect(_on_exit_activated)
	_objective_manager.run_completed.connect(_on_run_completed)


func _on_world_state_changed(_previous: int, _current: int) -> void:
	if _operator_system.is_anchor_active():
		_audio.play_cue("anchor_resist")


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
	var dormant_material := _make_material(Color(0.12, 0.13, 0.17), Color(0.0, 0.0, 0.0))
	var anchor_material := _make_material(Color(0.92, 0.76, 0.28), Color(0.7, 0.38, 0.04), 2.2)
	var fragment_material := _make_material(Color(0.32, 0.12, 0.38), Color(0.08, 0.01, 0.12), 0.6)
	var fragment_active := _make_material(Color(0.95, 0.38, 0.88), Color(0.7, 0.08, 0.58), 2.4)
	var exit_active := _make_material(Color(0.42, 0.96, 0.58), Color(0.08, 0.72, 0.28), 2.2)

	_build_anchor_target(target_normal, target_eligible, target_anchored)
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

	var indicator := Node3D.new()
	indicator.name = "AnchorInvariantRing"
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

	anchor_target.configure(_operator_system, _world_state)
	anchor_target.configure_presentation(normal, eligible, anchored, indicator)
	_arena.register_transformable(anchor_target, "mid")


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
	_arena.register_transformable(receiver_root, "outer")


func _build_anchor_pickup(dormant: Material, available: Material) -> void:
	anchor_pickup = AnchorPickup.new()
	anchor_pickup.name = "AnchorAcquisition"
	anchor_pickup.position = Vector3(0.0, 1.15, -6.5)
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
	exit_shape.radius = 1.15
	exit_collision.shape = exit_shape
	puzzle_exit.add_child(exit_collision)
	puzzle_exit.configure(self, dormant, active)


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
