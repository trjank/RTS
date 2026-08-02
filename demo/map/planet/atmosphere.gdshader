shader_type spatial;

// NOTE: This must NEVER write to the depth buffer to use depth-based effects
render_mode fog_disabled, depth_draw_never, cull_back;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;
uniform float glint: hint_range(0.0, 0.1) = 0.02;
uniform float glint_concentration: hint_range(0.0, 100.0) = 10.0;
uniform vec3 direct_light_color: source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 indirect_light_color: source_color = vec3(1.0, 0.0, 0.0);

instance uniform vec3 atmosphere_color : source_color = vec3(1.0, 1.0, 1.0);
instance uniform float rim_strength : hint_range(0.0, 10.0) = 0.0;
instance uniform float density : hint_range(0.0, 10.0) = 1.0;

float to_world_depth(float depth, vec2 screen_uv, mat4 inv_projection_matrix) {
	// Normalized device coordinates (NDC) depends on the renderer
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec3 ndc = vec3(screen_uv, depth) * 2.0 - 1.0;
#else
	vec3 ndc = vec3(2.0 * screen_uv - 1.0, depth);
#endif
	vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
	return -view.z / view.w;
}

void fragment() {
	float mesh_depth = to_world_depth(texture(DEPTH_TEXTURE, SCREEN_UV).x, SCREEN_UV, INV_PROJECTION_MATRIX);
	float atmosphere_depth = to_world_depth(FRAGCOORD.z, SCREEN_UV, INV_PROJECTION_MATRIX);
	float light_travel_depth = mesh_depth - atmosphere_depth;
	// The further light has to travel, the thicker the atmosphere
	float atmosphere = 1.0 - exp(-light_travel_depth * density);
	// More light is reflected at the edges (this is the Fresnel effect)
	float rim_intensity = rim_strength * exp(-dot(NORMAL, VIEW) * rim_strength);
	ALBEDO = atmosphere_color * (atmosphere + rim_intensity);
	ALPHA = max(atmosphere, 0.0);
}

void light() {
	float intensity = max(dot(LIGHT, NORMAL), 0.0);
	DIFFUSE_LIGHT = mix(indirect_light_color, direct_light_color, intensity) * intensity;
	DIFFUSE_LIGHT += glint * pow(intensity, glint_concentration) * LIGHT_COLOR;
}