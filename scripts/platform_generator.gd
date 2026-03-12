extends Node
class_name PlatformGenerator

## Rule-based platform procedural generation system
## Uses templates and module library for consistent, themed generation

## Generate platform based on type
static func generate_platform(platform_node: Node3D, platform_type: String = "R&D"):
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# Get template for this platform type
	var template = PlatformTemplates.get_template(platform_type)
	if template == null:
		print("Warning: No template found for platform type: ", platform_type)
		template = PlatformTemplates.get_template("R&D")  # Fallback

	# Generation pipeline
	_create_platform_base(platform_node, template)
	_apply_top_modules(platform_node, template, rng)
	_apply_middle_modules(platform_node, template, rng)
	_apply_edge_modules(platform_node, template, rng)
	_randomize_details(platform_node, template, rng)

## Generate HQ with castle structure
static func generate_hq_castle(platform_node: Node3D):
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# HQ uses special 3-tier structure
	_create_hq_layer_1(platform_node)
	_create_hq_layer_2(platform_node)
	_create_hq_layer_3(platform_node)

	# Add some procedural details
	var template = PlatformTemplates.get_template("HQ")
	_add_hq_details(platform_node, template, rng)

## Create platform base with themed color
static func _create_platform_base(parent: Node3D, template: Dictionary):
	var base = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 3.5
	cylinder.bottom_radius = 3.5
	cylinder.height = 0.8
	cylinder.radial_segments = 6
	base.mesh = cylinder
	base.position = Vector3(0, 0.4, 0)

	var material = StandardMaterial3D.new()
	material.albedo_color = PlatformTemplates.get_base_color(template)
	base.set_surface_override_material(0, material)

	parent.add_child(base)

## Apply top layer modules (high visibility structures)
static func _apply_top_modules(parent: Node3D, template: Dictionary, rng: RandomNumberGenerator):
	var modules = PlatformTemplates.get_random_modules(template, "top", rng)
	var positions = _get_top_positions(modules.size(), rng)

	for i in range(modules.size()):
		var module_id = modules[i]
		var module_data = ModuleLibrary.get_module(module_id)
		if module_data == null:
			continue

		var pos = positions[i] if i < positions.size() else _get_random_top_position(rng)
		_create_module(parent, module_data, pos, rng)

## Apply middle layer modules (floor structures)
static func _apply_middle_modules(parent: Node3D, template: Dictionary, rng: RandomNumberGenerator):
	var modules = PlatformTemplates.get_random_modules(template, "middle", rng)

	for module_id in modules:
		var module_data = ModuleLibrary.get_module(module_id)
		if module_data == null:
			continue

		var pos = _get_random_middle_position(rng)
		_create_module(parent, module_data, pos, rng)

## Apply edge modules (attached to platform edges)
static func _apply_edge_modules(parent: Node3D, template: Dictionary, rng: RandomNumberGenerator):
	var edge_slots = PlatformTemplates.get_edge_slot_positions()
	var available_slots = edge_slots.duplicate()

	# Shuffle slots for random placement
	available_slots.shuffle()

	var modules = PlatformTemplates.get_random_modules(template, "edge", rng)

	for i in range(min(modules.size(), available_slots.size())):
		var module_id = modules[i]
		var module_data = ModuleLibrary.get_module(module_id)
		if module_data == null:
			continue

		var slot_index = edge_slots.find(available_slots[i])
		var pos = available_slots[i]
		var rotation = PlatformTemplates.get_edge_slot_rotation(slot_index)

		_create_edge_module(parent, module_data, pos, rotation, rng)

## Add small random details for variety
static func _randomize_details(parent: Node3D, template: Dictionary, rng: RandomNumberGenerator):
	# Add small details like vents, small boxes, pipes
	var detail_count = rng.randi_range(2, 5)

	for i in range(detail_count):
		var detail_type = rng.randi_range(0, 2)
		var pos = _get_random_detail_position(rng)

		match detail_type:
			0:  # Small vent
				_create_small_vent(parent, pos, rng)
			1:  # Small box
				_create_small_box(parent, pos, rng)
			2:  # Small pipe
				_create_small_pipe(parent, pos, rng)

