shader_type spatial;

render_mode unshaded;

const float NO_DIV_ZERO = 0.01;
const vec2 TEXTURE_SCALE = vec2(1.0, 0.01);

uniform sampler2D particle_texture: repeat_enable;

instance uniform float speed = 1.0;
instance uniform float cohesion: hint_range(0.0, 1.0) = 1.0;
instance uniform float alpha: hint_range(0.0, 1.0) = 1.0;
instance uniform vec3 start_color: source_color;
instance uniform vec3 end_color: source_color;

void fragment() {
	float edge_distance = 1.0 - 2.0 * abs(UV.x - 0.5);
	// Stretch the texture out to create lines instead of blobs
	vec2 uv = TEXTURE_SCALE * UV + vec2(0.0, speed * TIME);
	float particle = texture(particle_texture, uv).r;
	// Make a gradient from start_color at bottom and end_color at the top
	ALBEDO = mix(end_color, start_color, particle * UV.y);
	ALPHA = edge_distance * mix(particle, 1.0, cohesion);
	ALPHA = UV.y * pow(ALPHA, 1.0 / (NO_DIV_ZERO + alpha) );
}