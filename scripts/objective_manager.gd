class_name ObjectiveManager
extends Node

signal objective_changed(previous: ObjectiveState, current: ObjectiveState)
signal anchor_pickup_revealed
signal fragment_collected_signal
signal exit_activated_signal
signal run_completed

enum ObjectiveState {
	LEARN_LAW,
	DISCOVER_ANCHOR,
	ANCHOR_TARGET,
	REACH_FRAGMENT,
	EXIT_UNLOCKED,
	REACH_EXIT,
	RUN_COMPLETE,
}

var current_objective: ObjectiveState = ObjectiveState.LEARN_LAW
var fragment_collected: bool = false
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
	_set_objective(ObjectiveState.EXIT_UNLOCKED)
	fragment_collected_signal.emit()
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
	exit_active = false


func _set_objective(next_objective: ObjectiveState) -> void:
	if next_objective == current_objective:
		return
	var previous := current_objective
	current_objective = next_objective
	objective_changed.emit(previous, current_objective)
