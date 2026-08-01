shader_type spatial;

#include "res://map/triplanar_mapping.gdshaderinc"

uniform float uv_blend_sharpness : hint_range(0.0, 150.0, 0.001);
uniform float distortion_speed : hint_range(0.0, 3.0) = 0.3;
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.3;
uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform sampler3D distortion_noise;

instance uniform float emission_energy : hint_range(0.0, 100.0, 0.01) = 1.0;
instance uniform vec3 emission_color_primary : source_color = vec3(1.0, 0.0, 0.0);
instance uniform vec3 emission_color_secondary : source_color = vec3(1.0);

varying vec3 uv_power_normal;
varying vec3 uv_triplanar_pos;

void vertex() {
	uv_power_normal = to_uv_power_normal(NORMAL, uv_blend_sharpness);
	uv_triplanar_pos = VERTEX;
	uv_triplanar_pos *= 1.0 + distortion_strength * texture(distortion_noise, VERTEX + distortion_speed * TIME).xyz;
}

void fragment() {
	SPECULAR = 0.0;
	ALBEDO = vec3(0.0);
	float emission = triplanar_texture(texture_emission, uv_power_normal, uv_triplanar_pos).r;
	EMISSION = mix(emission_color_primary, emission_color_secondary, emission) * emission_energy;
}
