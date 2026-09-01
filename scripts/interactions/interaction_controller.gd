class_name InteractionController
extends Node

@export_range(1.0, 10.0, 0.1) var interaction_distance: float = 4.5

var enabled: bool = true
var aimed_interactable: Node
var aimed_interaction: String = "NONE"

var _camera: Camera3D
var _actor: Node


func configure(camera: Camera3D, actor: Node) -> void:
	_camera = camera
	_actor = actor


func _physics_process(_delta: float) -> void:
	_update_aimed_interactable()


func _unhandled_input(event: InputEvent) -> void:
	if enabled and event.is_action_pressed("interact") and is_instance_valid(aimed_interactable):
		aimed_interactable.call("interact", _actor)
		get_viewport().set_input_as_handled()


func _update_aimed_interactable() -> void:
	aimed_interactable = null
	aimed_interaction = "NONE"
	if not enabled or not is_instance_valid(_camera) or not _camera.is_inside_tree():
		return
	var ray_origin := _camera.global_position
	var ray_end := ray_origin - _camera.global_basis.z * interaction_distance
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var hit := _camera.get_world_3d().direct_space_state.intersect_ray(query)
	var collider: Node = hit.get("collider")
	if is_instance_valid(collider) and collider.has_method("interact"):
		aimed_interactable = collider
		if collider.has_method("interaction_label"):
			aimed_interaction = collider.call("interaction_label")

