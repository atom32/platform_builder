shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec4 water_color : source_color = vec4(0.1, 0.3, 0.5, 1.0);
uniform float wave_speed : hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float wave_height : hint_range(0.0, 2.0, 0.1) = 0.3;
uniform float wave_frequency : hint_range(0.1, 10.0, 0.1) = 2.0;

uniform sampler2D noise_texture;

varying float wave_offset;

void vertex() {
	// Create wave animation using sine waves
	float time = TIME * wave_speed;

	// Combine multiple waves for more natural look
	float wave1 = sin(VERTEX.x * wave_frequency + time) * wave_height;
	float wave2 = sin(VERTEX.z * wave_frequency * 0.7 + time * 1.3) * wave_height * 0.7;
	float wave3 = sin((VERTEX.x + VERTEX.z) * wave_frequency * 0.5 + time * 0.7) * wave_height * 0.5;

	wave_offset = wave1 + wave2 + wave3;

	// Apply wave height to Y position
	VERTEX.y += wave_offset;

	// Calculate normal for lighting
	float delta = 0.1;
	float h_left = sin((VERTEX.x - delta) * wave_frequency + time) * wave_height;
	float h_right = sin((VERTEX.x + delta) * wave_frequency + time) * wave_height;
	float h_down = sin(VERTEX.z * wave_frequency * 0.7 + time * 1.3) * wave_height * 0.7;
	float h_up = sin((VERTEX.z + delta) * wave_frequency * 0.7 + time * 1.3) * wave_height * 0.7;

	vec3 tangent = vec3(1.0, h_right - h_left, 0.0);
	vec3 binormal = vec3(0.0, h_up - h_down, 1.0);
	NORMAL = normalize(cross(binormal, tangent));
}

void fragment() {
	// Mix base color with wave highlights
	float highlight = smoothstep(-0.5, 0.5, wave_offset);
	vec3 color = mix(water_color.rgb, water_color.rgb * 1.3, highlight * 0.3);

	// Add depth-based darkening at edges
	float depth = smoothstep(0.0, 50.0, -VERTEX.z);
	color = mix(color, color * 0.7, depth * 0.3);

	ALBEDO = color;
	ROUGHNESS = 0.7;
	METALLIC = 0.1;
}
