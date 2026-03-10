extends Node
class_name BridgeGenerator

## Generates visual bridges between parent and child platforms

## Generate a bridge between parent and child platform
static func create_bridge(parent_platform: Platform, child_platform: Node3D):
	if not parent_platform or not child_platform:
		return

	var bridge = MeshInstance3D.new()
	bridge.name = "Bridge_to_%s" % child_platform.name

	# Calculate positions using GLOBAL coordinates
	# This is critical because platforms may be nested (child of child)
	var parent_pos = parent_platform.global_position
	var child_pos = child_platform.global_position

	# Calculate direction and distance
	var direction = child_pos - parent_pos
	var distance = direction.length()

	# Bridge dimensions
	var bridge_length = distance
	var bridge_width = 1.5
	var bridge_height = 0.3

	# Create bridge mesh (box)
	var bridge_mesh = BoxMesh.new()
	bridge_mesh.size = Vector3(bridge_width, bridge_height, bridge_length)
	bridge.mesh = bridge_mesh

	# Position bridge at midpoint (using global position)
	var mid_point = (parent_pos + child_pos) / 2.0
	bridge.global_position = mid_point
	bridge.global_position.y = -1.5  # Slightly below platform surface

	# Rotate bridge to align with direction
	# BoxMesh extends along Z axis by default
	# We need to rotate from (0,0,1) to our direction
	var forward = Vector3(0, 0, 1)
	var target_direction = direction.normalized()

	# Calculate rotation around Y axis
	var angle = atan2(target_direction.x, target_direction.z)
	bridge.rotation_degrees.y = rad_to_deg(angle)

	# Create industrial material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.5, 0.55)  # Industrial gray
	material.metallic = 0.3
	material.roughness = 0.7
	bridge.set_surface_override_material(0, material)

	# Add bridge to scene (as child of Base root)
	# Find the Base node (parent of HQ)
	var scene_root = parent_platform.get_parent()
	while scene_root and not scene_root is Base:
		scene_root = scene_root.get_parent()

	if scene_root:
		scene_root.add_child(bridge)
		# Convert global position to local since we're adding to Base
		bridge.global_position = mid_point
		bridge.global_position.y = -1.5

	return bridge
