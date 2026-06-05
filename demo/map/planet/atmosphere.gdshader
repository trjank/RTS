shader_type spatial;

render_mode fog_disabled, depth_draw_never, blend_add;

const float MIN_BRIGHTNESS = 0.02;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;

instance uniform vec3 atmosphere_color : source_color = vec3(1.0, 1.0, 1.0);
instance uniform float fresnel_effect_strength : hint_range(0.0, 10.0) = 1.0;
instance uniform float density : hint_range(0.0, 10.0) = 1.0;

float to_world_depth(float depth, vec2 screen_uv, mat4 inv_projection_matrix) {
	// Normalized device coordinates (NDC) depends on the renderer
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec3 ndc = vec3(screen_uv, depth) * 2.0 - 1.0;
#else
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
#endif
	vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

void fragment() {
	float mesh_depth = to_world_depth(texture(DEPTH_TEXTURE, SCREEN_UV).x, SCREEN_UV, INV_PROJECTION_MATRIX);
	float atmosphere_depth = to_world_depth(FRAGCOORD.z, SCREEN_UV, INV_PROJECTION_MATRIX);
	float light_travel_depth = mesh_depth - atmosphere_depth;
	// The atmosphere becomes thicker as light has to travel further
	float atmosphere = 1.0 - exp(-light_travel_depth * density);
	// Make the atmosphere stronger near the edges
	float fresnel_effect = pow(1.0 - dot(NORMAL, VIEW), fresnel_effect_strength);
	ALBEDO = atmosphere_color * atmosphere * fresnel_effect;
	EMISSION = vec3(MIN_BRIGHTNESS);
}