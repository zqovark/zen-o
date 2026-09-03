extends Node3D

@onready var player: PlayerController = %Player
@onready var test_arena: TestArena = %TestArena
@onready var threshold_system: ZenoThresholdSystem = %ZenoThresholdSystem
@onready var world_state_controller: WorldStateController = %WorldStateController
@onready var transformation_director: TransformationDirector = %TransformationDirector
@onready var operator_system: OperatorSystem = %OperatorSystem
@onready var objective_manager: ObjectiveManager = %ObjectiveManager
@onready var interaction_controller: InteractionController = %InteractionController
@onready var anchor_puzzle: AnchorPuzzleController = %AnchorPuzzle
@onready var anchor_route: AnchorRouteController = %AnchorRoute
@onready var spatial_feedback: SpatialFeedbackController = %SpatialFeedback
@onready var threshold_visualizer: ThresholdVisualizer = %ThresholdVisualizer
@onready var spatial_state_preview: SpatialStatePreview = %SpatialStatePreview
@onready var debug_overlay: DebugOverlay = %DebugOverlay

var _debug_visible: bool = false


func _ready() -> void:
	threshold_system.configure(player, Vector3.ZERO)
	threshold_system.threshold_entered.connect(world_state_controller.on_threshold_entered)
	threshold_system.threshold_exited.connect(world_state_controller.on_threshold_exited)

	anchor_puzzle.configure(
		test_arena,
		transformation_director,
		world_state_controller,
		operator_system,
		objective_manager,
		player,
		interaction_controller
	)
	anchor_route.configure(
		test_arena,
		transformation_director,
		world_state_controller,
		operator_system,
		objective_manager,
		player,
		anchor_puzzle.puzzle_exit
	)
	transformation_director.configure(test_arena)
	world_state_controller.world_state_changed.connect(
		transformation_director.transition_to_state
	)
	operator_system.anchor_resolution_changed.connect(
		transformation_director.refresh_current_state
	)
	transformation_director.apply_state_immediately(world_state_controller.current_state)
	interaction_controller.configure(player.camera, player)
	spatial_feedback.configure(
		player.camera,
		world_state_controller,
		threshold_system.thresholds,
		threshold_system.conceptual_edge_radius
	)

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
		spatial_state_preview,
		operator_system,
		objective_manager,
		anchor_puzzle,
		anchor_route,
		interaction_controller
	)
	threshold_visualizer.set_debug_visible(_debug_visible)
	spatial_state_preview.set_debug_visible(_debug_visible)
	debug_overlay.set_debug_visible(_debug_visible)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_run"):
		get_tree().reload_current_scene()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		_debug_visible = not _debug_visible
		threshold_visualizer.set_debug_visible(_debug_visible)
		spatial_state_preview.set_debug_visible(_debug_visible)
		debug_overlay.set_debug_visible(_debug_visible)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F4:
		spatial_state_preview.cycle_preview()
		get_viewport().set_input_as_handled()