## Create a single module (now as IndustrialModule node with behavior)
static func _create_module(
	parent: Node3D,
	module_data: Dictionary,
	position: Vector3,
	rng: RandomNumberGenerator
):
	# Create module node
	var module_node = IndustrialModule.new()
	module_node.module_id = ModuleLibrary.get_module_id(module_data)
	module_node.module_type = module_node.module_id

	# Position the module node
	var height = ModuleLibrary.get_height(module_data)
	module_node.position = Vector3(position.x, 0, position.z)

	# Create visual mesh as child
	var visual = MeshInstance3D.new()
	visual.name = "Visual"
	visual.position = Vector3(0, height, 0)

	# Create mesh based on type
	var mesh_type = ModuleLibrary.get_mesh_type(module_data)
	var scale = ModuleLibrary.get_scale(module_data)
	_create_mesh_for_type(visual, mesh_type, scale)

	# Rotation
	var can_rotate = ModuleLibrary.get_can_rotate(module_data)
	var fixed_angles = ModuleLibrary.get_fixed_angles(module_data)
	if can_rotate:
		if fixed_angles.is_empty():
			visual.rotation_degrees = Vector3(0, rng.randf_range(0, 360), 0)
		else:
			var angle = fixed_angles.pick_random()
			visual.rotation_degrees = Vector3(0, angle, 0)

	# Color
	var material = StandardMaterial3D.new()
	var color_options = ModuleLibrary.get_color_options(module_data)
	var color = color_options.pick_random()
	material.albedo_color = color
	visual.set_surface_override_material(0, material)

	module_node.add_child(visual)

	# Create interaction area
	var interaction_area = Area3D.new()
	interaction_area.name = "InteractionArea"

	var collision_shape = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 2.0  # Interaction radius
	collision_shape.shape = shape
	interaction_area.add_child(collision_shape)

	interaction_area.position = Vector3(0, height + 1.0, 0)
	module_node.add_child(interaction_area)

	# Add to parent
	parent.add_child(module_node)

	# Note: signal connection is now handled internally by IndustrialModule

## Create edge module (attached to platform edge, now as IndustrialModule node)
static func _create_edge_module(
	parent: Node3D,
	module_data: Dictionary,
	position: Vector3,
	rotation_degrees: float,
	rng: RandomNumberGenerator
):
	# Create module node
	var module_node = IndustrialModule.new()
	module_node.module_id = ModuleLibrary.get_module_id(module_data)
	module_node.module_type = module_node.module_id

	# Position the module node
	var height = ModuleLibrary.get_height(module_data)
	module_node.position = Vector3(position.x, 0, position.z)

	# Create visual mesh as child
	var visual = MeshInstance3D.new()
	visual.name = "Visual"
	visual.position = Vector3(0, height, 0)

	# Create mesh based on type
	var mesh_type = ModuleLibrary.get_mesh_type(module_data)
	var scale = ModuleLibrary.get_scale(module_data)
	_create_mesh_for_type(visual, mesh_type, scale)

	# Rotation - edge modules face outward
	var base_rotation = rotation_degrees
	var can_rotate = ModuleLibrary.get_can_rotate(module_data)
	var fixed_angles = ModuleLibrary.get_fixed_angles(module_data)
	if can_rotate and not fixed_angles.is_empty():
		base_rotation += fixed_angles.pick_random()
	visual.rotation_degrees = Vector3(0, base_rotation, 0)

	# Color
	var material = StandardMaterial3D.new()
	var color_options = ModuleLibrary.get_color_options(module_data)
	var color = color_options.pick_random()
	material.albedo_color = color
	visual.set_surface_override_material(0, material)

	module_node.add_child(visual)

	# Create interaction area
	var interaction_area = Area3D.new()
	interaction_area.name = "InteractionArea"

	var collision_shape = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 2.0  # Interaction radius
	collision_shape.shape = shape
	interaction_area.add_child(collision_shape)

	interaction_area.position = Vector3(0, height + 1.0, 0)
	module_node.add_child(interaction_area)

	# Add to parent
	parent.add_child(module_node)

	# Note: signal connection is now handled internally by IndustrialModule

