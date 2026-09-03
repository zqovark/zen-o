class_name ObjectiveManager
extends Node

signal objective_changed(previous: ObjectiveState, current: ObjectiveState)
signal anchor_pickup_revealed
signal fragment_collected_signal
signal route_opened_signal
signal exit_activated_signal
signal run_completed

enum ObjectiveState {
	LEARN_LAW,
	DISCOVER_ANCHOR,
	ANCHOR_TARGET,
	REACH_FRAGMENT,
	ANCHOR_ROUTE,
	TRAVERSE_ROUTE,
	REACH_EXIT,
	RUN_COMPLETE,
}

var current_objective: ObjectiveState = ObjectiveState.LEARN_LAW
var fragment_collected: bool = false
var route_opened: bool = false
var route_traversed: bool = false
var exit_active: bool = false


func on_world_state_changed(_previous: int, current: int) -> void:
	if current_objective == ObjectiveState.LEARN_LAW and current >= 3:
		_set_objective(ObjectiveState.DISCOVER_ANCHOR)
		anchor_pickup_revealed.emit()


func on_anchor_acquired() -> void:
	if current_objective <= ObjectiveState.DISCOVER_ANCHOR:
		_set_objective(ObjectiveState.ANCHOR_TARGET)


func on_anchor_applied(_target: AnchorableSpatialTarget, state: int) -> void:
	if fragment_collected:
		if not route_opened:
			_set_objective(ObjectiveState.ANCHOR_ROUTE)
		return
	if state == 1:
		_set_objective(ObjectiveState.REACH_FRAGMENT)
	else:
		_set_objective(ObjectiveState.ANCHOR_TARGET)


func try_collect_fragment(alignment_valid: bool) -> bool:
	if fragment_collected or not alignment_valid:
		return false
	if current_objective != ObjectiveState.REACH_FRAGMENT:
		return false
	fragment_collected = true
	_set_objective(ObjectiveState.ANCHOR_ROUTE)
	fragment_collected_signal.emit()
	return true


func on_route_opened() -> bool:
	if not fragment_collected or route_opened:
		return false
	route_opened = true
	_set_objective(ObjectiveState.TRAVERSE_ROUTE)
	route_opened_signal.emit()
	return true


func on_route_traversed() -> bool:
	if not route_opened or route_traversed:
		return false
	route_traversed = true
	exit_active = true
	exit_activated_signal.emit()
	_set_objective(ObjectiveState.REACH_EXIT)
	return true


func try_complete_run() -> bool:
	if not exit_active or current_objective == ObjectiveState.RUN_COMPLETE:
		return false
	_set_objective(ObjectiveState.RUN_COMPLETE)
	run_completed.emit()
	return true


func objective_label() -> String:
	return ObjectiveState.keys()[current_objective]


func reset() -> void:
	current_objective = ObjectiveState.LEARN_LAW
	fragment_collected = false
	route_opened = false
	route_traversed = false
	exit_active = false


func _set_objective(next_objective: ObjectiveState) -> void:
	if next_objective == current_objective:
		return
	var previous := current_objective
	current_objective = next_objective
	objective_changed.emit(previous, current_objective)
