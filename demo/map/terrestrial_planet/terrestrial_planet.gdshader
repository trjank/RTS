shader_type spatial;

render_mode cull_back;

#include "res://map/triplanar_mapping.gdshaderinc"

#define STYLIZED true

uniform sampler2D biome_texture;
uniform float slope_color_theshold: hint_range(0.0, 1.0) = 0.95;
uniform float slope_color_blend: hint_range(0.0, 1.0) = 0.1;
uniform float uv_blend_sharpness: hint_range(0.0, 1.0);

instance uniform vec3 biome_color: source_color;
instance uniform vec3 flat_color: source_color;
instance uniform vec3 steep_color: source_color;
instance uniform vec3 shore_color: source_color;
instance uniform vec3 water_color: source_color;
instance uniform float shore_height = 1.02;
instance uniform float water_height = 1.01;

varying float height;
#if STYLIZED
varying flat float biome_value;
#else
varying float biome_value;
#endif

void vertex() {
	height = length(VERTEX);
	vec3 uv_power_normal = to_uv_power_normal(NORMAL, uv_blend_sharpness);
	biome_value = clamp(triplanar_texture(biome_texture, uv_power_normal, VERTEX).r, 0.0, 1.0);
	VERTEX = normalize(VERTEX) * max(height, water_height);
}

void fragment() {
#if STYLIZED
	NORMAL = -normalize(cross(dFdx(VERTEX), dFdy(VERTEX) ) );
#endif
	float flatness = dot(NORMAL, normalize(VERTEX - NODE_POSITION_VIEW) );
	flatness = smoothstep(slope_color_theshold, slope_color_theshold + slope_color_blend, flatness);
	ALBEDO = height < shore_height ? shore_color : mix(steep_color, flat_color, flatness);
	ALBEDO = height < water_height ? water_color : mix(ALBEDO, biome_color, biome_value);
}