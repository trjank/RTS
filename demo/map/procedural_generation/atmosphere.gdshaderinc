/*---------------------------------------------------------------------|
| Author: TrueJank                                                     |
|                                                                      |
| This function creates a soft atmosphere around a spherical object.   |
| Make sure to project your sphere to a radius of r_start and not      |
| STANDARD_MAX_RADIUS so the edge of the atmosphere lines up with the  |
| edge of the sphere.                                                  |
|---------------------------------------------------------------------*/

const float MIN_ATMOSPHERE = 0.5;
const float ATMOSPHERE_SOFTNESS = 0.01;

vec4 create_atmosphere(vec4 old_color, vec3 atmosphere_color, float r, float r_start, float r_end, float intensity) {
	float boundary = smoothstep(r_start - ATMOSPHERE_SOFTNESS, r_start, r);
	vec4 new_color = vec4(atmosphere_color, 1.0);
	vec4 color_inside = mix(old_color, new_color, MIN_ATMOSPHERE);
	vec4 color_outside = new_color * (intensity * max(r_end - r, 0.0) );
	return mix(color_inside, color_outside, boundary);
}