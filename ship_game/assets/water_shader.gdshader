shader_type spatial;
render_mode depth_draw_opaque, cull_back, shadows_enabled;

uniform vec4 water_color : source_color = vec4(0.0, 0.4, 0.8, 0.9);
uniform float wave_height : hint_range(0.0, 2.0) = 0.4;
uniform float wave_speed = 1.5;
uniform float wave_scale = 0.5;
uniform float time : hint_range(0, 1000) = 0.0;

varying float wave_factor;

void vertex() {
	vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
	float t = time * wave_speed;
	
	// Create wave effect
	wave_factor = sin(world_pos.x * wave_scale + t) * cos(world_pos.z * wave_scale + t) * wave_height;
	VERTEX.y += wave_factor;
	
	// Calculate normals for lighting
	NORMAL = normalize(vec3(
		-sin(world_pos.x * wave_scale + t) * wave_scale * wave_height,
		1.0,
		-cos(world_pos.z * wave_scale + t) * wave_scale * wave_height
	));
}

void fragment() {
	vec3 view_dir = normalize(CAMERA_POSITION - (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz);
	vec3 normal = normalize(NORMAL);
	
	// Light direction
	vec3 light_dir = normalize(vec3(0.5, 1.0, 0.3));
	
	// Diffuse lighting
	float diff = max(dot(normal, light_dir), 0.2);
	
	// Base color with diffuse
	vec3 final_color = water_color.rgb * diff;
	
	// Specular highlights
	float spec = pow(max(dot(reflect(-light_dir, normal), view_dir), 0.0), 64.0);
	final_color += vec3(1.0) * spec * 0.6;
	
	ALBEDO = final_color;
	ALPHA = water_color.a;
	TRANSMISSION = 0.1;
	SPECULAR = 0.8;
	ROUGHNESS = 0.2;
}
