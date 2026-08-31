extends Node
class_name TransformationDirector

@export var transition_speed: float = 2.5
@export var world_root_path: NodePath

var _target_scale: float = 1.0
@onready var _world_root: Node3D = get_node(world_root_path)

func _ready() -> void:
	_target_scale = _world_root.scale.x

func _process(delta: float) -> void:
	var next_scale := move_toward(_world_root.scale.x, _target_scale, transition_speed * delta)
	_world_root.scale = Vector3.ONE * next_scale

func on_world_state_changed(_previous: int, current: int, state_controller: WorldStateController) -> void:
	_target_scale = state_controller.get_world_scale()
