class_name AnchorPickup
extends Area3D

var available: bool = false

var _operator_system: OperatorSystem
var _objective_manager: ObjectiveManager
var _audio: PuzzleAudio
var _visual: MeshInstance3D
var _collision: CollisionShape3D
var _dormant_material: Material
var _available_material: Material


func configure(
	operator_system: OperatorSystem,
	objective_manager: ObjectiveManager,
	audio: PuzzleAudio,
	visual: MeshInstance3D,
	collision: CollisionShape3D,
	dormant_material: Material,
	available_material: Material
) -> void:
	_operator_system = operator_system
	_objective_manager = objective_manager
	_audio = audio
	_visual = visual
	_collision = collision
	_dormant_material = dormant_material
	_available_material = available_material
	_refresh_presentation()


func set_available(next_available: bool = true) -> void:
	available = next_available
	_refresh_presentation()


func interact(_actor: Node) -> bool:
	if not available or not is_instance_valid(_operator_system):
		return false
	if not _operator_system.acquire_anchor():
		return false
	_objective_manager.on_anchor_acquired()
	_audio.play_cue("anchor_acquired")
	visible = false
	available = false
	if is_instance_valid(_collision):
		_collision.disabled = true
	return true


func interaction_label() -> String:
	return "ACQUIRE ANCHOR" if available else "DORMANT"


func _refresh_presentation() -> void:
	if is_instance_valid(_visual):
		_visual.material_override = _available_material if available else _dormant_material

