extends Area3D
class_name StateInteractable

signal interacted(interactable: StateInteractable)

@export var interactable_id: StringName
@export var visible_states: PackedInt32Array = [0, 1, 2, 3]
@export var collectible_states: PackedInt32Array = [0, 1, 2, 3]
@export var one_shot: bool = true

var _consumed: bool = false

func apply_state(state_index: int) -> void:
	visible = not _consumed and visible_states.has(state_index)

func can_interact(state_index: int) -> bool:
	return not _consumed and collectible_states.has(state_index) and visible

func interact(state_index: int) -> void:
	if not can_interact(state_index):
		return
	interacted.emit(self)
	if one_shot:
		_consumed = true
		visible = false