## Create mesh for specific type
static func _create_mesh_for_type(mesh_instance: MeshInstance3D, mesh_type: int, scale: Vector3):
	match mesh_type:
		ModuleLibrary.MeshType.CYLINDER:
			var cylinder = CylinderMesh.new()
			cylinder.top_radius = scale.x / 2.0
			cylinder.bottom_radius = scale.x / 2.0
			cylinder.height = scale.y
			mesh_instance.mesh = cylinder

		ModuleLibrary.MeshType.BOX:
			var box = BoxMesh.new()
			box.size = scale
			mesh_instance.mesh = box

		ModuleLibrary.MeshType.DISH:
			# Create radar dish (inverted cone approximation)
			var dish = CylinderMesh.new()
			dish.top_radius = scale.x / 4.0
			dish.bottom_radius = scale.x / 2.0
			dish.height = scale.y
			dish.radial_segments = 16
			mesh_instance.mesh = dish

		ModuleLibrary.MeshType.ANTENNA:
			var antenna = CylinderMesh.new()
			antenna.top_radius = scale.x / 2.0
			antenna.bottom_radius = scale.x / 2.0
			antenna.height = scale.y
			mesh_instance.mesh = antenna

		ModuleLibrary.MeshType.CRANE:
			var crane = BoxMesh.new()
			crane.size = scale
			mesh_instance.mesh = crane

		ModuleLibrary.MeshType.PIPE_CLUSTER:
			var pipe = CylinderMesh.new()
			pipe.top_radius = scale.x / 2.0
			pipe.bottom_radius = scale.x / 2.0
			pipe.height = scale.y
			mesh_instance.mesh = pipe

		ModuleLibrary.MeshType.CONTAINER:
			var container = BoxMesh.new()
			container.size = scale
			mesh_instance.mesh = container

		ModuleLibrary.MeshType.SOLAR_PANEL:
			var panel = BoxMesh.new()
			panel.size = scale
			mesh_instance.mesh = panel

		ModuleLibrary.MeshType.VENT:
			var vent = CylinderMesh.new()
			vent.top_radius = scale.x / 2.0
			vent.bottom_radius = scale.x / 2.0
			vent.height = scale.y
			mesh_instance.mesh = vent

		ModuleLibrary.MeshType.SATELLITE_DISH:
			var sat_dish = CylinderMesh.new()
			sat_dish.top_radius = scale.x / 6.0
			sat_dish.bottom_radius = scale.x / 2.0
			sat_dish.height = scale.y
			sat_dish.radial_segments = 24
			mesh_instance.mesh = sat_dish

		ModuleLibrary.MeshType.HELIPAD:
			var pad = BoxMesh.new()
			pad.size = scale
			mesh_instance.mesh = pad

		ModuleLibrary.MeshType.TURRET:
			var turret = BoxMesh.new()
			turret.size = scale
			mesh_instance.mesh = turret

		ModuleLibrary.MeshType.COMMS_ARRAY:
			# Create tower with multiple elements
			var tower = CylinderMesh.new()
			tower.top_radius = scale.x / 3.0
			tower.bottom_radius = scale.x / 2.0
			tower.height = scale.y
			mesh_instance.mesh = tower

## Get positions for top modules (spread out, not too close to center)
static func _get_top_positions(count: int, rng: RandomNumberGenerator) -> Array[Vector3]:
	var positions: Array[Vector3] = []
	var radius = 2.0  # Distance from center

	for i in range(count):
		var angle = (PI * 2 / count) * i + rng.randf_range(-0.3, 0.3)
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		positions.append(Vector3(x, 0, z))

	return positions

