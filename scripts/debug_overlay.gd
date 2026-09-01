class_name DebugOverlay
extends CanvasLayer

var _player: PlayerController
var _threshold_system: ZenoThresholdSystem
var _world_state: WorldStateController
var _director: TransformationDirector
var _state_preview: SpatialStatePreview
var _panel: PanelContainer
var _readout: Label


func _ready() -> void:
	_create_interface()


func configure(
	player: PlayerController,
	threshold_system: ZenoThresholdSystem,
	world_state: WorldStateController,
	director: TransformationDirector,
	state_preview: SpatialStatePreview
) -> void:
	_player = player
	_threshold_system = threshold_system
	_world_state = world_state
	_director = director
	_state_preview = state_preview


func set_debug_visible(next_visible: bool) -> void:
	if is_instance_valid(_panel):
		_panel.visible = next_visible


func _process(_delta: float) -> void:
	if not (
		is_instance_valid(_player)
		and is_instance_valid(_threshold_system)
		and is_instance_valid(_world_state)
		and is_instance_valid(_director)
		and is_instance_valid(_state_preview)
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
		+ "WASD move • Mouse look • Esc release • F3 debug • F4 preview"
	)


func _create_interface() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(14.0, 14.0)
	_panel.custom_minimum_size = Vector2(430.0, 0.0)
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

	var crosshair := Label.new()
	crosshair.text = "+"
	crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crosshair.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	crosshair.position = Vector2(-10.0, -14.0)
	crosshair.size = Vector2(20.0, 28.0)
	crosshair.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0, 0.78))
	crosshair.add_theme_font_size_override("font_size", 18)
	add_child(crosshair)
