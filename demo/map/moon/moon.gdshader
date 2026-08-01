shader_type spatial;

#include "res://map/triplanar_mapping.gdshaderinc"

uniform float uv_blend_sharpness: hint_range(0.0, 1.0) = 0.0;
uniform sampler2D rock_texture;

varying flat vec3 rock_color;

void vertex() {
	vec3 uv_power_normal = to_uv_power_normal(NORMAL, uv_blend_sharpness);
	rock_color = triplanar_texture(rock_texture, uv_power_normal, VERTEX).rgb;
}

void fragment() {
	ALBEDO = rock_color;
}