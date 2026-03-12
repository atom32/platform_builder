shader_type spatial;
render_mode unshaded, cull_disabled, ensure_correct_normals, blend_mix;

uniform float radius: float = 0.0;
uniform float max_radius: float = 20.0;
uniform float thickness: float = 0.5;
uniform vec4 color: source_color = vec4(0.2, 0.8, 1.0, 1.0);

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	// Calculate distance from center
	float dist = length(UV - vec2(0.5)) * 2.0;  // Scale to 0-1 range

	// Create expanding ring effect
	float ring_edge = radius / max_radius;
	float ring_inner = max(0.0, ring_edge - thickness / max_radius);
	float ring_outer = ring_edge;

	// Alpha based on position in ring
	float alpha = 0.0;
	if (dist >= ring_inner && dist <= ring_outer) {
		// Smooth falloff at edges
		float inner_fade = smoothstep(ring_inner, ring_inner + 0.05, dist);
		float outer_fade = 1.0 - smoothstep(ring_outer - 0.05, ring_outer, dist);
		alpha = inner_fade * outer_fade;
	}

	// Fade out as it expands
	alpha *= (1.0 - (radius / max_radius));

	// Check if we have any visible alpha
	if (alpha < 0.01) {
		discard;
	}

	ALBEDO = color.rgb;
	ALPHA = color.a * alpha;
}
