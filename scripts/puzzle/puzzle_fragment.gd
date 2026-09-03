class_name PuzzleFragment
extends Area3D

var collectible: bool = false
var collected: bool = false

var _controller: AnchorPuzzleController
var _visual: MeshInstance3D
var _collision: CollisionShape3D
var _stability_indicator: Node3D
var _dormant_material: Material
var _collectible_material: Material
var _stability_tween: Tween


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


func configure_feedback(stability_indicator: Node3D) -> void:
	_stability_indicator = stability_indicator
	_refresh_presentation()


func set_collectible(next_collectible: bool) -> void:
	if collected:
		return
	var just_stabilized := next_collectible and not collectible
	collectible = next_collectible
	_refresh_presentation()
	if just_stabilized:
		_play_stability_feedback()


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
	if is_instance_valid(_stability_indicator):
		_stability_indicator.visible = collectible and not collected


func _play_stability_feedback() -> void:
	if not is_instance_valid(_stability_indicator):
		return
	if is_instance_valid(_stability_tween):
		_stability_tween.kill()
	_stability_indicator.scale = Vector3.ONE * 0.45
	_stability_tween = create_tween()
	_stability_tween.set_trans(Tween.TRANS_BACK)
	_stability_tween.set_ease(Tween.EASE_OUT)
	_stability_tween.tween_property(_stability_indicator, "scale", Vector3.ONE, 0.42)
