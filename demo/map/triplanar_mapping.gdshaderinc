// This is Godot's default implementation
vec3 to_uv_power_normal(vec3 normal, float uv_blend_sharpness) {
	vec3 uv_power_normal = pow(abs(normal), vec3(uv_blend_sharpness) );
	uv_power_normal /= dot(uv_power_normal, vec3(1.0) );
	return uv_power_normal;
}
// This is Godot's default implementation
vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 sample = vec4(0.0);
	sample += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	sample += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	sample += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0) ) * p_weights.x;
	return sample;
}