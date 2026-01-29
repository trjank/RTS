class_name Explosion extends Object

const SHATTER := {
	"color_primary": Color(),
	"color_secondary": Color(),
	"fireball_intensity": 0.0,
	"shockwave_force": 1.0,
	"num_shockwaves": 1.0,
}
const DULL := {
	"color_primary": Color(1.0, 0.35, 0.0),
	"color_secondary": Color(),
	"fireball_intensity": 15.0,
	"shockwave_force": 0.2,
	"num_shockwaves": 0.5,
}
const BRIGHT := {
	"color_primary": Color(1.0, 0.0, 0.0),
	"color_secondary": Color(1.0, 0.73, 0.38),
	"fireball_intensity": 15.0,
	"shockwave_force": 0.8,
	"num_shockwaves": 1.3,
}
const GRAVITY := {
	"color_primary": Color(1.0, 0.0, 1.0, 1.0),
	"color_secondary": Color(0.4, 0.12, 0.4, 1.0),
	"fireball_intensity": 50.0,
	"shockwave_force": 0.5,
	"num_shockwaves": 1.1,
}
const NEUTRON := {
	"color_primary": Color(0.0, 1.0, 0.98, 1.0),
	"color_secondary": Color(0.16, 0.2, 0.3, 1.0),
	"fireball_intensity": 500.0,
	"shockwave_force": 0.0,
	"num_shockwaves": 0.8,
}
const WARP := {
	"color_primary": Color(),
	"color_secondary": Color(0.31, 0.72, 0.16, 1.0),
	"fireball_intensity": 5.0,
	"shockwave_force": 0.18,
	"num_shockwaves": 1.0,
}
const MATERIAL := preload("res://explosion/explosion.tres")

static func explode(node: Node2D, parameters: Dictionary, force := 1.0, explosion_duration := 1.0, implosion_duration := 0.0) -> Signal:
	assert(implosion_duration <= explosion_duration)
	#
	node.material = MATERIAL
	node.set_instance_shader_parameter("force", force)
	node.set_instance_shader_parameter("time_start", Time.get_ticks_msec() / 1000.0)
	node.set_instance_shader_parameter("time_scale", PI / explosion_duration)
	node.set_instance_shader_parameter("color_primary", parameters["color_primary"] )
	node.set_instance_shader_parameter("color_secondary", parameters["color_secondary"] )
	node.set_instance_shader_parameter("fireball_intensity", parameters["fireball_intensity"] )
	node.set_instance_shader_parameter("shockwave_force", parameters["shockwave_force"] )
	node.set_instance_shader_parameter("num_shockwaves", parameters["num_shockwaves"] )
	return node.get_tree().create_timer(explosion_duration + implosion_duration).timeout
