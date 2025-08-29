shader_type canvas_item;

uniform sampler2D star_pattern;
uniform sampler2D nebula_pattern;
uniform sampler2D cluster_pattern;

uniform vec3 nebula_color;
uniform vec3 nebula_fade_color;
uniform vec3 nebula_var_color;
uniform float darkness_density : hint_range(0.5, 1.0);
uniform float smoothing : hint_range(0.0, 0.1);
uniform float nebula_color_variation : hint_range(0.0, 1.0);

const float COLOR_VARIATION_MULTIPLIER = 50.0;
const float POWER_FILTER = 5.0;
const vec3 BLACK = vec3(0.0);

void fragment(){
	// Draw the stars
	float darkness_start = darkness_density - smoothing;
	float darkness_end = darkness_density + smoothing;
	float brightness = texture(star_pattern, UV).r;
	brightness = pow(brightness, POWER_FILTER);
	brightness = smoothstep(darkness_start, darkness_end, brightness);
	COLOR = vec4(vec3(brightness), 1.0);
	// Draw the nebulas
	float k = COLOR_VARIATION_MULTIPLIER * nebula_color_variation;
	float color_variation = sin(UV.x * k) * sin(UV.y * k);
	float nebula_brightness = texture(nebula_pattern, UV).r;
	nebula_brightness = pow(nebula_brightness, POWER_FILTER);
	vec3 color = mix(nebula_color, nebula_var_color, color_variation);
	color = mix(nebula_fade_color, color, nebula_brightness);

	float clustering = texture(cluster_pattern, UV).r;
	clustering = smoothstep(darkness_start, darkness_end, clustering);
	color = mix(BLACK, color, clustering);

	COLOR.rgb = mix(COLOR.rgb, color, nebula_brightness);
}