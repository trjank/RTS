shader_type spatial;

uniform sampler3D colors;

void fragment() {
	ALBEDO = texture(colors, 0.5 + 0.5 * normalize(VERTEX) ).rgb;
}
