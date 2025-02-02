shader_type canvas_item;

uniform sampler2D shadow_map;
uniform mat2 transform;
uniform float shadow_offset: hint_range(0.0, 0.5);
uniform float global_darkness: hint_range(0.0, 1.0);

const vec2 CENTER = vec2(0.5);
const vec2 AWAY_FROM_LIGHT_SOURCE = vec2(0.0, -1.0);

void fragment() {
	vec2 new_uv = transform * (UV - CENTER) + CENTER;
	new_uv += shadow_offset * AWAY_FROM_LIGHT_SOURCE;
	vec4 shadow = texture(shadow_map, new_uv);
	float darkness = global_darkness * shadow.a;
	COLOR.rgb = mix(COLOR.rgb, shadow.rgb, darkness);
}
