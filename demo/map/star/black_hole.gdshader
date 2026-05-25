shader_type spatial;

render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D distortion_curve;
uniform float horizon_radius : hint_range(0.1, 0.5);
uniform float horizon_smoothing : hint_range(0.0, 0.1);

const vec2 UV_CENTER = vec2(0.5);

void fragment() {
	vec2 radial = UV - UV_CENTER;
	float radius = length(radial);
	float darkness = smoothstep(horizon_radius, horizon_radius - horizon_smoothing, radius);
	float distortion = texture(distortion_curve, vec2(radius, 0.0) ).r;
	vec2 offset = distortion * NORMAL.xy;
	ALBEDO = darkness * texture(SCREEN_TEXTURE, SCREEN_UV + offset).rgb;
}