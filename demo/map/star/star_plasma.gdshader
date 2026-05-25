shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, ambient_light_disabled, specular_occlusion_disabled;

uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec3 uv_scale;
uniform vec3 uv_offset;
uniform float uv_blend_sharpness : hint_range(0.0, 150.0, 0.001);
uniform float distortion_speed : hint_range(0.0, 3.0) = 0.3;
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.3;
uniform sampler3D distortion_noise;

instance uniform float emission_energy : hint_range(0.0, 100.0, 0.01) = 3.0;
instance uniform vec3 emission_color_primary : source_color;
instance uniform vec3 emission_color_secondary : source_color;

varying vec3 uv_power_normal;
varying vec3 uv_triplanar_pos;

void vertex() {
	TANGENT = vec3(0.0, 0.0, -1.0) * abs(NORMAL.x);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(NORMAL.y);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	//
	BINORMAL = vec3(0.0, 1.0, 0.0) * abs(NORMAL.x);
	BINORMAL += vec3(0.0, 0.0, -1.0) * abs(NORMAL.y);
	BINORMAL += vec3(0.0, 1.0, 0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	// UV1 Triplanar: Enabled
	uv_power_normal = pow(abs(NORMAL), vec3(uv_blend_sharpness) );
	uv_triplanar_pos = VERTEX * uv_scale + uv_offset;
	uv_power_normal /= dot(uv_power_normal, vec3(1.0) );
	uv_triplanar_pos *= vec3(1.0, -1.0, 1.0);
	// Animated distortion effect
	uv_triplanar_pos *= 1.0 + distortion_strength * texture(distortion_noise, VERTEX + distortion_speed * TIME).xyz;
}

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0) ) * p_weights.x;
	return samp;
}

void fragment() {
	ALBEDO = vec3(0.0);
	SPECULAR = 0.0;
	//EMISSION = triplanar_texture(texture_emission, uv_power_normal, uv_triplanar_pos).rgb * emission_energy;
	float emission = triplanar_texture(texture_emission, uv_power_normal, uv_triplanar_pos).r;
	EMISSION = mix(emission_color_primary, emission_color_secondary, emission) * emission_energy;
}
