shader_type spatial;

render_mode blend_add;

uniform sampler2D noise : repeat_enable;

instance uniform float strength = 0.1;
instance uniform float speed = 2.0;
instance uniform float time_offset = 0.1;

void fragment() {
	vec2 noise_uv = UV - vec2(0.0, speed * (TIME + time_offset) );
	float distortion = -0.5 + texture(noise, noise_uv).r;
	COLOR = texture(TEXTURE, UV + vec2(0.0, strength * distortion) );
	COLOR.rgb *= vec3(1.0, 0.9, 0.0);
	COLOR *= 1.0 + 100.0 * step(0.1, COLOR.a);
}