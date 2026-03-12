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
	torus.inner_radius = 0.4  # Inner radius (hole size)
	torus.outer_radius = 0.5  # Outer radius (ring thickness)
	torus.ring_segments = 32

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

	# Parallel tween group for both scale and fade
	var parallel_tween = tween.parallel()

	# Scale animation: Expand ring
	parallel_tween.tween_property(scan_ring, "scale", Vector3(max_scale, max_scale, max_scale), scan_duration)
	parallel_tween.tween_property(scan_ring, "scale", Vector3(0.1, 0.1, 0.1), 0.1)  # Quick reset

	# Fade animation using custom callback
	_create_fade_animation()

func _create_fade_animation():
	# Simple approach: Animate a counter and update material in _process
	var fade_tween = create_tween()
	fade_tween.set_loops()

	# Animate a dummy property from 0 to 1
	fade_tween.tween_property(self, "fade_progress", 1.0, scan_duration)
	fade_tween.tween_property(self, "fade_progress", 0.0, 0.1)  # Reset

## Dummy property for fade animation
var fade_progress: float = 0.0:
	set(value):
		fade_progress = value
		_update_ring_alpha(value)

func _update_ring_alpha(progress: float):
	if not scan_ring:
		return

	var material = scan_ring.get_surface_override_material(0)
	if not material:
		return

	# Alpha: 0.6 -> 0.0
	var new_alpha = 0.6 * (1.0 - progress)
	material.albedo_color = Color(ring_color.r, ring_color.g, ring_color.b, new_alpha)
