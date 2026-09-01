class_name PuzzleExit
extends Area3D

var active: bool = false

var _controller: AnchorPuzzleController
var _visuals: Array[MeshInstance3D] = []
var _dormant_material: Material
var _active_material: Material


func configure(
	controller: AnchorPuzzleController,
	dormant_material: Material,
	active_material: Material
) -> void:
	_controller = controller
	_dormant_material = dormant_material
	_active_material = active_material
	_refresh_presentation()


func register_visual(visual: MeshInstance3D) -> void:
	_visuals.append(visual)
	_refresh_presentation()


func set_active(next_active: bool = true) -> void:
	active = next_active
	_refresh_presentation()


func interact(_actor: Node) -> bool:
	if not active or not is_instance_valid(_controller):
		return false
	return _controller.try_complete_run()


func interaction_label() -> String:
	return "COMPLETE RUN" if active else "EXIT INACTIVE"


func _refresh_presentation() -> void:
	var material := _active_material if active else _dormant_material
	for visual in _visuals:
		if is_instance_valid(visual):
			visual.material_override = material
