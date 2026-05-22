shader_type canvas_item;

#include "res://map/procedural_generation/sphere.gdshaderinc"

/*---------------------------------------------------------------------|
| Author: TrueJank                                                     |
|                                                                      |
| This is a basic shader to procedurally generate cratered moons.      |
| To avoid creating multiple noise textures, set random offsets to     |
| vec2's with values between 0.0 and 1.0 (this gives the illusion of   |
| different noise patterns, but allows the GPU to reuse the texture).  |
|---------------------------------------------------------------------*/

const float CRATER_SHARPNESS = 0.7;
const float DISCOLORATION = 0.5;

uniform sampler2D noise_shade: repeat_enable;
uniform sampler2D noise_crater_large: repeat_enable;
uniform sampler2D noise_crater_small: repeat_enable;
uniform sampler2D fault_noise: repeat_enable;

instance uniform float rotation_speed = 0.0;
instance uniform vec3 color: source_color = vec3(1.0);
instance uniform vec2 random_offset_crater = vec2(0.0);
instance uniform vec2 random_offset_fault = vec2(0.0);
instance uniform vec2 random_offset_shade = vec2(0.0);

void light() {
	LIGHT = shade_sphere(UV, LIGHT, LIGHT_ENERGY, LIGHT_COLOR, LIGHT_DIRECTION.xy);
}

void fragment() {
	Projection projection = project_to_sphere(UV, STANDARD_MAX_RADIUS);
	// Rotate around y axis
	projection.uv.x -= rotation_speed * TIME;
	// Layer the noise textures
	float crater_large = texture(noise_crater_large, projection.uv + random_offset_crater).r;
	float crater_small = texture(noise_crater_small, projection.uv - random_offset_crater).r;
	COLOR.rgb = DISCOLORATION * texture(noise_shade, projection.uv + random_offset_shade).rgb;
	COLOR.rgb += CRATER_SHARPNESS * color * (crater_large + crater_small);
	COLOR.rgb *= texture(fault_noise, projection.uv + random_offset_fault).r;
	// Maintain a circular boundary for the "sphere"
	COLOR.a = step(projection.r, STANDARD_MAX_RADIUS);
}