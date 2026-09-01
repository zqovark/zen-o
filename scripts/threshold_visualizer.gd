class_name ThresholdVisualizer
extends Node3D

@export var debug_visible: bool = true
@export_range(24, 256, 1) var ring_segments: int = 96

var _thresholds: PackedFloat32Array
var _edge_radius: float = 28.0


func configure(threshold_values: PackedFloat32Array, conceptual_edge_radius: float) -> void:
	_thresholds = threshold_values
	_edge_radius = conceptual_edge_radius
	_rebuild()


func set_debug_visible(next_visible: bool) -> void:
	debug_visible = next_visible
	visible = debug_visible


func _rebuild() -> void:
	for child in get_children():
		child.queue_free()

	var colors := [
		Color(0.18, 0.85, 0.82, 0.85),
		Color(0.52, 0.62, 1.0, 0.9),
		Color(0.95, 0.58, 0.3, 0.95),
	]
	for index in _thresholds.size():
		_create_ring(
			_edge_radius * _thresholds[index],
			colors[index % colors.size()]
		)
	_create_ring(_edge_radius, Color(0.9, 0.9, 0.95, 0.42))
	visible = debug_visible


func _create_ring(radius: float, color: Color) -> void:
	var immediate_mesh := ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.no_depth_test = true
	material.render_priority = 1

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, material)
	for index in ring_segments + 1:
		var angle := TAU * float(index) / float(ring_segments)
		immediate_mesh.surface_add_vertex(
			Vector3(sin(angle) * radius, 0.035, cos(angle) * radius)
		)
	immediate_mesh.surface_end()

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = immediate_mesh
	add_child(mesh_instance)
