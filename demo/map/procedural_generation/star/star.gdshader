shader_type canvas_item;
render_mode unshaded;

#include "res://sphere.gdshaderinc"
#include "res://atmosphere.gdshaderinc"

/*---------------------------------------------------------------------|
| Author: TrueJank                                                     |
|                                                                      |
| This is a basic shader to procedurally generate stars.      |
| To avoid creating multiple noise textures, set random_offset_plasma to  |
| a vec2 with values between 0.0 and 1.0 (this gives the illusion of   |
| different noise patterns, but allows the GPU to reuse the texture).  |
|---------------------------------------------------------------------*/

const float PLASMA_SEAM = 0.01;
const float PLASMA_MOVEMENT = 0.01;

uniform sampler2D noise_plasma: repeat_enable;
uniform sampler2D noise_distortion: repeat_enable;

instance uniform vec4 color_primary: source_color;
instance uniform vec4 color_secondary: source_color;
instance uniform vec3 color_atmosphere: source_color = vec3(0.0);
instance uniform float r_atmosphere: hint_range(0.0, 0.5) = 0.45;
instance uniform float atmosphere_glow = 20.0;
instance uniform float rotation_speed = 0.0;
instance uniform float plasma_speed = 0.01;
instance uniform float plasma_glow: hint_range(1.0, 10.0) = 1.5;
instance uniform vec2 random_offset_plasma = vec2(0.0);
instance uniform vec2 distortion_origin = vec2(0.5);

void fragment() {
	vec2 distortion_offset = UV - distortion_origin;
	vec2 distortion = texture(noise_distortion, UV - plasma_speed * TIME * sign(distortion_offset) ).xy - 0.5;
	distortion *= PLASMA_MOVEMENT * smoothstep(0.0, PLASMA_SEAM, abs(distortion_offset.x * distortion_offset.y) );
	// Distort the projection
	Projection projection = project_to_sphere(UV + distortion, r_atmosphere);
	// Rotate around the y axis
	projection.uv.x -= rotation_speed * TIME;
	float plasma = texture(noise_plasma, projection.uv + random_offset_plasma).r;
	COLOR = plasma_glow * mix(color_primary, color_secondary, plasma);
	COLOR = create_atmosphere(COLOR, color_atmosphere, projection.r, r_atmosphere, STANDARD_MAX_RADIUS, atmosphere_glow);
}