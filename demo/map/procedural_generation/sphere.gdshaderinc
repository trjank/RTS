/*---------------------------------------------------------------------|
| Author: TrueJank                                                     |
|                                                                      |
| These are shader functions to make 3d effects with 2d shaders.       |
| By shrinking details at the edges of a circle, we can make a flat    | 
| texture appear spherical. The custom light shader helper is an       |
| approximation that works well for medium to long distances, and adds |
| both light and shadows to maintain consistent brightness with        |
| multiple light sources.                                              |
|                                                                      |
| FOR BEST RESULTS: Use BLEND_MODE_ADD for light sources               |
|---------------------------------------------------------------------*/

const float MAX_BRIGHTNESS = 0.3;
const float MAX_DARKNESS = 0.5;
const float STANDARD_MAX_RADIUS = 0.5;
const vec2 UV_CENTER = vec2(0.5);

struct Projection {
	float r;
	vec2 uv;
	vec2 direction;
};

Projection project_to_sphere(vec2 uv, float r_max) {
	vec2 from_center = uv - UV_CENTER;
	float r = length(from_center);
	from_center /= r;
	uv = ( (1.0 / PI) * asin(r / r_max) ) * from_center + UV_CENTER;
	return Projection(r, uv, from_center);
}

vec4 shade_sphere(vec2 uv, vec4 old_light, float light_energy, vec4 light_color, vec2 light_direction) {
	float brightness = dot(uv - UV_CENTER, light_direction.xy);
	vec4 new_light = light_energy * light_color;
	new_light.a = clamp(brightness, -MAX_DARKNESS, MAX_BRIGHTNESS);
	return old_light + new_light;
}