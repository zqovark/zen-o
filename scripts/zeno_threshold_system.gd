class_name ZenoThresholdSystem
extends Node

signal threshold_entered(index: int)
signal threshold_exited(index: int)
signal movement_direction_changed(direction: MovementDirection)

enum MovementDirection {
	TOWARD_CENTER = -1,
	STILL = 0,
	TOWARD_EDGE = 1,
}

@export var center: Vector3 = Vector3.ZERO
@export_range(1.0, 1000.0, 0.5) var conceptual_edge_radius: float = 28.0
@export var thresholds: PackedFloat32Array = PackedFloat32Array([0.5, 0.75, 0.875])
@export_range(0.0, 0.05, 0.0005) var exit_hysteresis: float = 0.008
@export_range(0.0, 1.0, 0.001) var direction_deadzone: float = 0.015

var current_threshold: int = 0
var previous_threshold: int = 0
var distance_to_center: float = 0.0
var normalized_edge_progress: float = 0.0
var movement_direction: MovementDirection = MovementDirection.STILL
var tracked_node: Node3D

var _has_previous_sample: bool = false
var _previous_distance: float = 0.0


func configure(node_to_track: Node3D, arena_center: Vector3 = Vector3.ZERO) -> void:
	tracked_node = node_to_track
	center = arena_center
	_has_previous_sample = false


func _physics_process(_delta: float) -> void:
	if is_instance_valid(tracked_node):
		var flat_offset := tracked_node.global_position - center
		flat_offset.y = 0.0
		sample_distance(flat_offset.length())


func sample_distance(new_distance: float) -> void:
	distance_to_center = maxf(new_distance, 0.0)
	normalized_edge_progress = clampf(distance_to_center / conceptual_edge_radius, 0.0, 1.0)
	_update_movement_direction()
	_update_thresholds()
	_previous_distance = distance_to_center
	_has_previous_sample = true


func movement_direction_label() -> String:
	match movement_direction:
		MovementDirection.TOWARD_CENTER:
			return "TOWARD CENTER"
		MovementDirection.TOWARD_EDGE:
			return "TOWARD EDGE"
		_:
			return "STILL"


func reset() -> void:
	current_threshold = 0
	previous_threshold = 0
	distance_to_center = 0.0
	normalized_edge_progress = 0.0
	movement_direction = MovementDirection.STILL
	_has_previous_sample = false


func _update_movement_direction() -> void:
	var next_direction := MovementDirection.STILL
	if _has_previous_sample:
		var distance_delta := distance_to_center - _previous_distance
		if distance_delta > direction_deadzone:
			next_direction = MovementDirection.TOWARD_EDGE
		elif distance_delta < -direction_deadzone:
			next_direction = MovementDirection.TOWARD_CENTER

	if next_direction != movement_direction:
		movement_direction = next_direction
		movement_direction_changed.emit(movement_direction)


func _update_thresholds() -> void:
	while (
		current_threshold < thresholds.size()
		and normalized_edge_progress >= thresholds[current_threshold]
	):
		previous_threshold = current_threshold
		current_threshold += 1
		threshold_entered.emit(current_threshold)

	while (
		current_threshold > 0
		and normalized_edge_progress
		<= thresholds[current_threshold - 1] - exit_hysteresis
	):
		var exited_threshold := current_threshold
		previous_threshold = current_threshold
		current_threshold -= 1
		threshold_exited.emit(exited_threshold)

