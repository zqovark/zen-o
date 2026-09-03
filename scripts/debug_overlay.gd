class_name DebugOverlay
extends CanvasLayer

var debug_visible: bool = false
var _player: PlayerController
var _threshold_system: ZenoThresholdSystem
var _world_state: WorldStateController
var _director: TransformationDirector
var _state_preview: SpatialStatePreview
var _operator_system: OperatorSystem
var _objective_manager: ObjectiveManager
var _anchor_puzzle: AnchorPuzzleController
var _anchor_route: AnchorRouteController
var _interaction_controller: InteractionController
var _panel: PanelContainer
var _readout: Label
var _crosshair: Label
var _controls_hint: Label


func _ready() -> void:
	_create_interface()


func configure(
	player: PlayerController,
	threshold_system: ZenoThresholdSystem,
	world_state: WorldStateController,
	director: TransformationDirector,
	state_preview: SpatialStatePreview,
	operator_system: OperatorSystem,
	objective_manager: ObjectiveManager,
	anchor_puzzle: AnchorPuzzleController,
	anchor_route: AnchorRouteController,
	interaction_controller: InteractionController
) -> void:
	_player = player
	_threshold_system = threshold_system
	_world_state = world_state
	_director = director
	_state_preview = state_preview
	_operator_system = operator_system
	_objective_manager = objective_manager
	_anchor_puzzle = anchor_puzzle
	_anchor_route = anchor_route
	_interaction_controller = interaction_controller


func set_debug_visible(next_visible: bool) -> void:
	debug_visible = next_visible
	if is_instance_valid(_panel):
		_panel.visible = next_visible


func _process(_delta: float) -> void:
	if not (
		is_instance_valid(_player)
		and is_instance_valid(_threshold_system)
		and is_instance_valid(_world_state)
		and is_instance_valid(_director)
		and is_instance_valid(_state_preview)
		and is_instance_valid(_operator_system)
		and is_instance_valid(_objective_manager)
		and is_instance_valid(_anchor_puzzle)
		and is_instance_valid(_anchor_route)
		and is_instance_valid(_interaction_controller)
	):
		return

	var position := _player.global_position
	_readout.text = (
		"ZENO / SPATIAL DIAGNOSTICS\n"
		+ "current_state           %d\n" % _world_state.current_state
		+ "previous_state          %d\n" % _world_state.previous_state
		+ "current_threshold       %d\n" % _threshold_system.current_threshold
		+ "previous_threshold      %d\n" % _threshold_system.previous_threshold
		+ "distance_to_center      %7.3f\n" % _threshold_system.distance_to_center
		+ "normalized_progress     %7.3f\n" % _threshold_system.normalized_edge_progress
		+ "movement_direction      %s\n" % _threshold_system.movement_direction_label()
		+ "player_position         (%6.2f, %5.2f, %6.2f)\n" % [position.x, position.y, position.z]
		+ "near  radius / scale    %5.2f / %5.2f\n" % [_director.near_radius_ratio, _director.near_scale_ratio]
		+ "mid   radius / scale    %5.2f / %5.2f\n" % [_director.mid_radius_ratio, _director.mid_scale_ratio]
		+ "outer radius / scale    %5.2f / %5.2f\n" % [_director.outer_radius_ratio, _director.outer_scale_ratio]
		+ "transition              %s  %5.2f\n" % [str(_director.transition_active), _director.transition_progress]
		+ "target_preview          %s\n\n" % _state_preview.preview_label()
		+ "anchor_acquired         %s\n" % str(_operator_system.anchor_acquired)
		+ "anchor_active           %s\n" % str(_operator_system.is_anchor_active())
		+ "anchored_target         %s\n" % _operator_system.anchored_target_label()
		+ "anchored_state          %d\n" % _operator_system.anchored_state
		+ "objective_state         %s\n" % _objective_manager.objective_label()
		+ "fragment_collected      %s\n" % str(_objective_manager.fragment_collected)
		+ "fragment_ready          %s  error %5.3f\n" % [str(_anchor_puzzle.fragment_collectible), _anchor_puzzle.alignment_error]
		+ "route_unlocked          %s\n" % str(_anchor_route.route_unlocked)
		+ "route_open              %s  clearance %5.3f\n" % [str(_anchor_route.route_open), _anchor_route.radial_clearance]
		+ "route_crossed           %s\n" % str(_anchor_route.route_crossed)
		+ "exit_active             %s\n" % str(_objective_manager.exit_active)
		+ "aimed_interaction       %s\n\n" % _interaction_controller.aimed_interaction
		+ "WASD move • Mouse look • E interact • R restart\nEsc release • F3 debug • F4 preview"
	)
	_crosshair.add_theme_color_override(
		"font_color",
		Color(1.0, 0.78, 0.3) if _interaction_controller.aimed_interaction != "NONE" else Color(0.9, 0.96, 1.0, 0.78)
	)


func _create_interface() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(14.0, 14.0)
	_panel.custom_minimum_size = Vector2(455.0, 0.0)
	add_child(_panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.012, 0.018, 0.032, 0.86)
	panel_style.border_color = Color(0.26, 0.72, 0.75, 0.7)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	_panel.add_theme_stylebox_override("panel", panel_style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	_panel.add_child(margin)

	_readout = Label.new()
	_readout.add_theme_color_override("font_color", Color(0.84, 0.95, 0.96))
	_readout.add_theme_font_size_override("font_size", 14)
	margin.add_child(_readout)

	_crosshair = Label.new()
	_crosshair.text = "+"
	_crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_crosshair.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_crosshair.set_anchors_preset(Control.PRESET_CENTER)
	_crosshair.position = Vector2(-10.0, -14.0)
	_crosshair.size = Vector2(20.0, 28.0)
	_crosshair.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0, 0.78))
	_crosshair.add_theme_font_size_override("font_size", 18)
	add_child(_crosshair)

	_controls_hint = Label.new()
	_controls_hint.text = "WASD  MOVE     MOUSE  LOOK     E  INTERACT     R  RESTART"
	_controls_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_controls_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_controls_hint.position = Vector2(-280.0, -58.0)
	_controls_hint.size = Vector2(560.0, 28.0)
	_controls_hint.add_theme_color_override("font_color", Color(0.82, 0.92, 0.94, 0.88))
	_controls_hint.add_theme_color_override("font_outline_color", Color(0.01, 0.018, 0.026, 0.92))
	_controls_hint.add_theme_constant_override("outline_size", 5)
	_controls_hint.add_theme_font_size_override("font_size", 14)
	add_child(_controls_hint)

	var hint_tween := create_tween()
	hint_tween.tween_interval(7.0)
	hint_tween.tween_property(_controls_hint, "modulate:a", 0.0, 1.5)
