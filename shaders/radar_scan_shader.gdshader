shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_always;

uniform vec4 ring_color: source_color = vec4(0.2, 0.8, 1.0, 0.5);
uniform float inner_radius: float = 0.0;
uniform float outer_radius: float = 5.0;
uniform float ring_thickness: float = 0.3;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	// Calculate distance from center (UV is 0-1, map to -1 to 1)
	vec2 uv_centered = UV * 2.0 - 1.0;
	float dist = length(uv_centered);

	// Map to world space roughly (plane is 10x10 units)
	float world_dist = dist * 5.0;

	// Check if fragment is within the ring
	float ring_inner = inner_radius;
	float ring_outer = inner_radius + ring_thickness;

	// Calculate alpha based on position in ring
	float alpha = 0.0;

	if (world_dist >= ring_inner && world_dist <= ring_outer) {
		// Smooth edges
		float inner_edge = smoothstep(ring_inner, ring_inner + 0.1, world_dist);
		float outer_edge = 1.0 - smoothstep(ring_outer - 0.1, ring_outer, world_dist);
		alpha = inner_edge * outer_edge;

		// Fade based on radius (larger rings = more transparent)
		float fade = 1.0 - (inner_radius / outer_radius);
		alpha *= fade;
	}

	if (alpha < 0.01) {
		discard;
	}

	ALBEDO = ring_color.rgb;
	ALPHA = ring_color.a * alpha;
}
