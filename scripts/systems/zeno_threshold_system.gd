extends Node
class_name ZenoThresholdSystem

signal threshold_entered(index: int)
signal threshold_exited(index: int)
signal movement_direction_changed(direction: int)

@export var threshold_distances: PackedFloat32Array = [6.0, 10.0, 14.0]

var _current_index: int = 0
var _last_distance: float = 0.0
var _movement_direction: int = 0

func update_for_position(player_position: Vector3) -> void:
	var distance_to_center := Vector2(player_position.x, player_position.z).length()
	var new_index := 0
	for i in threshold_distances.size():
		if distance_to_center >= threshold_distances[i]:
			new_index = i + 1

	var direction := signf(distance_to_center - _last_distance)
	if int(direction) != _movement_direction and int(direction) != 0:
		_movement_direction = int(direction)
		movement_direction_changed.emit(_movement_direction)

	if new_index > _current_index:
		for i in range(_current_index + 1, new_index + 1):
			threshold_entered.emit(i)
	elif new_index < _current_index:
		for i in range(_current_index, new_index, -1):
			threshold_exited.emit(i)

	_current_index = new_index
	_last_distance = distance_to_center

func get_debug_data(player_position: Vector3) -> Dictionary:
	var distance_to_center := Vector2(player_position.x, player_position.z).length()
	var max_distance: float = threshold_distances[threshold_distances.size() - 1] if threshold_distances.size() > 0 else 1.0
	return {
		"threshold_index": _current_index,
		"distance_to_center": distance_to_center,
		"edge_progress": clampf(distance_to_center / max_distance, 0.0, 1.0),
		"movement_direction": _movement_direction
	}
