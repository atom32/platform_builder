extends Node3D
class_name RadarScanEffect

## Simple radar scan effect using ring mesh expansion
## Shader-free approach for better compatibility

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

	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = ring_color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard = false
	material.cull_mode = BaseMaterial3D.CULL_BACK

	scan_ring.set_surface_override_material(0, material)
	scan_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	add_child(scan_ring)

func _start_scan_animation():
	tween = create_tween()
	tween.set_loops()

	# Reset scale
	scan_ring.scale = Vector3(0.1, 0.1, 0.1)
	scan_ring.position = Vector3(0, 0.2, 0)

	# Animate: Scale up and fade out
	var fade_tween = create_tween()
	fade_tween.set_loops()

	# Scale animation
	var scale_tween = create_tween()
	scale_tween.set_parallel()
	scale_tween.set_loops()

	# Expand ring
	scale_tween.tween_property(scan_ring, "scale", Vector3(max_scale, max_scale, max_scale), scan_duration)
	scale_tween.tween_property(scan_ring, "scale", Vector3(0.1, 0.1, 0.1), 0.1)  # Quick reset

	# Fade out using material alpha
	_fade_out_animation()

func _fade_out_animation():
	var fade_tween = create_tween()
	fade_tween.set_loops()

	var material = scan_ring.get_surface_override_material(0)

	# Fade out as it expands
	fade_tween.tween_method(Callable(self, "_update_fade").bind(material), scan_duration)

func _update_fade(material: StandardMaterial3D, progress: float):
	# Progress goes 0 to 1
	# Fade alpha from 0.6 to 0
	var new_alpha = 0.6 * (1.0 - progress)
	material.albedo_color = Color(ring_color.r, ring_color.g, ring_color.b, new_alpha)
	material.albedo_color.a = new_alpha

## Stop scanning
func stop_scan():
	if tween:
		tween.kill()
		tween = null
	queue_free()

## Restart scan
func restart_scan():
	if tween:
		tween.kill()
	_start_scan_animation()
