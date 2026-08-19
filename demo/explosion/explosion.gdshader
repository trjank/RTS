shader_type spatial;

render_mode unshaded;

uniform sampler2D height_map;
uniform float smoke: hint_range(0.0, 100.0) = 14.0;

instance uniform float age: hint_range(0.0, 1.0) = 0.0;
instance uniform float fade_delay: hint_range(1.0, 10.0) = 1.0;
instance uniform float speed: hint_range(0.0, 1.0) = 0.0;
instance uniform float volatility: hint_range(0.0, 1.0) = 1.0;
instance uniform vec2 random_offset = vec2(0.0);
instance uniform vec3 color: source_color;

varying float height;

void vertex() {
	vec2 uv = UV + speed * TIME * NORMAL.xy;
	height = age * texture(height_map, uv).r;
	VERTEX *= 1.0 + volatility * (2.0 * height - 1.0);
}

void fragment() {
	ALBEDO = color * exp(-smoke * height);
	ALPHA = step(pow(age, fade_delay), height);
}