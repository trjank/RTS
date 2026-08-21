shader_type spatial;

render_mode unshaded;

uniform vec2 size = vec2(1.0, 1.0);
uniform sampler2D ship_texture: repeat_disable;
uniform sampler2D shield_texture;

instance uniform float shield_speed = 3.0;
instance uniform float shield: hint_range(0.0, 1.0) = 0.0;
instance uniform vec3 player_color: source_color;

vec3 draw_shield(vec3 albedo, vec2 uv) {
	float oscillator = 0.5 + 0.5 * sin(shield_speed * TIME + uv.y);
	vec3 s = texture(shield_texture, uv * size).rgb;
	return mix(albedo, shield * s, oscillator);
}

//void vertex() {
	//NORMAL = normalize(VERTEX);
//}

void fragment() {
	vec4 color = texture(ship_texture, UV);
	if (color.a < 0.5) discard;
	ALBEDO = mix(color.rgb, player_color, color.r - color.g);
	ALBEDO = draw_shield(ALBEDO, UV);
}