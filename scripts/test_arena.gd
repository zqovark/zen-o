class_name TestArena
extends Node3D

@export_range(8, 96, 1) var boundary_segments: int = 48
@export_range(10.0, 80.0, 0.5) var base_boundary_radius: float = 28.0

var _transformable_nodes: Array[Node3D] = []

var _floor_material: StandardMaterial3D
var _guide_material: StandardMaterial3D
var _center_material: StandardMaterial3D
var _near_material: StandardMaterial3D
var _near_accent_material: StandardMaterial3D
var _mid_material: StandardMaterial3D
var _mid_accent_material: StandardMaterial3D
var _outer_material: StandardMaterial3D
var _outer_accent_material: StandardMaterial3D


func _ready() -> void:
	_create_materials()
	_create_floor()
	_create_center_reference()
	_create_near_monoliths()
	_create_mid_colonnades()
	_create_outer_boundary()


func get_transformable_nodes() -> Array[Node3D]:
	return _transformable_nodes.duplicate()


func _create_materials() -> void:
	_floor_material = _make_material(Color(0.045, 0.052, 0.07), 0.94)
	_guide_material = _make_material(Color(0.105, 0.13, 0.16), 0.86)
	_center_material = _make_material(Color(0.96, 0.72, 0.2), 0.46)
	_near_material = _make_material(Color(0.16, 0.68, 0.7), 0.42)
	_near_accent_material = _make_material(Color(0.48, 0.96, 0.89), 0.32)
	_mid_material = _make_material(Color(0.34, 0.38, 0.68), 0.58)
	_mid_accent_material = _make_material(Color(0.68, 0.7, 0.95), 0.4)
	_outer_material = _make_material(Color(0.57, 0.59, 0.7), 0.75)
	_outer_accent_material = _make_material(Color(0.86, 0.68, 0.42), 0.54)


func _create_floor() -> void:
	var floor_body := StaticBody3D.new()
	floor_body.name = "Floor"
	floor_body.position.y = -0.2
	add_child(floor_body)

	var cylinder_mesh := CylinderMesh.new()
	cylinder_mesh.top_radius = 38.0
	cylinder_mesh.bottom_radius = 38.0
	cylinder_mesh.height = 0.4
	cylinder_mesh.radial_segments = 96
	cylinder_mesh.material = _floor_material
	_add_mesh(floor_body, cylinder_mesh, Vector3.ZERO)

	var floor_collision := CollisionShape3D.new()
	var floor_shape := CylinderShape3D.new()
	floor_shape.radius = 38.0
	floor_shape.height = 0.4
	floor_collision.shape = floor_shape
	floor_body.add_child(floor_collision)

	# These fixed diameters make alignment and radial motion readable.
	for index in 4:
		var guide := MeshInstance3D.new()
		var guide_mesh := BoxMesh.new()
		guide_mesh.size = Vector3(0.055, 0.018, base_boundary_radius * 2.0)
		guide_mesh.material = _guide_material
		guide.mesh = guide_mesh
		guide.position.y = 0.014
		guide.rotation.y = TAU * float(index) / 8.0
		add_child(guide)


func _create_center_reference() -> void:
	var center_body := StaticBody3D.new()
	center_body.name = "CenterBeacon"
	add_child(center_body)

	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 1.45
	base_mesh.bottom_radius = 1.45
	base_mesh.height = 0.18
	base_mesh.radial_segments = 32
	base_mesh.material = _center_material
	_add_mesh(center_body, base_mesh, Vector3(0.0, 0.09, 0.0))

	var obelisk_mesh := CylinderMesh.new()
	obelisk_mesh.top_radius = 0.28
	obelisk_mesh.bottom_radius = 0.78
	obelisk_mesh.height = 3.4
	obelisk_mesh.radial_segments = 6
	obelisk_mesh.material = _center_material
	_add_mesh(center_body, obelisk_mesh, Vector3(0.0, 1.8, 0.0))

	var center_collision := CollisionShape3D.new()
	var center_shape := CylinderShape3D.new()
	center_shape.radius = 0.8
	center_shape.height = 3.4
	center_collision.position.y = 1.8
	center_collision.shape = center_shape
	center_body.add_child(center_collision)

	var beacon := OmniLight3D.new()
	beacon.position.y = 3.45
	beacon.light_color = Color(1.0, 0.67, 0.2)
	beacon.light_energy = 3.2
	beacon.omni_range = 8.0
	center_body.add_child(beacon)


