shader_type canvas_item;

#include "res://map/procedural_generation/sphere.gdshaderinc"

/*---------------------------------------------------------------------|
| Author: TrueJank                                                     |
|                                                                      |
| This is a basic shader to procedurally generate jovian planets.      |
| To avoid creating multiple noise textures, set random_offset_gas to  |
| a vec2 with values between 0.0 and 1.0 (this gives the illusion of   |
| different noise patterns, but allows the GPU to reuse the texture).  |
|---------------------------------------------------------------------*/

const float BAND_VIOLENCE = 2.0;
const float BAND_SHARPNESS = 1.0;
const float BAND_COLOR_POP = 0.5;

uniform sampler2D noise_gas: repeat_enable;

instance uniform float rotation_speed = 0.0;
instance uniform float num_bands = 3.0;
instance uniform vec3 base_color_primary: source_color = vec3(0.0);
instance uniform vec3 base_color_secondary: source_color = vec3(0.0);
instance uniform vec3 band_color_primary: source_color = vec3(0.0);
instance uniform vec3 band_color_secondary: source_color = vec3(0.0);
instance uniform vec2 random_offset_gas = vec2(0.0);

void light() {
	LIGHT = shade_sphere(UV, LIGHT, LIGHT_ENERGY, LIGHT_COLOR, LIGHT_DIRECTION.xy);
}

void fragment() {
	Projection projection = project_to_sphere(UV, STANDARD_MAX_RADIUS);
	// Rotate around y axis
	projection.uv.x -= rotation_speed * TIME;
	// Layer the colors
	float swirl = texture(noise_gas, projection.uv + random_offset_gas).r;
	float band_intensity = 0.5 + BAND_SHARPNESS * sin(num_bands * PI * UV.y + BAND_VIOLENCE * swirl);
	vec3 band_color = mix(band_color_primary, band_color_secondary, UV.y);
	band_intensity *= 1.0 + BAND_COLOR_POP * swirl;
	COLOR.rgb = mix(base_color_primary, base_color_secondary, swirl);
	COLOR.rgb = mix(COLOR.rgb, band_color, band_intensity);
	// Maintain a circular boundary for the "sphere"
	COLOR.a = step(projection.r, STANDARD_MAX_RADIUS);
}