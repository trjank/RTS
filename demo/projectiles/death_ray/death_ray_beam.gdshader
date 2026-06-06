shader_type spatial;

render_mode unshaded;

instance uniform vec3 outer_beam_color: source_color = vec3(0.0, 1.0, 0.0);
instance uniform vec3 inner_beam_color: source_color = vec3(1.0, 1.0, 1.0);
instance uniform float inner_beam_size: hint_range(0.0, 1.0) = 0.0;
instance uniform float volatility: hint_range(0.0, 1.0) = 0.0;
instance uniform float alpha = 1.0;

const float FLICKER_SPEED = 75.0;

void fragment() {
	// Make beam appear cylindrical by making edges more transparent
	float x = 2.0 * UV.x - 1.0;
	float depth = sqrt(1.0 - x * x);
	// Oscillate the size of the inner beam so the beam looks unstable
	float flicker = volatility * sin(FLICKER_SPEED * TIME);
	// Layer the inner and outer beams
	ALBEDO = mix(outer_beam_color, inner_beam_color, step(1.0 - depth, inner_beam_size + flicker) );
	ALPHA = alpha * depth;
}