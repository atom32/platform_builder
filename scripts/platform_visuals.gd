extends Node
class_name PlatformVisuals

## Visual system for platforms
## Handles platform geometry and materials

## Create hexagon platform mesh
static func create_hexagon_mesh() -> CylinderMesh:
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 5.0
	cylinder.bottom_radius = 5.0
	cylinder.height = 1.0
	cylinder.radial_segments = 6
	return cylinder

## Get platform color tint based on type
static func get_platform_color(platform_type: String) -> Color:
	match platform_type:
		"HQ":
			return Color(0.3, 0.3, 0.35)  # Dark metal
		"R&D":
			return Color(0.7, 0.7, 0.3)  # Yellow tint
		"Combat":
			return Color(0.7, 0.3, 0.3)  # Red tint
		"Support":
			return Color(0.3, 0.5, 0.7)  # Blue tint
		"Intel":
			return Color(0.6, 0.3, 0.7)  # Purple tint
		"Medical":
			return Color(0.3, 0.7, 0.4)  # Green tint
		_:
			return Color(0.5, 0.5, 0.5)  # Default gray

## Apply hexagon shape and color to platform mesh
static func apply_hexagon_visuals(mesh_instance: MeshInstance3D, platform_type: String):
	if not mesh_instance:
		return

	# Replace with hexagon mesh
	var hex_mesh = create_hexagon_mesh()
	mesh_instance.mesh = hex_mesh

	# Apply color tint
	var material = StandardMaterial3D.new()
	material.albedo_color = get_platform_color(platform_type)
	mesh_instance.set_surface_override_material(0, material)
