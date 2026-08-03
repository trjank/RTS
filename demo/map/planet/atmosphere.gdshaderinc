render_mode depth_draw_never, cull_back, fog_disabled;

#ifndef ATMOSPHERE_DEPTH_IS_CONSTANT
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;
#endif

uniform float glint: hint_range(0.0, 0.1) = 0.02;
uniform float glint_concentration: hint_range(0.0, 100.0) = 10.0;
uniform vec3 direct_light_color: source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 indirect_light_color: source_color = vec3(1.0, 0.0, 0.0);

instance uniform float rim_strength: hint_range(0.0, 10.0) = 0.0;
instance uniform float density: hint_range(0.0, 10.0) = 1.0;
instance uniform vec3 color: source_color = vec3(1.0, 1.0, 1.0);

float to_world_depth(float depth, vec2 screen_uv, mat4 inv_projection_matrix) {
	// NOTE: These normalized coordinates are only for the Forward+ renderer
	vec3 normalized_device_coordinates = vec3(2.0 * screen_uv - 1.0, depth);
	vec4 view = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);
	return -view.z / view.w;
}

void fragment() {
#ifdef ATMOSPHERE_DEPTH_IS_CONSTANT
	float atmosphere = density;
#else
	float mesh_depth = to_world_depth(texture(DEPTH_TEXTURE, SCREEN_UV).x, SCREEN_UV, INV_PROJECTION_MATRIX);
	float atmosphere_depth = to_world_depth(FRAGCOORD.z, SCREEN_UV, INV_PROJECTION_MATRIX);
	float light_travel_depth = mesh_depth - atmosphere_depth;
	// The further light has to travel, the thicker the atmosphere
	float atmosphere = 1.0 - exp(-light_travel_depth * density);
#endif
	// More light is reflected at the edges (this is the Fresnel effect)
	float rim_intensity = rim_strength * exp(-dot(NORMAL, VIEW) * rim_strength);
	ALBEDO = color * (atmosphere + rim_intensity);
	ALPHA = max(atmosphere, 0.0);
}

void light() {
	float intensity = max(dot(LIGHT, NORMAL), 0.0);
	vec3 scatter_light = intensity * mix(indirect_light_color, direct_light_color, intensity);
	vec3 glint_light = glint * pow(intensity, glint_concentration) * LIGHT_COLOR;
	DIFFUSE_LIGHT += ATTENUATION * (scatter_light + glint_light);
}