shader_type spatial;

render_mode unshaded;

uniform float line_thickness : hint_range(0.0, 1.0);

instance uniform vec2 size = vec2(5.0);
instance uniform vec4 line_color : source_color;

void fragment() {
	vec2 xy = UV * size;
	float line_distance = xy.x + xy.y;
	// All stripes have the same color
	ALBEDO = line_color.rgb;
	// But adjacent stripes have different opacities
	ALPHA = line_color.a;
	ALPHA *= 0.5 + 0.5 * step(mod(line_distance, 2.0 * line_thickness), line_thickness);
}