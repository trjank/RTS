shader_type spatial;

render_mode blend_mix, depth_draw_never, cull_back;

uniform vec4 albedo : source_color;
uniform sampler2D wave_texture;

void vertex() {
	VERTEX *= 1.0 + 0.01 * cos(TIME + 100.0 * NORMAL.x * NORMAL.y);
}

void fragment() {
	ALBEDO = albedo.rgb;
	//ALBEDO *= texture(wave_texture, UV).rgb;
	ALPHA = albedo.a;
}