func _create_near_monoliths() -> void:
	# Asymmetric silhouettes make growth and inward motion easy to compare.
	for index in 4:
		var angle := TAU * (float(index) / 4.0 + 0.125)
		var body := AnimatableBody3D.new()
		body.name = "NearMonolithCluster%02d" % index
		body.position = Vector3(sin(angle) * 8.5, 0.0, cos(angle) * 8.5)
		body.rotation.y = angle
		add_child(body)

		_add_box(body, Vector3(1.25, 4.8, 0.9), Vector3(-0.82, 2.4, 0.0), _near_material)
		_add_box(body, Vector3(0.72, 2.65, 0.72), Vector3(0.78, 1.325, 0.15), _near_material)
		_add_box(
			body,
			Vector3(2.4, 0.32, 0.72),
			Vector3(-0.15, 3.25, 0.08),
			_near_accent_material,
			false
		)
		_add_sphere(body, 0.42, Vector3(-0.82, 5.14, 0.0), _near_accent_material)
		_register_transformable(body, "near")


func _create_mid_colonnades() -> void:
	# Repeated open gates reveal spacing expansion while remaining traversable.
	var gate_radii := [13.0, 17.0, 21.0]
	for ray_index in 4:
		var angle := TAU * float(ray_index) / 4.0
		for depth_index in gate_radii.size():
			var radius: float = gate_radii[depth_index]
			var body := AnimatableBody3D.new()
			body.name = "MidGate%02d_%02d" % [ray_index, depth_index]
			body.position = Vector3(sin(angle) * radius, 0.0, cos(angle) * radius)
			body.rotation.y = angle
			add_child(body)

			var height := 4.3 + float(depth_index) * 0.4
			_add_box(body, Vector3(0.5, height, 0.5), Vector3(-2.0, height * 0.5, 0.0), _mid_material)
			_add_box(body, Vector3(0.5, height, 0.5), Vector3(2.0, height * 0.5, 0.0), _mid_material)
			_add_box(
				body,
				Vector3(4.5, 0.36, 0.5),
				Vector3(0.0, height, 0.0),
				_mid_accent_material,
				false
			)
			_add_sphere(body, 0.24, Vector3(-2.0, height + 0.42, 0.0), _mid_accent_material)
			_add_sphere(body, 0.24, Vector3(2.0, height + 0.42, 0.0), _mid_accent_material)
			_register_transformable(body, "mid")


func _create_outer_boundary() -> void:
	var segment_width := TAU * base_boundary_radius / float(boundary_segments) * 1.08
	for index in boundary_segments:
		var angle := TAU * float(index) / float(boundary_segments)
		var body := AnimatableBody3D.new()
		body.name = "OuterWall%02d" % index
		body.position = Vector3(sin(angle) * base_boundary_radius, 0.0, cos(angle) * base_boundary_radius)
		body.rotation.y = angle
		add_child(body)

		_add_box(
			body,
			Vector3(segment_width, 2.8, 0.72),
			Vector3(0.0, 1.4, 0.0),
			_outer_material
		)

		# Eight tall teeth give the moving wall a stable, memorable skyline.
		if index % 6 == 0:
			_add_box(
				body,
				Vector3(0.9, 6.8, 1.05),
				Vector3(0.0, 3.4, 0.0),
				_outer_accent_material,
				false
			)
			_add_sphere(body, 0.52, Vector3(0.0, 7.2, 0.0), _outer_accent_material)

		_register_transformable(body, "outer")


func _add_box(
	parent: Node3D,
	size: Vector3,
	local_position: Vector3,
	material: Material,
	with_collision: bool = true
) -> void:
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	box_mesh.material = material
	_add_mesh(parent, box_mesh, local_position)
	if not with_collision:
		return
	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	collision.position = local_position
	collision.shape = box_shape
	parent.add_child(collision)


func _add_sphere(
	parent: Node3D,
	radius: float,
	local_position: Vector3,
	material: Material
) -> void:
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2.0
	sphere_mesh.radial_segments = 16
	sphere_mesh.rings = 8
	sphere_mesh.material = material
	_add_mesh(parent, sphere_mesh, local_position)


func _add_mesh(parent: Node3D, mesh: Mesh, local_position: Vector3) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.position = local_position
	parent.add_child(mesh_instance)


func _register_transformable(node: Node3D, layer: String) -> void:
	node.set_meta("base_position", node.position)
	node.set_meta("base_scale", node.scale)
	node.set_meta("zeno_layer", layer)
	_transformable_nodes.append(node)


func _make_material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material
