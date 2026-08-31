extends CharacterBody3D
class_name PlayerController

signal interaction_requested(target: Node)

@export var move_speed: float = 6.0
@export var acceleration: float = 12.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.0018

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		_camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -1.2, 1.2)
	elif event.is_action_pressed("ui_cancel"):
		var next_mode := Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
		Input.set_mouse_mode(next_mode)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move_dir := (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	var target_velocity := move_dir * move_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if Input.is_action_just_pressed("interact"):
		var target := _get_interaction_target()
		if target != null:
			interaction_requested.emit(target)

	move_and_slide()

func _get_interaction_target() -> Node:
	var from := _camera.global_position
	var to := from - _camera.global_transform.basis.z * 3.0
	var params := PhysicsRayQueryParameters3D.create(from, to)
	params.collide_with_areas = true
	params.collide_with_bodies = true
	var hit := get_world_3d().direct_space_state.intersect_ray(params)
	if hit.is_empty():
		return null
	return hit["collider"] as Node
