extends Node
class_name WorldStateController

signal world_state_changed(previous_state: int, current_state: int)

@export var max_state: int = 3

var state_index: int = 0
var previous_state: int = 0
var _pending_forward_boost: int = 0

func _ready() -> void:
	set_state(0)

func on_threshold_entered(_threshold_index: int) -> void:
	var delta := 1 + _pending_forward_boost
	_pending_forward_boost = 0
	set_state(min(max_state, state_index + delta))

func on_threshold_exited(_threshold_index: int) -> void:
	set_state(max(0, state_index - 1))

func queue_forward_state_boost(extra_steps: int) -> void:
	_pending_forward_boost = max(0, extra_steps)

func set_state(new_state: int) -> void:
	if new_state == state_index:
		return
	previous_state = state_index
	state_index = new_state
	world_state_changed.emit(previous_state, state_index)

func get_world_scale() -> float:
	return [1.0, 1.25, 1.6, 2.0][state_index]
