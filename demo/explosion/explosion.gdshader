shader_type spatial;

render_mode unshaded;

uniform sampler2D height_map;
uniform float min_radius: hint_range(0.0, 1.0) = 0.5;

instance uniform float smoke: hint_range(0.0, 50.0) = 1.0;
instance uniform float height_variation: hint_range(0.0, 1.0) = 1.0;
instance uniform float speed: hint_range(0.0, 1.0) = 0.0;
instance uniform float alpha_threshold: hint_range(0.0, 1.0) = 0.0;
instance uniform vec3 color: source_color;
instance uniform vec2 random_offset = vec2(0.0);

varying float height;

void vertex() {
	vec2 uv = UV + speed * TIME * NORMAL.xy + random_offset;
	height = height_variation * texture(height_map, uv).r;
	VERTEX = 0.5 * mix(height, 1.0, min_radius) * NORMAL;
}

void fragment() {
	ALBEDO = color * exp(-smoke * height);
	ALPHA = min(length(ALBEDO), 1.0);
	//ALPHA = step(alpha_threshold, height);
}