shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 water_color : hint_color = vec4(0.1, 0.4, 0.8, 0.8);
uniform float wave_height : hint_range(0.0, 1.0) = 0.3;
uniform float wave_speed = 1.0;
uniform float wave_scale = 2.0;

varying float height_displacement;

void vertex() {
	// Create wave effect using sine waves
	vec3 pos = VERTEX;
	float time = TIME * wave_speed;
	
	// Combine multiple sine waves for more natural look
	height_displacement = sin(pos.x * wave_scale + time) * wave_height;
	height_displacement += sin(pos.z * wave_scale * 0.8 + time * 1.2) * wave_height * 0.5;
	
	pos.y += height_displacement;
	VERTEX = pos;
}

void fragment() {
	// Base water color with transparency
	vec4 color = water_color;
	
	// Add subtle variation based on wave height
	float brightness = 1.0 + height_displacement * 0.3;
	color.rgb *= brightness;
	
	// Add specular-like highlights
	float highlight = smoothstep(0.2, 0.5, height_displacement);
	color.rgb += vec3(0.2, 0.3, 0.4) * highlight;
	
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
