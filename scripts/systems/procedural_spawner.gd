extends Node
class_name ProceduralSpawner

@export var fragment_a_slots: Array[NodePath]
@export var fragment_b_slots: Array[NodePath]

func place_interactable(interactable: Node3D, slot_paths: Array[NodePath]) -> void:
	if slot_paths.is_empty():
		return
	var slot_path := slot_paths[randi() % slot_paths.size()]
	var slot := get_node_or_null(slot_path) as Node3D
	if slot == null:
		return
	interactable.global_position = slot.global_position
