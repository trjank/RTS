class_name Explosion extends Object

const SHATTER := {
	"color_primary": Color(),
	"color_secondary": Color(),
	"fireball_intensity": 0.0,
	"dust": 0.11,
	"shockwave_force": 1.0,
	"num_shockwaves": 1.0,
}
const DULL := {
	"color_primary": Color(1.0, 0.35, 0.0),
	"color_secondary": Color(),
	"fireball_intensity": 15.0,
	"dust": 0.05,
	"shockwave_force": 0.5,
	"num_shockwaves": 0.5,
}
const BRIGHT := {
	"color_primary": Color(1.0, 0.0, 0.0),
	"color_secondary": Color(1.0, 0.73, 0.38),
	"fireball_intensity": 15.0,
	"dust": 0.11,
	"shockwave_force": 0.8,
	"num_shockwaves": 1.3,
}
const GRAVITY := {
	"color_primary": Color(1.0, 0.0, 1.0, 1.0),
	"color_secondary": Color(0.0, 0.122, 0.4, 1.0),
	"fireball_intensity": 50.0,
	"dust": 0.07,
	"shockwave_force": 0.95,
	"num_shockwaves": 0.5,
}
const NEUTRON := {
	"color_primary": Color(0.16, 0.2, 0.3, 1.0),
	"color_secondary": Color(0.0, 1.0, 0.98, 1.0),
	"fireball_intensity": 100.0,
	"dust": 0.0,
	"shockwave_force": 0.5,
	"num_shockwaves": 0.8,
}
const MATERIAL := preload("res://explosion/explosion.tres")

static func explode(sprite: Sprite2D, parameters: Dictionary, force := 1.0, explosion_duration := 1.0, implosion_duration := 0.0) -> Signal:
	assert(implosion_duration <= explosion_duration)
	#
	var rotation_direction := Vector2.from_angle(randf_range(0.0, TAU) )
	var size := sprite.global_scale * sprite.get_rect().size
	size /= maxf(size.x, size.y)
	#sprite.material = MATERIAL
	sprite.set_instance_shader_parameter("force", force)
	sprite.set_instance_shader_parameter("aspect_ratio", size)
	sprite.set_instance_shader_parameter("rotation_direction", rotation_direction)
	sprite.set_instance_shader_parameter("time_start", Time.get_ticks_msec() / 1000.0 - 0.3)
	sprite.set_instance_shader_parameter("time_scale", PI / explosion_duration)
	sprite.set_instance_shader_parameter("color_primary", parameters["color_primary"] )
	sprite.set_instance_shader_parameter("color_secondary", parameters["color_secondary"] )
	sprite.set_instance_shader_parameter("dust", parameters["dust"] )
	sprite.set_instance_shader_parameter("fireball_intensity", parameters["fireball_intensity"] )
	sprite.set_instance_shader_parameter("shockwave_force", parameters["shockwave_force"] )
	sprite.set_instance_shader_parameter("num_shockwaves", parameters["num_shockwaves"] )
	sprite.set_material.call_deferred(MATERIAL)
	return sprite.get_tree().create_timer(explosion_duration + implosion_duration).timeout
