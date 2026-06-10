shader_type spatial;

uniform sampler2D height_map;
uniform sampler2D emission_map;
uniform sampler2D alpha_map;

instance uniform float height_variation: hint_range(0.0, 1.0) = 0.0;
instance uniform float speed: hint_range(0.0, 1.0) = 0.0;
instance uniform float alpha_threshold: hint_range(0.0, 1.0) = 0.0;
instance uniform float emission_threshold: hint_range(0.0, 1.0) = 0.0;
instance uniform vec3 emission_color: source_color;

varying float height;

void vertex() {
	height = height_variation * texture(height_map, UV + speed * TIME).x;
	VERTEX += height * NORMAL;
}

void fragment() {
	EMISSION = step(emission_threshold, texture(emission_map, UV).r) * emission_color;
	ALBEDO = vec3(1.0 - height);
	ALPHA = step(alpha_threshold, texture(alpha_map, UV).r);
}