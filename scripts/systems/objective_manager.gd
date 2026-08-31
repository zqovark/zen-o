extends Node
class_name ObjectiveManager

signal objectives_updated
signal run_completed

var has_fragment_a: bool = false
var has_fragment_b: bool = false
var anchor_activated: bool = false
var exit_unlocked: bool = false

func collect_fragment(fragment_id: StringName) -> void:
	if fragment_id == &"fragment_a":
		has_fragment_a = true
	elif fragment_id == &"fragment_b":
		has_fragment_b = true
	objectives_updated.emit()
	_refresh_exit_lock()

func activate_anchor() -> void:
	anchor_activated = true
	objectives_updated.emit()
	_refresh_exit_lock()

func can_exit() -> bool:
	return exit_unlocked

func _refresh_exit_lock() -> void:
	exit_unlocked = has_fragment_a and has_fragment_b and anchor_activated

func complete_run() -> void:
	if exit_unlocked:
		run_completed.emit()
