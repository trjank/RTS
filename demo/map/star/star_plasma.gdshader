shader_type canvas_item;

//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float warping: hint_range(0.0, 1.0);
uniform sampler2D warp_x;
uniform sampler2D warp_y;
uniform float speed = 3.0;

const vec2 CENTER = vec2(0.5, 0.5);
const vec3 WHITE = vec3(1.0);

void fragment() {
	float d_from_edge = 0.5 - length(UV - CENTER);
	//vec2 distortion = vec2(warping) * sin(3.0 * TIME + 10.0 * d_from_edge * UV.x * UV.y);
	vec2 distortion = 3.0 * vec2(warping) * sin(TIME + 3.0 * texture(warp_x, UV).r + 3.0 * texture(warp_y, UV).r);
	distortion.x *= 0.5 - texture(warp_x, UV).r;
	distortion.y *= 0.5 - texture(warp_y, UV).r;
	COLOR = texture(TEXTURE, UV + distortion * d_from_edge);
	COLOR.rgb = mix(COLOR.rgb, WHITE, exp(-10.0 * d_from_edge));
}