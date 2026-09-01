class_name WorldStateController
extends Node

signal world_state_changed(previous: int, current: int)

@export_range(0, 16, 1) var maximum_state: int = 3

var current_state: int = 0
var previous_state: int = 0


func on_threshold_entered(index: int) -> void:
	set_state(index)


func on_threshold_exited(index: int) -> void:
	set_state(index - 1)


func set_state(next_state: int) -> void:
	next_state = clampi(next_state, 0, maximum_state)
	if next_state == current_state:
		return
	previous_state = current_state
	current_state = next_state
	world_state_changed.emit(previous_state, current_state)


func reset() -> void:
	set_state(0)

