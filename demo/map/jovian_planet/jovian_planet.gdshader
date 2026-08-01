shader_type spatial;

uniform sampler2D gas_texture;

instance uniform vec3 primary_color: source_color;
instance uniform vec3 secondary_color: source_color;

void fragment() {
	float vorticity = texture(gas_texture, UV).r;
	ALBEDO = mix(primary_color, secondary_color, vorticity);
}
