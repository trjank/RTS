shader_type canvas_item;

uniform sampler2D radial_noise : repeat_enable;
uniform vec4 color: source_color;
uniform vec4 color2: source_color;

instance uniform float angle : hint_range(0.0, 1.6);
instance uniform float random_offset : hint_range(0.0, 1.0) = 0.0;

const vec2 UV_CENTER = vec2(0.5);
const float UV_PLANET_RADIUS = 0.25;

void fragment() {
	vec2 uv = UV - UV_CENTER;
	float r1 = length(uv);
	uv.y /= cos(angle);
	float r = length(uv);
	float ring = texture(radial_noise, vec2(r + random_offset, 0.0) ).r;
	COLOR = mix(color, color2, ring);
	COLOR.a *= float(0.3 <= r && r <= 0.5 && (UV.y > 0.5 || r1 > UV_PLANET_RADIUS) );
}

void light() {
	vec4 light = LIGHT_ENERGY * LIGHT_COLOR;
	light.a = dot(UV - UV_CENTER, LIGHT_DIRECTION.xy);
	LIGHT += light;
}