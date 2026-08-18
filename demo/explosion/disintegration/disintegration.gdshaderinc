uniform sampler2D crack_texture;

instance uniform float dust = 0.11;
instance uniform float fracture: hint_range(0.0, 1.0) = 0.0;

vec4 disintegrate(vec4 color, vec2 uv) {
	float crack = texture(crack_texture, uv).r;
	color.a *= smoothstep(crack, fracture + dust, dust);
	return color;
}