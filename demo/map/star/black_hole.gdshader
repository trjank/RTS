shader_type spatial;

render_mode unshaded;

#define DISTORT_BACKGROUND false

const float ANIMATION_PERIOD = 1.0;
const float G_M = 0.1;
const float SCHWARZCHILD_RADIUS = 0.1;
const float MIN_DT = 0.2 * SCHWARZCHILD_RADIUS;
const float MAX_DT = 1.0 * SCHWARZCHILD_RADIUS;
const float ACCRETION_DISK_OUTER_RADIUS = 0.5;
const float ACCRETION_DISK_INNER_RADIUS = 0.18;
// KEEP THIS AS SMALL AS POSSIBLE (HUGE PERFORMANCE IMPACT)
const int NUM_TIME_STEPS = 32;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform sampler2D accretion_disk_texture;

instance uniform vec3 accretion_disk_light_color: source_color = vec3(0.0, 1.0, 5.0);
instance uniform float accretion_disk_start_rotation = 0.0;
instance uniform float accretion_disk_rotation_speed: hint_range(-1.0, 1.0) = 1.0;
instance uniform float accretion_disk_light_dropoff: hint_range(2.0, 10.0) = 4.0;

varying vec3 local_position;
varying vec3 local_camera_position;

struct LightRay {
	vec3 previous_position;
	vec3 position;
	vec3 velocity;
	float r;
	float dt;
};

vec2 rotate_2d(vec2 position, float theta) {
	float cos_theta = cos(theta);
	float sin_theta = sin(theta);
	mat2 rotation_matrix = mat2(vec2(cos_theta, sin_theta), vec2(-sin_theta, cos_theta) );
	return rotation_matrix * position;
}

LightRay raymarch(LightRay ray) {
	ray.previous_position = ray.position;
	ray.r = length(ray.position);
	// Use smaller time steps closer to the event horizon
	ray.dt = clamp(ray.r * 0.1, MIN_DT, MAX_DT);
	// Use Newtonian gravity approximation and integration for performance
	vec3 acceleration = -G_M * ray.position / (ray.r * ray.r * ray.r);
	ray.velocity += acceleration * ray.dt;
	ray.position += ray.velocity * ray.dt;
	return ray;
}

vec3 calculate_accretion_disk_light(vec2 xy, float r) {
	// Here we stitch two oscillators together to make a seamless rotation animation
	// This is necessary because the inner accretion disk rotates faster,
	// causing the texture to shear and look vastly different
	float t1 = mod(TIME, ANIMATION_PERIOD);
	float t2 = mod(TIME + 0.5 * ANIMATION_PERIOD, ANIMATION_PERIOD);
	float orbital_velocity = sqrt(G_M / (r * r * r) );
	vec2 xy1 = rotate_2d(xy, (accretion_disk_start_rotation + accretion_disk_rotation_speed * t1) * orbital_velocity);
	vec2 xy2 = rotate_2d(xy, (accretion_disk_start_rotation + accretion_disk_rotation_speed * t2) * orbital_velocity);
	float brightness1 = texture(accretion_disk_texture, xy1).r;
	float brightness2 = texture(accretion_disk_texture, xy2).r;
	float brightness = mix(brightness1, brightness2, 0.5 + 0.5 * cos( (TAU / ANIMATION_PERIOD) * t1) );
	// Make the light brighter on the inner disk compared to outer disk
	// The inner disk rotates quicker, is hotter, and has a stronger glow
	brightness *= pow(r / ACCRETION_DISK_INNER_RADIUS, -accretion_disk_light_dropoff) - pow(0.5 / ACCRETION_DISK_INNER_RADIUS, -accretion_disk_light_dropoff);
	return accretion_disk_light_color * brightness;
}

bool hit_accretion_disk(vec3 ray_from, vec3 ray_to) {
	// NOTE: The accretion disk lies entirely on the plane y = 0
	return ray_from.y * ray_to.y > 0.0;
}

vec3 intersect_accretion_disk(vec3 ray_from, vec3 ray_to, vec3 albedo) {
	if (hit_accretion_disk(ray_from, ray_to) ) return albedo;
	// Calculate the exact intersection point (without this, the disk looks blocky)
	float t_intersect = ray_from.y / (ray_from.y - ray_to.y);
	vec3 intersection = mix(ray_from, ray_to, t_intersect);
	float r = length(intersection);
	bool intersected = SCHWARZCHILD_RADIUS < r && r <= ACCRETION_DISK_OUTER_RADIUS;
	return intersected ? albedo + calculate_accretion_disk_light(vec2(intersection.x, intersection.z), r) : albedo;
}

void vertex() {
	local_position = VERTEX;
	local_camera_position = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0) ).xyz;
}

void fragment() {
	ALPHA = 1.0;
	ALBEDO = vec3(0.0);
	LightRay ray;
	ray.position = local_position;
	ray.velocity = normalize(local_position - local_camera_position);
	//
	for (int i = 0; i < NUM_TIME_STEPS; ++i) {
		ray = raymarch(ray);
		ALBEDO = intersect_accretion_disk(ray.previous_position, ray.position, ALBEDO);
		if (ray.r <= SCHWARZCHILD_RADIUS) break;
	}
	if (ray.r > SCHWARZCHILD_RADIUS) {
		// NOTE: This will not render transparent objects behind the black hole
		// Unfortunately, there is no easy fix because transparent objects are handled later in the pipeline
	#if DISTORT_BACKGROUND
		vec3 world_direction = normalize(MODEL_MATRIX * vec4(ray.velocity, 0.0) ).xyz;
		vec3 view_direction = normalize(VIEW_MATRIX * vec4(world_direction, 0.0) ).xyz;
		//vec2 distortion = 0.05 * (MODEL_MATRIX * vec4(ray.velocity, 0.0)).xy;
		vec2 distortion = 0.1 * view_direction.xy / abs(view_direction.z);
		ALBEDO += texture(SCREEN_TEXTURE, SCREEN_UV + distortion).rgb;
	#else
		ALBEDO += texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	#endif
	}
}