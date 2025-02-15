shader_type canvas_item;

uniform sampler2D elevation_map;
uniform sampler2D detail_map;
uniform vec3 primary_color;
uniform vec3 secondary_color;
uniform vec3 detail_color;

uniform vec3 atmosphere_color;
uniform float atmosphere_size : hint_range(0.0, 0.5);

const float BASE_ATMOSPHERE_FADE = 3.0;
const float MAX_RADIUS = 0.5;

vec4 draw_atmosphere(float r) {
	float fade = BASE_ATMOSPHERE_FADE / atmosphere_size;
	float start_r = MAX_RADIUS - atmosphere_size;
	float height = r - start_r;
	float strength = exp(-fade * height);
	return vec4(atmosphere_color, strength);
}

vec3 generate_surface_pixel(vec2 uv, float r_proj) {
	float elevation = texture(elevation_map, uv).x;
	float detail = texture(detail_map, uv).x;
	detail *= smoothstep(0.4, 0.6, elevation);
	vec3 new_primary_color = mix(primary_color, detail_color, detail);
	return mix(secondary_color, new_primary_color, elevation);
}