## Get random position for top module
static func _get_random_top_position(rng: RandomNumberGenerator) -> Vector3:
	var radius = rng.randf_range(1.0, 2.5)
	var angle = rng.randf_range(0, PI * 2)
	return Vector3(cos(angle) * radius, 0, sin(angle) * radius)

## Get random position for middle module
static func _get_random_middle_position(rng: RandomNumberGenerator) -> Vector3:
	var x = rng.randf_range(-2.5, 2.5)
	var z = rng.randf_range(-2.5, 2.5)

	# Keep away from very center
	if abs(x) < 0.8 and abs(z) < 0.8:
		if abs(x) < abs(z):
			x = 1.5 if x >= 0 else -1.5
		else:
			z = 1.5 if z >= 0 else -1.5

	return Vector3(x, 0, z)

## Get random position for small detail
static func _get_random_detail_position(rng: RandomNumberGenerator) -> Vector3:
	var x = rng.randf_range(-3.0, 3.0)
	var z = rng.randf_range(-3.0, 3.0)
	return Vector3(x, 0, z)

## Create small vent detail
static func _create_small_vent(parent: Node3D, pos: Vector3, rng: RandomNumberGenerator):
	var vent = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.15
	cylinder.bottom_radius = 0.15
	cylinder.height = 0.3
	vent.mesh = cylinder
	vent.position = Vector3(pos.x, 0.15, pos.z)

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.4, 0.4, 0.45)
	vent.set_surface_override_material(0, material)

	parent.add_child(vent)

## Create small box detail
static func _create_small_box(parent: Node3D, pos: Vector3, rng: RandomNumberGenerator):
	var box = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.4, 0.25, 0.4)
	box.mesh = box_mesh
	box.position = Vector3(pos.x, 0.125, pos.z)

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.48, 0.45)
	box.set_surface_override_material(0, material)

	parent.add_child(box)

## Create small pipe detail
static func _create_small_pipe(parent: Node3D, pos: Vector3, rng: RandomNumberGenerator):
	var pipe = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.08
	cylinder.bottom_radius = 0.08
	cylinder.height = 0.6
	pipe.mesh = cylinder
	pipe.position = Vector3(pos.x, 0.3, pos.z)

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.5, 0.4)
	pipe.set_surface_override_material(0, material)

	parent.add_child(pipe)

# ===== HQ LAYER FUNCTIONS =====

## Create Layer 1 - Base with corner towers
static func _create_hq_layer_1(parent: Node3D):
	var corners = [
		Vector3(3.5, 0.5, 0),
		Vector3(1.75, 0.5, 3),
		Vector3(-1.75, 0.5, 3),
		Vector3(-3.5, 0.5, 0),
		Vector3(-1.75, 0.5, -3),
		Vector3(1.75, 0.5, -3)
	]

	for corner in corners:
		var tower = MeshInstance3D.new()
		var cylinder = CylinderMesh.new()
		cylinder.top_radius = 0.8
		cylinder.bottom_radius = 1.0
		cylinder.height = 2.5
		tower.mesh = cylinder
		tower.position = corner

		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.3, 0.3, 0.35)
		tower.set_surface_override_material(0, material)

		parent.add_child(tower)

	# Central hexagonal platform
	var center_base = MeshInstance3D.new()
	var base_cylinder = CylinderMesh.new()
	base_cylinder.top_radius = 3.0
	base_cylinder.bottom_radius = 3.0
	base_cylinder.height = 0.8
	base_cylinder.radial_segments = 6
	center_base.mesh = base_cylinder
	center_base.position = Vector3(0, 0.4, 0)

	var base_material = StandardMaterial3D.new()
	base_material.albedo_color = Color(0.35, 0.35, 0.4)
	center_base.set_surface_override_material(0, base_material)

	parent.add_child(center_base)

