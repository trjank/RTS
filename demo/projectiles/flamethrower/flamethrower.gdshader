shader_type spatial;

render_mode unshaded;

const float TEXTURE_SCALE = 0.3;

uniform sampler2D flame_texture: repeat_enable;

instance uniform vec3 start_color: source_color;
instance uniform vec3 end_color: source_color;
instance uniform float uv_speed = 1.0;
instance uniform float uv_ratio = 1.0;
instance uniform float uv_length: hint_range(0.0, 1.0) = 1.0;
instance uniform float constriction: hint_range(0.0, 1.0) = 1.0;
instance uniform float volatility: hint_range(0.0, 1.0) = 0.5;
instance uniform float softness: hint_range(0.0, 1.0) = 0.5;
instance uniform float exit_roundness = 1.0;
instance uniform float random_offset = 0.0;

void fragment() {
	float x = UV.x - 0.5;
	vec2 uv = vec2(x / UV.y + 0.5 - UV.y * sin(TIME), uv_ratio * (UV.y - TIME * uv_speed + random_offset) );
	float density = texture(flame_texture, TEXTURE_SCALE * uv).r;
	// Give the flame a triangular look (more constricted at start)
	float edge = volatility * (1.0 - density);
	float edge_distance = pow(UV.y, constriction) - 2.0 * abs(x);
	ALPHA = density * smoothstep(edge, edge + softness, edge_distance);
	// Give the flame a gentle fade out, instead of abrutly disappearing
	ALPHA *= smoothstep(uv_length, uv_length - softness - exit_roundness * x * x, UV.y);
	ALBEDO = mix(start_color, end_color, UV.y) * density;
}