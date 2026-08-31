extends Node
class_name OperatorSystem

signal operator_activated(operator_id: StringName)

var active_operator: StringName = &""

func activate_anchor() -> void:
	active_operator = &"anchor"
	operator_activated.emit(active_operator)