## Create Layer 2 - Main building
static func _create_hq_layer_2(parent: Node3D):
	# Main building block
	var main_building = MeshInstance3D.new()
	var building_mesh = CylinderMesh.new()
	building_mesh.top_radius = 2.2
	building_mesh.bottom_radius = 2.4
	building_mesh.height = 3.0
	building_mesh.radial_segments = 6
	main_building.mesh = building_mesh
	main_building.position = Vector3(0, 2.3, 0)

	var building_material = StandardMaterial3D.new()
	building_material.albedo_color = Color(0.4, 0.4, 0.45)
	main_building.set_surface_override_material(0, building_material)

	parent.add_child(main_building)

	# Side structures (4 small blocks)
	var side_positions = [
		Vector3(2.5, 1.5, 0),
		Vector3(-2.5, 1.5, 0),
		Vector3(0, 1.5, 2.5),
		Vector3(0, 1.5, -2.5)
	]

	for pos in side_positions:
		var side_block = MeshInstance3D.new()
		var block = BoxMesh.new()
		block.size = Vector3(1.2, 2.0, 1.2)
		side_block.mesh = block
		side_block.position = pos

		var block_material = StandardMaterial3D.new()
		block_material.albedo_color = Color(0.38, 0.38, 0.42)
		side_block.set_surface_override_material(0, block_material)

		parent.add_child(side_block)

## Create Layer 3 - Control tower and radar
static func _create_hq_layer_3(parent: Node3D):
	# Control tower (center)
	var control_tower = MeshInstance3D.new()
	var tower_mesh = CylinderMesh.new()
	tower_mesh.top_radius = 0.8
	tower_mesh.bottom_radius = 1.2
	tower_mesh.height = 2.5
	tower_mesh.radial_segments = 6
	control_tower.mesh = tower_mesh
	control_tower.position = Vector3(0, 4.8, 0)

	var tower_material = StandardMaterial3D.new()
	tower_material.albedo_color = Color(0.45, 0.45, 0.5)
	control_tower.set_surface_override_material(0, tower_material)

	parent.add_child(control_tower)

	# Large radar dish on top
	var radar = MeshInstance3D.new()
	var radar_mesh = CylinderMesh.new()
	radar_mesh.top_radius = 0.3
	radar_mesh.bottom_radius = 1.5
	radar_mesh.height = 0.8
	radar_mesh.radial_segments = 16
	radar.mesh = radar_mesh
	radar.position = Vector3(0, 6.2, 0)

	var radar_material = StandardMaterial3D.new()
	radar_material.albedo_color = Color(0.6, 0.6, 0.65)
	radar.set_surface_override_material(0, radar_material)

	parent.add_child(radar)

	# Antenna around tower
	var antenna_positions = [
		Vector3(1.5, 5.5, 0),
		Vector3(-1.5, 5.5, 0),
		Vector3(0, 5.5, 1.5),
		Vector3(0, 5.5, -1.5)
	]

	for pos in antenna_positions:
		var antenna = MeshInstance3D.new()
		var antenna_mesh = CylinderMesh.new()
		antenna_mesh.top_radius = 0.1
		antenna_mesh.bottom_radius = 0.1
		antenna_mesh.height = 1.5
		antenna.mesh = antenna_mesh
		antenna.position = pos

		var antenna_material = StandardMaterial3D.new()
		antenna_material.albedo_color = Color(0.5, 0.5, 0.55)
		antenna.set_surface_override_material(0, antenna_material)

		parent.add_child(antenna)

## Add procedural details to HQ
static func _add_hq_details(parent: Node3D, template: Dictionary, rng: RandomNumberGenerator):
	# Add edge modules to HQ
	var edge_slots = PlatformTemplates.get_edge_slot_positions()
	var available_slots = edge_slots.duplicate()
	available_slots.shuffle()

	var modules = PlatformTemplates.get_random_modules(template, "edge", rng)

	for i in range(min(modules.size(), available_slots.size())):
		var module_id = modules[i]
		var module_data = ModuleLibrary.get_module(module_id)
		if module_data == null:
			continue

		var slot_index = edge_slots.find(available_slots[i])
		var pos = available_slots[i]
		var rotation = PlatformTemplates.get_edge_slot_rotation(slot_index)

		_create_edge_module(parent, module_data, pos, rotation, rng)
