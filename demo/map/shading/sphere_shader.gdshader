shader_type canvas_item;

uniform sampler2D shadow_map;
uniform mat2 inv_rot;
uniform float global_darkness: hint_range(0.0, 1.0);

const vec2 CENTER = vec2(0.5);

void fragment() {
	vec2 shadow_UV = inv_rot * (UV - CENTER) + CENTER;
	vec4 shadow = texture(shadow_map, shadow_UV);
	float darkness = global_darkness * shadow.a;
	COLOR.rgb = mix(COLOR.rgb, shadow.rgb, darkness);
}
