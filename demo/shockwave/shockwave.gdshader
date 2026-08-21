shader_type spatial;

render_mode unshaded;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform float distribution: hint_range(0.0, 10.0) = 1.0;

instance uniform float distortion: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	const float ASPECT_RATIO = VIEWPORT_SIZE.y / VIEWPORT_SIZE.x;
	float r = dot(NORMAL, VIEW);
	vec2 direction = VERTEX.xy * vec2(ASPECT_RATIO, -1.0) * (1.0 - pow(r, distribution) );
	ALBEDO = texture(screen_texture, SCREEN_UV - distortion * direction).rgb;
}