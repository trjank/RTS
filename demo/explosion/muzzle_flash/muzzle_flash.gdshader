shader_type spatial;

render_mode unshaded;

uniform sampler2D noise;

const float P = 2.0;

void fragment() {
	vec2 xy = pow(abs(UV - 0.5), vec2(P) );
	float d = xy.x + xy.y * UV.y;
	float dx = texture(noise, UV + TIME).r;
	d *= dx;
	ALBEDO = vec3(d, 0.0, 0.0);
	ALPHA = step(d, 0.1);
}