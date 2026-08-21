shader_type spatial;

render_mode unshaded;

uniform float speed: hint_range(0.0, 1.0) = 0.0;
uniform float smoke: hint_range(0.0, 100.0) = 14.0;
uniform sampler2D height_map;

varying float height;
varying float age;
varying float fade_delay;

vec2 random_vec2(int seed) {
	return fract(sin(float(seed) * vec2(12.9898, 78.233) ) * 43758.5453123);
}

void vertex() {
	// Extract the limited data we can store per instance
	age = INSTANCE_CUSTOM.x;
	fade_delay = INSTANCE_CUSTOM.y;
	float skew = INSTANCE_CUSTOM.z;
	float volatility = INSTANCE_CUSTOM.w;
	vec2 random_offset = random_vec2(INSTANCE_ID);
	// Make the explosion non-spherical
	vec2 uv = UV + speed * TIME * NORMAL.xy + random_offset;
	height = age * texture(height_map, uv).r;
	VERTEX *= 1.0 + volatility * (2.0 * height - 1.0);
	VERTEX *= pow(1.0 - VERTEX.z, skew);
}

void fragment() {
	ALBEDO = COLOR.rgb * exp(-smoke * height);
	ALPHA = step(pow(age, fade_delay), height);
}