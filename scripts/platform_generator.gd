extends Node
class_name PlatformGenerator

## Procedurally generates random modules on platforms

## Module types
enum ModuleType {
	RADAR,
	ANTENNA,
	CRANE,
	PIPES,
	CONTAINER
}

## Generate random modules on a platform
static func generate_platform(platform_node: Node3D):
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# Random number of modules (2-5)
	var module_count = rng.randi_range(2, 5)

	for i in range(module_count):
		_create_random_module(platform_node, rng)

## Generate HQ castle structure (3-tier fortress)
static func generate_hq_castle(platform_node: Node3D):
	# Layer 1: Base platform with corner towers
	_create_hq_layer_1(platform_node)

	# Layer 2: Main building block
	_create_hq_layer_2(platform_node)

	# Layer 3: Control tower and radar
	_create_hq_layer_3(platform_node)

	print("HQ Castle generated: 3-tier structure")

## Create Layer 1 - Base with corner towers
static func _create_hq_layer_1(parent: Node3D):
	# Corner towers at hexagon corners
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

## Create a single random module
static func _create_random_module(parent: Node3D, rng: RandomNumberGenerator):
	var module_type = rng.randi_range(0, ModuleType.size() - 1)
	var mesh_instance = MeshInstance3D.new()

	# Set mesh based on type
	match module_type:
		ModuleType.RADAR:
			_create_radar(mesh_instance)
		ModuleType.ANTENNA:
			_create_antenna(mesh_instance)
		ModuleType.CRANE:
			_create_crane(mesh_instance)
		ModuleType.PIPES:
			_create_pipes(mesh_instance)
		ModuleType.CONTAINER:
			_create_container(mesh_instance)

	# Random position within platform bounds
	var x = rng.randf_range(-3.5, 3.5)
	var z = rng.randf_range(-3.5, 3.5)
	var y = 0.5  # Start at platform surface

	mesh_instance.position = Vector3(x, y, z)

	# Random rotation (0-360 degrees)
	var rotation_degrees = rng.randf_range(0, 360)
	mesh_instance.rotation_degrees = Vector3(0, rotation_degrees, 0)

	# Randomize color slightly for variety
	var material = StandardMaterial3D.new()
	material.albedo_color = _get_random_color(rng)
	mesh_instance.set_surface_override_material(0, material)

	parent.add_child(mesh_instance)

## Create radar module (dish on pole)
static func _create_radar(mesh_instance: MeshInstance3D):
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.3
	cylinder.bottom_radius = 0.3
	cylinder.height = 2.0
	mesh_instance.mesh = cylinder

## Create antenna module (tall thin pole)
static func _create_antenna(mesh_instance: MeshInstance3D):
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.1
	cylinder.bottom_radius = 0.1
	cylinder.height = 4.0
	mesh_instance.mesh = cylinder

## Create crane module (tall box structure)
static func _create_crane(mesh_instance: MeshInstance3D):
	var box = BoxMesh.new()
	box.size = Vector3(0.5, 5.0, 0.5)
	mesh_instance.mesh = box

## Create pipes module (cluster of small cylinders)
static func _create_pipes(mesh_instance: MeshInstance3D):
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.2
	cylinder.bottom_radius = 0.2
	cylinder.height = 1.5
	mesh_instance.mesh = cylinder

## Create container module (small box)
static func _create_container(mesh_instance: MeshInstance3D):
	var box = BoxMesh.new()
	box.size = Vector3(1.5, 1.0, 1.5)
	mesh_instance.mesh = box

## Get random industrial color
static func _get_random_color(rng: RandomNumberGenerator) -> Color:
	var colors = [
		Color(0.6, 0.6, 0.6),  # Gray
		Color(0.7, 0.5, 0.3),  # Rust orange
		Color(0.4, 0.4, 0.5),  # Blue-gray
		Color(0.5, 0.5, 0.5),  # Dark gray
		Color(0.8, 0.7, 0.4),  # Yellow-tan
		Color(0.3, 0.3, 0.35)  # Dark metal
	]
	return colors[rng.randi() % colors.size()]
