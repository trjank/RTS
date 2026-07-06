shader_type spatial;

render_mode unshaded, fog_disabled, depth_test_disabled;

uniform float shadow_darkness: hint_range(0.0, 1.0) = 0.5;
uniform float shadow_start: hint_range(0.0, 1.0) = 0.5;

instance uniform vec3 border_color: source_color = vec3(1.0);
instance uniform vec3 base_color: source_color = vec3(0.0);
instance uniform vec3 pip_color: source_color = vec3(1.0, 0.0, 0.0);
instance uniform vec2 size = vec2(1.0);
instance uniform float border_width: hint_range(0.0, 1.0) = 0.1;
instance uniform float pip_width: hint_range(0.0, 1.0) = 0.5;
instance uniform float pip_progress: hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec2 xy = UV * size;
	xy.x = mod(xy.x, pip_width);
	// Determine how close the pixel is to the border
	bool x_border = xy.x <= border_width;
	bool y_border = xy.y <= border_width || size.y - border_width <= xy.y;
	// Determine the pip color based on pip progress and shadow
	vec3 color = UV.x <= pip_progress ? pip_color * (1.0 - shadow_darkness * step(shadow_start, UV.y) ) : base_color;
	// Draw the border
	ALBEDO = x_border || y_border ? border_color : color;
}