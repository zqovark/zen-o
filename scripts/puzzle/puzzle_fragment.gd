class_name PuzzleFragment
extends Area3D

var collectible: bool = false
var collected: bool = false

var _controller: AnchorPuzzleController
var _visual: MeshInstance3D
var _collision: CollisionShape3D
var _dormant_material: Material
var _collectible_material: Material


func configure(
	controller: AnchorPuzzleController,
	visual: MeshInstance3D,
	collision: CollisionShape3D,
	dormant_material: Material,
	collectible_material: Material
) -> void:
	_controller = controller
	_visual = visual
	_collision = collision
	_dormant_material = dormant_material
	_collectible_material = collectible_material
	_refresh_presentation()


func set_collectible(next_collectible: bool) -> void:
	if collected:
		return
	collectible = next_collectible
	_refresh_presentation()


func collect() -> void:
	if collected:
		return
	collected = true
	collectible = false
	visible = false
	if is_instance_valid(_collision):
		_collision.disabled = true


func interact(_actor: Node) -> bool:
	if collected or not collectible or not is_instance_valid(_controller):
		return false
	return _controller.try_collect_fragment()


func interaction_label() -> String:
	return "COLLECT FRAGMENT" if collectible else "UNSTABLE FRAGMENT"


func _refresh_presentation() -> void:
	if is_instance_valid(_visual):
		_visual.material_override = _collectible_material if collectible else _dormant_material

