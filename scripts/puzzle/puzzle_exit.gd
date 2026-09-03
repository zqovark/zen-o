class_name PuzzleExit
extends Area3D

var active: bool = false

var _controller: AnchorPuzzleController
var _visuals: Array[MeshInstance3D] = []
var _collision: CollisionShape3D
var _activation_root: Node3D
var _activation_light: OmniLight3D
var _dormant_material: Material
var _active_material: Material
var _activation_tween: Tween


func configure(
	controller: AnchorPuzzleController,
	dormant_material: Material,
	active_material: Material
) -> void:
	_controller = controller
	_dormant_material = dormant_material
	_active_material = active_material
	_refresh_presentation()


func configure_feedback(activation_root: Node3D, activation_light: OmniLight3D) -> void:
	_activation_root = activation_root
	_activation_light = activation_light
	_refresh_presentation()


func register_visual(visual: MeshInstance3D) -> void:
	_visuals.append(visual)
	_refresh_presentation()


func register_collision(collision: CollisionShape3D) -> void:
	_collision = collision
	_refresh_presentation()


func set_active(next_active: bool = true) -> void:
	var just_activated := next_active and not active
	active = next_active
	_refresh_presentation()
	if just_activated:
		_play_activation_feedback()


func interact(_actor: Node) -> bool:
	if not active or not is_instance_valid(_controller):
		return false
	return _controller.try_complete_run()


func interaction_label() -> String:
	return "COMPLETE RUN" if active else "EXIT INACTIVE"


func can_interact() -> bool:
	return active


func _refresh_presentation() -> void:
	var material := _active_material if active else _dormant_material
	for visual in _visuals:
		if is_instance_valid(visual):
			visual.material_override = material
	if is_instance_valid(_activation_root):
		_activation_root.visible = active
	if is_instance_valid(_activation_light):
		_activation_light.light_energy = 1.15 if active else 0.0
	if is_instance_valid(_collision):
		_collision.set_deferred("disabled", not active)


func _play_activation_feedback() -> void:
	if not is_instance_valid(_activation_root):
		return
	if is_instance_valid(_activation_tween):
		_activation_tween.kill()
	_activation_root.scale = Vector3(1.0, 0.04, 1.0)
	_activation_tween = create_tween()
	_activation_tween.set_trans(Tween.TRANS_CUBIC)
	_activation_tween.set_ease(Tween.EASE_OUT)
	_activation_tween.tween_property(_activation_root, "scale", Vector3.ONE, 0.55)
