shader_type spatial;

render_mode unshaded;

#define DISTORT_BACKGROUND false

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
instance uniform float accretion_disk_rotation_speed: hint_range(-1.0, 1.0) = 0.0;
instance uniform float accretion_disk_light_dropoff: hint_range(2.0, 10.0) = 4.0;

varying vec3 local_position;
varying vec3 local_camera_position;

struct LightRay {
	vec3 position;
	vec3 velocity;
	float r;
	float dt;
};

void vertex() {
	local_position = VERTEX;
	local_camera_position = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0) ).xyz;
}

LightRay raymarch(LightRay ray) {
	ray.r = length(ray.position);
	// Use smaller time steps closer to the event horizon
	ray.dt = clamp(ray.r * 0.1, MIN_DT, MAX_DT);
	// Use Newtonian gravity approximation and integration for performance
	vec3 acceleration = -G_M * ray.position / (ray.r * ray.r * ray.r);
	ray.velocity += acceleration * ray.dt;
	ray.position += ray.velocity * ray.dt;
	return ray;
}

vec2 rotate_2d(vec2 position, float theta) {
	float cos_theta = cos(theta);
	float sin_theta = sin(theta);
	mat2 rotation_matrix = mat2(vec2(cos_theta, sin_theta), vec2(-sin_theta, cos_theta) );
	return rotation_matrix * position;
}

vec3 calculate_accretion_disk_light(vec2 xy, float r) {
	// NOTE: The use of mod makes this not a seamless transition
	float rotation = accretion_disk_start_rotation + mod(accretion_disk_rotation_speed * TIME, TAU);
	float orbital_velocity = sqrt(G_M / (r * r * r) );
	xy = rotate_2d(xy, rotation * orbital_velocity);
	float brightness = texture(accretion_disk_texture, xy).r;
	// Make the light brighter on the inner disk compared to outer disk
	// The inner disk rotates quicker, is hotter, and has a stronger glow
	brightness *= pow(r / ACCRETION_DISK_INNER_RADIUS, -accretion_disk_light_dropoff);
	return accretion_disk_light_color * brightness;
}

vec3 intersect_accretion_disk(vec3 previous_position, vec3 position, vec3 albedo) {
	// NOTE: The accretion disk lies entirely on the plane y = 0
	if (previous_position.y * position.y > 0.0)
		return albedo;
	// Calculate the exact intersection point (without this, the disk looks blocky)
	float t_intersect = previous_position.y / (previous_position.y - position.y);
	vec3 intersection = mix(previous_position, position, t_intersect);
	float r = length(intersection);
	bool intersected = SCHWARZCHILD_RADIUS < r && r <= ACCRETION_DISK_OUTER_RADIUS;
	return intersected ? albedo + calculate_accretion_disk_light(vec2(intersection.x, intersection.z), r) : albedo;
}

void fragment() {
	ALPHA = 1.0;
	ALBEDO = vec3(0.0);
	LightRay ray;
	ray.position = local_position;
	ray.velocity = normalize(local_position - local_camera_position);
	//
	for (int i = 0; i < NUM_TIME_STEPS; ++i) {
		vec3 previous_position = ray.position;
		ray = raymarch(ray);
		ALBEDO = intersect_accretion_disk(previous_position, ray.position, ALBEDO);
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