shader_type canvas_item;

#include "res://map/procedural_generation/sphere.gdshaderinc"
#include "res://map/procedural_generation/atmosphere.gdshaderinc"

/*---------------------------------------------------------------------|
| Author: TrueJank                                                     |
|                                                                      |
| This is a basic shader to procedurally generate terrestrial planets. |
| To avoid creating multiple noise textures, set random_offset to a    |
| vec2 with values between 0.0 and 1.0 (this gives the illusion of     |
| different noise patterns, but allows the GPU to reuse the texture).  |
|---------------------------------------------------------------------*/

const float MOUNTAIN_POP = 1.5;
const float OCEAN_SHALLOW_SIZE = 0.03;
const float BOUNDARY_SMOOTHING = 0.05;
const vec3 MOUNTAIN_COLOR = vec3(0.9);

uniform sampler2D noise_continents: repeat_enable;
uniform sampler2D noise_mountains: repeat_enable;

instance uniform vec3 color_ocean_deep: source_color = vec3(0.0);
instance uniform vec3 color_ocean_shallow: source_color = vec3(0.0);
instance uniform vec3 color_continent: source_color = vec3(0.0);
instance uniform vec3 color_atmosphere: source_color = vec3(0.0);
instance uniform float r_atmosphere: hint_range(0.0, 0.5) = 0.45;
instance uniform float rotation_speed = 0.0;
instance uniform float atmosphere_glow = 20.0;
instance uniform float ocean_coverage: hint_range(0.0, 1.0) = 0.5;
instance uniform float ocean_depth: hint_range(1.0, 10.0) = 10.0;
instance uniform vec2 random_offset = vec2(0.0);

void light() {
	LIGHT = shade_sphere(UV, LIGHT, LIGHT_ENERGY, LIGHT_COLOR, LIGHT_DIRECTION.xy);
}

void fragment() {
	Projection projection = project_to_sphere(UV, r_atmosphere);
	// Rotate around y axis
	projection.uv.x -= rotation_speed * TIME;
	// Layer the noise textures
	float continent = texture(noise_continents, projection.uv + random_offset).r;
	float mountains = texture(noise_mountains, projection.uv - random_offset).r;
	float continent_boundary = smoothstep(ocean_coverage, ocean_coverage + BOUNDARY_SMOOTHING, continent);
	float shallowness = smoothstep(ocean_coverage - OCEAN_SHALLOW_SIZE, ocean_coverage, continent);
	COLOR.rgb = mix(color_ocean_deep, color_ocean_shallow, shallowness);
	COLOR.rgb = mix(COLOR.rgb, color_continent, continent_boundary);
	// Invert the mountain texture for oceans (this turns mountains into ridges)
	float ocean_ridges = pow(1.0 - mountains, ocean_depth);
	mountains = mix(ocean_ridges, mountains, continent_boundary);
	COLOR.rgb = mix(COLOR.rgb, MOUNTAIN_COLOR, MOUNTAIN_POP * mountains);
	// TODO: May want to add dynamic clouds
	COLOR = create_atmosphere(COLOR, color_atmosphere, projection.r, r_atmosphere, STANDARD_MAX_RADIUS, atmosphere_glow);
}