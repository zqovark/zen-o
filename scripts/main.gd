extends Node3D

@onready var player: PlayerController = %Player
@onready var test_arena: TestArena = %TestArena
@onready var threshold_system: ZenoThresholdSystem = %ZenoThresholdSystem
@onready var world_state_controller: WorldStateController = %WorldStateController
@onready var transformation_director: TransformationDirector = %TransformationDirector
@onready var threshold_visualizer: ThresholdVisualizer = %ThresholdVisualizer
@onready var spatial_state_preview: SpatialStatePreview = %SpatialStatePreview
@onready var debug_overlay: DebugOverlay = %DebugOverlay

var _debug_visible: bool = true


func _ready() -> void:
	threshold_system.configure(player, Vector3.ZERO)
	threshold_system.threshold_entered.connect(world_state_controller.on_threshold_entered)
	threshold_system.threshold_exited.connect(world_state_controller.on_threshold_exited)

	transformation_director.configure(test_arena)
	world_state_controller.world_state_changed.connect(
		transformation_director.transition_to_state
	)
	transformation_director.apply_state_immediately(world_state_controller.current_state)

	threshold_visualizer.configure(
		threshold_system.thresholds,
		threshold_system.conceptual_edge_radius
	)
	spatial_state_preview.configure(test_arena, transformation_director)
	debug_overlay.configure(
		player,
		threshold_system,
		world_state_controller,
		transformation_director,
		spatial_state_preview
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		_debug_visible = not _debug_visible
		threshold_visualizer.set_debug_visible(_debug_visible)
		spatial_state_preview.set_debug_visible(_debug_visible)
		debug_overlay.set_debug_visible(_debug_visible)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F4:
		spatial_state_preview.cycle_preview()
		get_viewport().set_input_as_handled()
