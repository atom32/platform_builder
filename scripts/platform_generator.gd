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
