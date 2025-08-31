shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D distortion_curve;
uniform float horizon_radius : hint_range(0.1, 0.5);
uniform float horizon_smoothing : hint_range(0.0, 0.1);

const vec2 CENTER = vec2(0.5);
const vec4 BLACK = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 radial = UV - CENTER;
	float radius = length(radial);
	float darkness = smoothstep(horizon_radius, horizon_radius - horizon_smoothing, radius);
	float distortion = texture(distortion_curve, vec2(radius)).r;
	vec2 offset = distortion * normalize(radial);
	COLOR = mix(texture(screen_texture, SCREEN_UV + offset), BLACK, darkness);
}