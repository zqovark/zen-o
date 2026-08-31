extends CanvasLayer
class_name DebugOverlay

@onready var _label: Label = $Panel/MarginContainer/Label

func update_data(seed: int, state_controller: WorldStateController, threshold_data: Dictionary, operator_id: StringName, objective_text: String) -> void:
	_label.text = "Seed: %d\nState: %d (prev %d)\nThreshold: %d\nDistance: %.2f\nEdge progress: %.2f\nDirection: %d\nWorld scale: %.2f\nOperator: %s\nObjective: %s" % [
		seed,
		state_controller.state_index,
		state_controller.previous_state,
		threshold_data.get("threshold_index", 0),
		threshold_data.get("distance_to_center", 0.0),
		threshold_data.get("edge_progress", 0.0),
		threshold_data.get("movement_direction", 0),
		state_controller.get_world_scale(),
		String(operator_id),
		objective_text
	]
