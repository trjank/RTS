shader_type spatial;

render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D distortion_curve;

instance uniform float distortion_strength: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 normal = normalize(NORMAL).xy;
	float radius = dot(normalize(NORMAL), VIEW);
	float distortion = texture(distortion_curve, vec2(radius, 0.0) ).x;
	vec2 offset = distortion_strength * distortion * normalize(normal);
	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV + offset).rgb;
}