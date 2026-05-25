shader_type spatial;

uniform vec3 flat_color : source_color;
uniform vec3 steep_color : source_color;
uniform vec3 shore_color : source_color;
uniform sampler2D biome_texture;

varying float flatness;
varying float height;

varying vec3 uv1_triplanar_pos;

uniform float uv1_blend_sharpness : hint_range(0.0, 150.0, 0.001);
varying vec3 uv1_power_normal;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

void vertex() {
	flatness = smoothstep(0.7, 0.9, dot(NORMAL, normalize(VERTEX) ));
	height = length(VERTEX);

	uv1_power_normal = pow(abs(NORMAL), vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

void fragment() {
	if (height < 4.12) {
		ALBEDO = shore_color;
	} else {
		ALBEDO = mix(steep_color, flat_color, flatness);
	}
	ALBEDO *= triplanar_texture(biome_texture, uv1_power_normal, uv1_triplanar_pos).rgb;
}