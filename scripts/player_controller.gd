class_name PlayerController
extends CharacterBody3D

@export_range(1.0, 15.0, 0.1) var movement_speed: float = 5.2
@export_range(1.0, 50.0, 0.5) var acceleration: float = 22.0
@export_range(1.0, 50.0, 0.5) var deceleration: float = 28.0
@export_range(0.0005, 0.01, 0.0001) var mouse_sensitivity: float = 0.0025
@export_range(45.0, 89.0, 1.0) var vertical_look_limit_degrees: float = 84.0
@export var gravity: float = 24.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var _mouse_captured: bool = true
var input_enabled: bool = true


func _ready() -> void:
	_capture_mouse(true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _mouse_captured and input_enabled:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotation.x = clampf(
			head.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(-vertical_look_limit_degrees),
			deg_to_rad(vertical_look_limit_degrees)
		)
	elif event is InputEventMouseButton and event.pressed and not _mouse_captured:
		_capture_mouse(true)
	elif event.is_action_pressed("ui_cancel"):
		_capture_mouse(not _mouse_captured)
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if input_enabled:
		input_vector = Input.get_vector(
			"move_left", "move_right", "move_forward", "move_backward"
		)
	var desired_direction := Vector3.ZERO
	if input_vector.length_squared() > 0.0:
		desired_direction = (
			global_transform.basis.x * input_vector.x
			+ global_transform.basis.z * input_vector.y
		).normalized()

	var desired_velocity := desired_direction * movement_speed
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	var rate := acceleration if desired_direction != Vector3.ZERO else deceleration
	horizontal_velocity = horizontal_velocity.move_toward(desired_velocity, rate * delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	if is_on_floor():
		velocity.y = -0.5
	else:
		velocity.y -= gravity * delta

	move_and_slide()


func set_input_enabled(next_enabled: bool) -> void:
	input_enabled = next_enabled
	if not input_enabled:
		velocity = Vector3.ZERO


func _capture_mouse(captured: bool) -> void:
	_mouse_captured = captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE
