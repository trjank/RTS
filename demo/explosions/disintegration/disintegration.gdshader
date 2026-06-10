shader_type spatial;

uniform sampler2D crack_noise;
uniform sampler2D albedo_texture;

instance uniform float fracture: hint_range(0.0, 1.0) = 0.0;
instance uniform float dust = 0.11;

void fragment() {
	float cracking = texture(crack_noise, UV).r;
	vec4 albedo = texture(albedo_texture, UV);
	ALBEDO = albedo.rgb;
	ALPHA = albedo.a * smoothstep(cracking, fracture + dust, dust);
}