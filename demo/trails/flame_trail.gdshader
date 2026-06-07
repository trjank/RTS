shader_type spatial;

render_mode unshaded;

const float FLICKER_SPEED = 30.0;

instance uniform vec3 outer_color: source_color = vec3(2.0, 0.0, 0.0);
instance uniform vec3 inner_color: source_color = vec3(1.5, 1.5, 0.5);
instance uniform float roundness: hint_range(0.5, 2.0) = 1.0;
instance uniform float flicker_strength: hint_range(0.0, 0.2) = 0.1;
instance uniform float random_phase_offset = 0.0;

void fragment() {
	// Adjust coordinates so a UV of (0.5, 0.0) is the origin
	vec2 xy = vec2(2.0 * UV.x - 1.0, UV.y);
	float flicker = flicker_strength * sin(FLICKER_SPEED * TIME + random_phase_offset);
	float power_filter = roundness * (1.0 + flicker);
	// Take the p-norm (power of 2.0 is circular, power of 1.0 is square)
	xy = pow(abs(xy), vec2(power_filter) );
	// Points closer to a UV of (0.5, 0.0) are more intense
	float intensity = clamp(1.0 - xy.x - xy.y, 0.0, 1.0);
	ALBEDO = mix(outer_color, inner_color, intensity);
	ALPHA = intensity;
}
