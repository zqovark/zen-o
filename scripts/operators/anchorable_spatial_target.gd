class_name AnchorableSpatialTarget
extends AnimatableBody3D

var target_id: String = "anchor_target"
var anchor_eligible: bool = true
var is_anchored: bool = false
var anchored_state: int = -1

var _operator_system: OperatorSystem
var _world_state: WorldStateController
var _visuals: Array[MeshInstance3D] = []
var _eligible_indicator: Node3D
var _anchor_indicator: Node3D
var _normal_material: Material
var _eligible_material: Material
var _anchored_material: Material
var _anchor_feedback_tween: Tween


func configure(operator_system: OperatorSystem, world_state: WorldStateController) -> void:
	_operator_system = operator_system
	_world_state = world_state
	_operator_system.anchor_acquired_changed.connect(_on_anchor_acquired_changed)
	_refresh_presentation()


func configure_presentation(
	normal_material: Material,
	eligible_material: Material,
	anchored_material: Material,
	eligible_indicator: Node3D,
	indicator: Node3D
) -> void:
	_normal_material = normal_material
	_eligible_material = eligible_material
	_anchored_material = anchored_material
	_eligible_indicator = eligible_indicator
	_anchor_indicator = indicator
	_refresh_presentation()


func register_visual(mesh_instance: MeshInstance3D) -> void:
	_visuals.append(mesh_instance)
	_refresh_presentation()


func interact(_actor: Node) -> bool:
	if not is_instance_valid(_operator_system) or not is_instance_valid(_world_state):
		return false
	return _operator_system.apply_anchor(self, _world_state.current_state)


func interaction_label() -> String:
	if not is_instance_valid(_operator_system) or not _operator_system.anchor_acquired:
		return "ANCHOR UNAVAILABLE"
	return "RE-ANCHOR" if is_anchored else "ANCHOR"


func apply_anchor(state: int) -> void:
	is_anchored = true
	anchored_state = state
	_refresh_presentation()
	_pulse_anchor_indicator()


func release_anchor() -> void:
	is_anchored = false
	anchored_state = -1
	_refresh_presentation()


func _on_anchor_acquired_changed(_acquired: bool) -> void:
	_refresh_presentation()


func _refresh_presentation() -> void:
	var material := _normal_material
	if is_anchored:
		material = _anchored_material
	elif is_instance_valid(_operator_system) and _operator_system.anchor_acquired:
		material = _eligible_material
	for visual in _visuals:
		if is_instance_valid(visual):
			visual.material_override = material
	if is_instance_valid(_eligible_indicator):
		_eligible_indicator.visible = (
			not is_anchored
			and is_instance_valid(_operator_system)
			and _operator_system.anchor_acquired
		)
	if is_instance_valid(_anchor_indicator):
		_anchor_indicator.visible = is_anchored


func _pulse_anchor_indicator() -> void:
	if not is_instance_valid(_anchor_indicator):
		return
	if is_instance_valid(_anchor_feedback_tween):
		_anchor_feedback_tween.kill()
	_anchor_indicator.scale = Vector3.ONE * 1.28
	_anchor_feedback_tween = create_tween()
	_anchor_feedback_tween.set_trans(Tween.TRANS_CUBIC)
	_anchor_feedback_tween.set_ease(Tween.EASE_OUT)
	_anchor_feedback_tween.tween_property(_anchor_indicator, "scale", Vector3.ONE, 0.32)
