shader_type spatial;

render_mode cull_back;

#include "res://map/triplanar_mapping.gdshaderinc"

uniform sampler2D biome_texture;
uniform float slope_color_theshold: hint_range(0.0, 1.0) = 0.95;
uniform float slope_color_blend: hint_range(0.0, 1.0) = 0.1;
uniform float uv_blend_sharpness: hint_range(0.0, 1.0);

instance uniform vec3 biome_color: source_color;
instance uniform vec3 flat_color: source_color;
instance uniform vec3 steep_color: source_color;
instance uniform vec3 shore_color: source_color;
instance uniform vec3 water_color: source_color;
instance uniform float shore_height = 1.01;

varying float flatness;
varying float height;
varying flat float biome_value;

void vertex() {
	flatness = dot(NORMAL, normalize(VERTEX) );
	flatness = smoothstep(slope_color_theshold, slope_color_theshold + slope_color_blend, flatness);
	height = length(VERTEX);
	vec3 uv_power_normal = to_uv_power_normal(NORMAL, uv_blend_sharpness);
	biome_value = triplanar_texture(biome_texture, uv_power_normal, VERTEX).r;
	
	VERTEX = normalize(VERTEX) * max(height, 1.01);
}

void fragment() {
	ALBEDO = height < shore_height ? shore_color : mix(steep_color, flat_color, flatness);
	ALBEDO = mix(ALBEDO, biome_color, biome_value);
	if (height < 1.01) {
		ALBEDO = water_color;
	}
}