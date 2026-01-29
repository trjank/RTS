shader_type canvas_item;

render_mode blend_add;

/*---------------------------------------------------------------------|
| Author: TrueJank                                                     |
|                                                                      |
| This is a shader for explosion death effects. There are two stages:  |
| explosion and implosion, although you do not have to use the         |
| implosion effect if you disable the shader or free the node in time. |
| Both stages last time_scale seconds each.                            |
|---------------------------------------------------------------------*/

uniform sampler2D crack_noise;
uniform sampler2D explosion_noise;

instance uniform float time_start = 0.0;
instance uniform float time_scale = 1.0;
instance uniform vec3 color_primary : source_color = vec3(1.0, 0.35, 0.0);
instance uniform vec3 color_secondary : source_color = vec3(0.0);
instance uniform float force = 10.0;
instance uniform float fireball_intensity = 15.0;
instance uniform float shockwave_force : hint_range(0.0, 1.0) = 0.2;
instance uniform float num_shockwaves = 0.5;

const float SHOCKWAVE_SMOOTHING = 0.1;
const float SHOCKWAVE_CLARITY = 0.5;
const float DUST = 0.11;
//          ^^^^ Set fireball_intensity to 0.0 to tweak this
const vec2 CENTER = vec2(0.5);

void vertex() {
	float time_elapsed = TIME - time_start;
	float oscillator = 0.5 - 0.5 * cos(time_scale * time_elapsed);
    VERTEX.xy *= 1.0 + force * oscillator;
}

void fragment() {
	float time_elapsed = TIME - time_start;
	float oscillator = 0.5 - 0.5 * cos(time_scale * time_elapsed);
	float oscillator_reverse = 1.0 - oscillator;
	float explosion_step = step(0.0, sin(time_scale * time_elapsed) );
	// Use noise texture to create cracks
	float cracking = texture(crack_noise, UV).r;
	COLOR *= smoothstep(cracking, oscillator + DUST, DUST) * explosion_step;
	COLOR.a *= oscillator_reverse;
	// Use noise texture to color the fireball
	vec2 dr = UV - CENTER;
	float r = length(dr);
	float color_mix = texture(explosion_noise, UV - shockwave_force * oscillator * normalize(dr) ).r;
	vec3 color = mix(color_primary, color_secondary, color_mix);
	// Propagate sine waves from the center to create shockwaves
	float shockwave_phase = (PI * num_shockwaves / oscillator) * (4.0 * r - oscillator);
	float shockwave = 1.0 - SHOCKWAVE_CLARITY + SHOCKWAVE_CLARITY * cos(shockwave_phase);
	shockwave *= smoothstep(oscillator, oscillator - SHOCKWAVE_SMOOTHING, 2.0 * r);
	COLOR = mix(COLOR, vec4(color, oscillator_reverse), fireball_intensity * shockwave);
}