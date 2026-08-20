shader_type spatial;

render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
//uniform sampler2D distortion_curve;

varying float distortion;

void vertex() {
	distortion = INSTANCE_CUSTOM.x;
}

void fragment() {
	const float ASPECT_RATIO = VIEWPORT_SIZE.y / VIEWPORT_SIZE.x;
	vec2 direction = VERTEX.xy * vec2(ASPECT_RATIO, -1.0);
	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV - distortion * direction).rgb;
	//vec2 normal = normalize(NORMAL).xy;
	//float radius = dot(normalize(NORMAL), VIEW);
	//float distortion = texture(distortion_curve, vec2(radius, 0.0) ).x;
	//vec2 offset = distortion_strength * distortion * normalize(normal);
	//ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV + offset).rgb;
}