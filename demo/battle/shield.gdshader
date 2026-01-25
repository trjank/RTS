shader_type canvas_item;

// TODO: Use per-instance parameters

uniform sampler2D noise: repeat_enable;
uniform float animation_speed;
uniform vec2 size = vec2(2.0, 1.0);
uniform float effect_strength = 0.2;

const float MAX_DISTORTION = 10.0;

void fragment() {
	vec2 aspect_fixed_uv = UV * size / length(size);
	float distortion = texture(noise, aspect_fixed_uv).r;
	float oscillator = sin(animation_speed * TIME + MAX_DISTORTION * distortion);
	float amount = texture(noise, aspect_fixed_uv + vec2(sin(TIME) * distortion)).r;
	COLOR *= mix(1.0, oscillator, effect_strength);
}