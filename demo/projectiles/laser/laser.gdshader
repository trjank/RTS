shader_type spatial;

render_mode unshaded;

uniform sampler2D noise_texture;
uniform float texture_scale = 0.3;
uniform float inner_beam_size: hint_range(0.0, 1.0) = 0.5;
uniform float softness: hint_range(0.0, 1.0) = 0.1;
uniform float fade = 0.1;

instance uniform vec3 inner_color: source_color;
instance uniform vec3 outer_color: source_color;
instance uniform float speed = 1.0;
instance uniform float volatility = 0.5;
instance uniform float alpha = 1.0;

varying flat float uv_ratio;

void vertex() {
	uv_ratio = INSTANCE_CUSTOM.x;
}

void fragment() {
	float x = 2.0 * UV.x - 1.0;
	float y = uv_ratio * UV.y;
	// Animate the shape of the edge and adjust for scale
	vec2 uv = vec2(UV.x - speed * TIME * sign(x), y);
	float edge_distance = abs(x) * (1.0 + volatility * texture(noise_texture, texture_scale * uv).r);
	// Draw the inner and outer beams
	ALBEDO = mix(inner_color, outer_color, smoothstep(inner_beam_size - softness, inner_beam_size + softness, edge_distance) );
	ALPHA = pow(alpha, fade + edge_distance) * smoothstep(1.0, 1.0 - softness, edge_distance);
}
