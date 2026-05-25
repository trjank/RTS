shader_type spatial;

render_mode cull_disabled;

uniform sampler2D radial_noise: repeat_enable;
uniform vec4 color_primary: source_color;
uniform vec4 color_secondary: source_color;

instance uniform float random_offset: hint_range(0.0, 1.0) = 0.0;

const vec2 UV_CENTER = vec2(0.5);

void fragment() {
	float r = length(UV - UV_CENTER);
	float ring = texture(radial_noise, vec2(r + random_offset, 0.0) ).r;
	vec4 color = mix(color_primary, color_secondary, ring);
	ALBEDO = color.rgb;
	ALPHA = color.a * float(0.3 <= r && r <= 0.5);
}