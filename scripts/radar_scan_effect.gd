extends Node3D
class_name RadarScanEffect

## Simple radar scan effect using ring mesh expansion
## Tween-based animation for reliability

var scan_ring: MeshInstance3D = null
var tween: Tween = null

## Settings
var scan_duration: float = 3.0  # Seconds for full scan
var max_scale: float = 5.0  # Maximum scale
var ring_color: Color = Color(0.2, 0.8, 1.0, 0.6)

func _ready():
	_create_scan_ring()
	_start_scan_animation()

func _create_scan_ring():
	# Create a ring using Torus (donut shape)
	var torus = TorusMesh.new()
	torus.radius = 0.5  # Inner radius
	torus.inner_radius = 0.4  # Tube thickness
	torus.rings = 32
	torus.radial_segments = 32

	scan_ring = MeshInstance3D.new()
	scan_ring.name = "ScanRing"
	scan_ring.mesh = torus
	scan_ring.position = Vector3(0, 0.2, 0)  # Just above ground
	scan_ring.scale = Vector3(0.1, 0.1, 0.1)  # Start small

	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = ring_color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_BACK

	scan_ring.set_surface_override_material(0, material)
	scan_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	add_child(scan_ring)

func _start_scan_animation():
	tween = create_tween()
	tween.set_loops()
	tween.set_parallel(true)  # Run animations in parallel

	# Scale animation: Expand ring
	tween.tween_property(scan_ring, "scale", Vector3(max_scale, max_scale, max_scale), scan_duration)
	tween.tween_property(scan_ring, "scale", Vector3(0.1, 0.1, 0.1), 0.1)  # Quick reset

	# Create a separate tween for fade (can't be parallel with scale)
	_create_fade_animation()

func _create_fade_animation():
	# Create independent tween for fade animation
	var fade_tween = create_tween()
	fade_tween.set_loops()

	# Animate from high alpha to low alpha
	var start_color = Color(ring_color.r, ring_color.g, ring_color.b, 0.6)
	var end_color = Color(ring_color.r, ring_color.g, ring_color.b, 0.0)

	fade_tween.tween_method(
		scan_ring,
		"set_albedo_color",
		start_color,
		end_color,
		scan_duration
	)
