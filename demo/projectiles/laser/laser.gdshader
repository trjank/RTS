shader_type spatial;

render_mode unshaded;

uniform sampler2D noise_texture;
uniform float interior_start_ratio: hint_range(0.0, 1.0) = 0.5;

instance uniform vec3 inner_color: source_color;
instance uniform vec3 outer_color: source_color;
instance uniform float speed = 1.0;
instance uniform float width = 0.2;
instance uniform float uv_ratio = 1.0;
instance uniform float volatility = 0.5;

void fragment() {
	float x = abs(UV.x - 0.5);
	vec2 uv = vec2(UV.x - speed * TIME * sign(UV.x - 0.5), UV.y * uv_ratio);
	x += volatility * (0.5 - texture(noise_texture, uv).r);
	float exterior = smoothstep(interior_start_ratio * width, width, x);
	ALBEDO = mix(inner_color, outer_color, exterior);
	ALPHA = step(x, width);
}
