shader_type spatial;

uniform sampler2D biome_texture;
uniform float slope_color_theshold : hint_range(0.0, 1.0) = 0.95;
uniform float slope_color_blend : hint_range(0.0, 1.0) = 0.1;
uniform float uv_blend_sharpness : hint_range(0.0, 1.0);
uniform vec3 uv_scale;
uniform vec3 uv_offset;

instance uniform vec3 flat_color : source_color;
instance uniform vec3 steep_color : source_color;
instance uniform vec3 shore_color : source_color;
instance uniform float shore_height = 1.01;

varying float flatness;
varying float height;
varying vec3 uv_triplanar_pos;
varying vec3 uv_power_normal;

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

void vertex() {
	flatness = smoothstep(slope_color_theshold, slope_color_theshold + slope_color_blend, dot(NORMAL, normalize(VERTEX) ) );
	height = length(VERTEX);

	uv_power_normal = pow(abs(NORMAL), vec3(uv_blend_sharpness));
	uv_triplanar_pos = VERTEX * uv_scale + uv_offset;
	uv_power_normal /= dot(uv_power_normal, vec3(1.0));
	uv_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

void fragment() {
	if (height < shore_height) {
		ALBEDO = shore_color;
	} else {
		ALBEDO = mix(steep_color, flat_color, flatness);
	}
	ALBEDO *= triplanar_texture(biome_texture, uv_power_normal, uv_triplanar_pos).rgb;
}