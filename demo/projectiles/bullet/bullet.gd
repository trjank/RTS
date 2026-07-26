class_name Bullet extends Unit

var data: BulletData:
	set = set_data

@export var sound_effect: AudioStreamPlayer3D
@export var trail: MeshInstance3D

static func create() -> Bullet:
	return preload("res://projectiles/bullet/bullet.tscn").instantiate()

func _init() -> void:
	collision_layer = globals.Layer.PROJECTILES

func set_data(new_data: BulletData) -> void:
	if new_data == null:
		return queue_free()
	data = new_data
	size = Vector2(50.0, 50.0)
	mass = data.mass
	texture = data.get_image().get_texture()
	torque = data.torque
	linear_damp = data.linear_damp
	create_trail()

func begin_death_timer() -> void:
	get_tree().create_timer(data.lifetime_sec).timeout.connect(queue_free)

func play_sound_effect() -> void:
	var min_pitch_scale := 1.0 - data.sound_variation
	var max_pitch_scale := 1.0 + data.sound_variation
	sound_effect.pitch_scale = randf_range(min_pitch_scale, max_pitch_scale)
	sound_effect.play()

func create_trail() -> void:
	trail.visible = data.trail_enabled
	trail.set_instance_shader_parameter("inner_color", data.trail_inner_color * data.trail_glow)
	trail.set_instance_shader_parameter("outer_color", data.trail_outer_color * data.trail_glow)
	trail.set_instance_shader_parameter("flicker_strength", data.trail_flicker_strength)
	trail.set_instance_shader_parameter("roundness", data.trail_roundness)
	trail.set_instance_shader_parameter("random_phase_offset", randf_range(0.0, TAU) )

func launch(inertia_velocity := Vector3.ZERO) -> void:
	linear_velocity = inertia_velocity + data.launch_velocity * get_global_forward_direction()
	play_sound_effect()

func _process(_dt: float) -> void:
	trail.scale.x = data.trail_width_ratio
	trail.scale.z = data.trail_force * get_speed()

func order_attack() -> void:
	assert(data != null)
	#
	if data.is_missile():
		track()
	else:
		attack()
