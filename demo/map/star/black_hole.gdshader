shader_type spatial;

render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D distortion_curve;
uniform float horizon_size : hint_range(0.1, 1.0);
uniform float horizon_smoothing : hint_range(0.0, 0.1);

void raymarch() {
	
}

void fragment() {
	vec2 radial = normalize(NORMAL).xy;
	float radius = dot(normalize(NORMAL), VIEW);
	float darkness = smoothstep(horizon_size, horizon_size - horizon_smoothing, radius);
	float distortion = texture(distortion_curve, vec2(radius, 0.0) ).x;
	vec2 offset = distortion * normalize(radial);
	ALBEDO = darkness * texture(SCREEN_TEXTURE, SCREEN_UV + offset).rgb;
}