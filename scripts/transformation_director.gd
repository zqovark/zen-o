class_name TransformationDirector
extends Node

const STATE_PROFILES := [
	{
		"near_radius": 1.00,
		"near_scale": 1.00,
		"mid_radius": 1.00,
		"mid_scale": 1.00,
		"outer_radius": 1.00,
		"outer_scale": 1.00,
	},
	{
		"near_radius": 0.92,
		"near_scale": 1.25,
		"mid_radius": 1.07,
		"mid_scale": 0.86,
		"outer_radius": 1.12,
		"outer_scale": 1.05,
	},
	{
		"near_radius": 0.82,
		"near_scale": 1.52,
		"mid_radius": 1.16,
		"mid_scale": 0.70,
		"outer_radius": 1.20,
		"outer_scale": 1.10,
	},
	{
		"near_radius": 0.70,
		"near_scale": 1.88,
		"mid_radius": 1.28,
		"mid_scale": 0.54,
		"outer_radius": 1.28,
		"outer_scale": 1.16,
	},
]

@export_range(0.05, 3.0, 0.01) var transition_duration: float = 0.56

var transition_active: bool = false
var transition_progress: float = 1.0
var active_state: int = 0
var world_scale: float = 1.0
var near_radius_ratio: float = 1.0
var near_scale_ratio: float = 1.0
var mid_radius_ratio: float = 1.0
var mid_scale_ratio: float = 1.0
var outer_radius_ratio: float = 1.0
var outer_scale_ratio: float = 1.0
var arena: TestArena

var _elapsed: float = 0.0
var _nodes: Array[Node3D] = []
var _start_positions: Array[Vector3] = []
var _target_positions: Array[Vector3] = []
var _start_scales: Array[Vector3] = []
var _target_scales: Array[Vector3] = []


func configure(test_arena: TestArena) -> void:
	arena = test_arena


func get_state_count() -> int:
	return STATE_PROFILES.size()


func get_state_profile(state: int) -> Dictionary:
	var safe_state := clampi(state, 0, STATE_PROFILES.size() - 1)
	return STATE_PROFILES[safe_state].duplicate(true)


func get_target_position_for_state(node: Node3D, state: int) -> Vector3:
	return _target_position_for(node, get_state_profile(state))


func get_target_scale_for_state(node: Node3D, state: int) -> Vector3:
	return _target_scale_for(node, get_state_profile(state))


func refresh_current_state() -> void:
	if not is_instance_valid(arena):
		return
	_build_transition(STATE_PROFILES[active_state])
	_elapsed = 0.0
	transition_progress = 0.0
	transition_active = true


func transition_to_state(_previous: int, current: int) -> void:
	if not is_instance_valid(arena):
		return
	active_state = clampi(current, 0, STATE_PROFILES.size() - 1)
	_build_transition(STATE_PROFILES[active_state])
	_elapsed = 0.0
	transition_progress = 0.0
	transition_active = true


func apply_state_immediately(state: int) -> void:
	if not is_instance_valid(arena):
		return
	active_state = clampi(state, 0, STATE_PROFILES.size() - 1)
	var profile: Dictionary = STATE_PROFILES[active_state]
	for node in arena.get_transformable_nodes():
		node.position = _resolved_target_position(node, profile)
		node.scale = _resolved_target_scale(node, profile)
	_update_profile_metrics(profile)
	transition_progress = 1.0
	transition_active = false


func _physics_process(delta: float) -> void:
	if not transition_active:
		return
	_elapsed += delta
	var linear_weight := clampf(_elapsed / transition_duration, 0.0, 1.0)
	transition_progress = linear_weight
	# Quintic easing removes the visible acceleration corners of cubic smoothstep.
	var eased_weight := (
		linear_weight
		* linear_weight
		* linear_weight
		* (linear_weight * (linear_weight * 6.0 - 15.0) + 10.0)
	)
	for index in _nodes.size():
		_nodes[index].position = _start_positions[index].lerp(
			_target_positions[index], eased_weight
		)
		_nodes[index].scale = _start_scales[index].lerp(
			_target_scales[index], eased_weight
		)

	if linear_weight >= 1.0:
		transition_active = false


func _build_transition(profile: Dictionary) -> void:
	_nodes = arena.get_transformable_nodes()
	_start_positions.clear()
	_target_positions.clear()
	_start_scales.clear()
	_target_scales.clear()
	for node in _nodes:
		_start_positions.append(node.position)
		_target_positions.append(_resolved_target_position(node, profile))
		_start_scales.append(node.scale)
		_target_scales.append(_resolved_target_scale(node, profile))
	_update_profile_metrics(profile)


func _update_profile_metrics(profile: Dictionary) -> void:
	near_radius_ratio = float(profile["near_radius"])
	near_scale_ratio = float(profile["near_scale"])
	mid_radius_ratio = float(profile["mid_radius"])
	mid_scale_ratio = float(profile["mid_scale"])
	outer_radius_ratio = float(profile["outer_radius"])
	outer_scale_ratio = float(profile["outer_scale"])
	world_scale = outer_radius_ratio


func _target_position_for(node: Node3D, profile: Dictionary) -> Vector3:
	var base_position: Vector3 = node.get_meta("base_position", node.position)
	var layer: String = node.get_meta("zeno_layer", "mid")
	var radius_multiplier := float(profile.get(layer + "_radius", 1.0))
	return Vector3(
		base_position.x * radius_multiplier,
		base_position.y,
		base_position.z * radius_multiplier
	)


func _target_scale_for(node: Node3D, profile: Dictionary) -> Vector3:
	var base_scale: Vector3 = node.get_meta("base_scale", Vector3.ONE)
	var layer: String = node.get_meta("zeno_layer", "mid")
	return base_scale * float(profile.get(layer + "_scale", 1.0))


func _resolved_target_position(node: Node3D, world_profile: Dictionary) -> Vector3:
	return _target_position_for(node, _resolve_profile_for(node, world_profile))


func _resolved_target_scale(node: Node3D, world_profile: Dictionary) -> Vector3:
	return _target_scale_for(node, _resolve_profile_for(node, world_profile))


func _resolve_profile_for(node: Node3D, world_profile: Dictionary) -> Dictionary:
	if node is AnchorableSpatialTarget and node.is_anchored:
		return STATE_PROFILES[clampi(node.anchored_state, 0, STATE_PROFILES.size() - 1)]
	return world_profile
