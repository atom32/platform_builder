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

	# Clear existing pillars before creating new ones
	_clear_existing_pillars(mesh_instance)

	# Replace with hexagon mesh
	var hex_mesh = create_hexagon_mesh()
	mesh_instance.mesh = hex_mesh

	# Apply color tint
	var material = StandardMaterial3D.new()
	material.albedo_color = get_platform_color(platform_type)
	mesh_instance.set_surface_override_material(0, material)

	# Create support pillars (oil rig style)
	_create_support_pillars(mesh_instance, platform_type)

## Clear existing pillars to avoid duplicates
static func _clear_existing_pillars(mesh_instance: MeshInstance3D):
	var platform_node = mesh_instance.get_parent()
	if not platform_node:
		return

	# Remove all pillars (MeshInstance3D with position.y < -1.0)
	for child in platform_node.get_children():
		if child is MeshInstance3D and child.position.y < -1.0:
			child.queue_free()

## Create 6 support pillars at hexagon corners (oil rig style)
static func _create_support_pillars(mesh_instance: MeshInstance3D, platform_type: String):
	var platform_node = mesh_instance.get_parent()
	if not platform_node:
		return

	var pillar_color = get_platform_color(platform_type)
	# Make pillars slightly darker than platform
	pillar_color.v -= 0.1

	var pillar_material = StandardMaterial3D.new()
	pillar_material.albedo_color = pillar_color

	# Hexagon corner positions (radius = 5, rotated 30° to align with hexagon faces)
	# Angles: 30°, 90°, 150°, 210°, 270°, 330°
	# Pillars inset by 0.8 units so platform overhangs covers them
	var angle_offset = deg_to_rad(30)
	var inset = 0.8  # How far to inset pillars from edge
	var pillar_radius = 5.0 - inset
	var corners = []
	for i in range(6):
		var angle = angle_offset + (i * PI / 3)  # 60° increments
		var x = pillar_radius * cos(angle)
		var z = pillar_radius * sin(angle)
		corners.append(Vector3(x, 0, z))

	for corner in corners:
		var pillar = MeshInstance3D.new()

		# Create pillar cylinder
		var pillar_mesh = CylinderMesh.new()
		pillar_mesh.top_radius = 0.4
		pillar_mesh.bottom_radius = 0.4
		pillar_mesh.height = 3.0
		pillar.mesh = pillar_mesh

		# Position pillar at corner, extending downward from platform
		# Platform surface is at y=0, platform bottom at y=-0.5
		# Pillar should go from y=-0.5 to y=-3.5
		pillar.position = Vector3(corner.x, -2.0, corner.z)

		pillar.set_surface_override_material(0, pillar_material)

		# Add pillar as sibling of platform mesh (same parent)
		platform_node.add_child(pillar)
