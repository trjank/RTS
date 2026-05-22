shader_type spatial;

uniform uint major_line_tick = 5;
uniform float minor_line_thickness : hint_range(0.0, 1.0);
uniform float major_line_thickness : hint_range(0.0, 1.0);

instance uniform vec2 num_tiles = vec2(5.0);
instance uniform vec4 square_color : source_color;

void fragment() {
	vec2 xy = UV * num_tiles;
	// Offset xy so the line thickness is the same on all sides
	vec2 minor_xy = xy + vec2(0.5 * minor_line_thickness);
	vec2 major_xy = xy + vec2(0.5 * major_line_thickness);
	vec2 minor_edge_distance = step(minor_line_thickness, fract(minor_xy));
	vec2 major_edge_distance = step(major_line_thickness, mod(major_xy, float(major_line_tick)));
	// Keep the opacity of square_color when inside a grid square
	ALBEDO = square_color.rgb;
	// Set opacity to 0.0 to show the minor and major lines
	ALPHA = square_color.a;
	ALPHA *= minor_edge_distance.x * minor_edge_distance.y;
	ALPHA *= major_edge_distance.x * major_edge_distance.y;
}