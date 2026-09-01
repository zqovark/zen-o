class_name OperatorSystem
extends Node

signal anchor_acquired_changed(acquired: bool)
signal anchor_applied(target: AnchorableSpatialTarget, state: int)
signal anchor_released(target: AnchorableSpatialTarget)
signal anchor_resolution_changed

var anchor_acquired: bool = false
var active_anchor: AnchorableSpatialTarget
var anchored_state: int = -1


func acquire_anchor() -> bool:
	if anchor_acquired:
		return false
	anchor_acquired = true
	anchor_acquired_changed.emit(true)
	return true


func apply_anchor(target: AnchorableSpatialTarget, state: int) -> bool:
	if not anchor_acquired or not is_instance_valid(target) or not target.anchor_eligible:
		return false
	if is_instance_valid(active_anchor) and active_anchor != target:
		var released_target := active_anchor
		released_target.release_anchor()
		anchor_released.emit(released_target)

	active_anchor = target
	anchored_state = state
	active_anchor.apply_anchor(state)
	anchor_resolution_changed.emit()
	anchor_applied.emit(active_anchor, anchored_state)
	return true


func clear_anchor() -> void:
	if is_instance_valid(active_anchor):
		var released_target := active_anchor
		released_target.release_anchor()
		anchor_released.emit(released_target)
	active_anchor = null
	anchored_state = -1
	anchor_resolution_changed.emit()


func is_anchor_active() -> bool:
	return is_instance_valid(active_anchor) and active_anchor.is_anchored


func anchored_target_label() -> String:
	return active_anchor.target_id if is_instance_valid(active_anchor) else "NONE"


func reset() -> void:
	clear_anchor()
	anchor_acquired = false
	anchor_acquired_changed.emit(false)

