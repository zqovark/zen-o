class_name SpatialStatePreview
extends Node3D

var preview_state: int = -1

var _arena: TestArena
var _director: TransformationDirector
var _debug_visible: bool = true


func configure(test_arena: TestArena, transformation_director: TransformationDirector) -> void:
	_arena = test_arena
	_director = transformation_director
	_rebuild()


func cycle_preview() -> void:
	if not is_instance_valid(_director):
		return
	preview_state += 1
	if preview_state >= _director.get_state_count():
		preview_state = -1
	_rebuild()


func set_debug_visible(next_visible: bool) -> void:
	_debug_visible = next_visible
	visible = _debug_visible and preview_state >= 0


func preview_label() -> String:
	return "OFF" if preview_state < 0 else "STATE %d" % preview_state


func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	visible = _debug_visible and preview_state >= 0
	if preview_state < 0 or not is_instance_valid(_arena) or not is_instance_valid(_director):
		return

	var ghost_material := _make_ghost_material(preview_state)
	for source in _arena.get_transformable_nodes():
		var ghost_root := Node3D.new()
		ghost_root.position = _director.get_target_position_for_state(source, preview_state)
		ghost_root.rotation = source.rotation
		ghost_root.scale = _director.get_target_scale_for_state(source, preview_state)
		add_child(ghost_root)

		for source_child in source.get_children():
			if source_child is MeshInstance3D:
				var source_mesh := source_child as MeshInstance3D
				var ghost_mesh := MeshInstance3D.new()
				ghost_mesh.mesh = source_mesh.mesh
				ghost_mesh.transform = source_mesh.transform
				ghost_mesh.material_override = ghost_material
				ghost_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				ghost_root.add_child(ghost_mesh)


func _make_ghost_material(state: int) -> StandardMaterial3D:
	var colors := [
		Color(0.3, 0.95, 0.82, 0.16),
		Color(0.4, 0.68, 1.0, 0.16),
		Color(0.72, 0.52, 1.0, 0.16),
		Color(1.0, 0.55, 0.28, 0.16),
	]
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = colors[state % colors.size()]
	material.no_depth_test = true
	material.render_priority = 2
	return material
