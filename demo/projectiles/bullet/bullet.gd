class_name Bullet extends Unit

const COLLISION_MASK: int = Globals.Layer.SHIPS
const COLLISION_LAYER: int = Globals.Layer.PROJECTILES

var data: BulletData:
	set = set_data
var death_explosion: ExplosionData

@export var sound_effect: AudioStreamPlayer3D

var _trail: Trail

static func create() -> Bullet:
	return preload("res://projectiles/bullet/bullet.tscn").instantiate()

func _ready() -> void:
	super()
	#
	collision_mask = COLLISION_MASK
	collision_layer = COLLISION_LAYER

func is_missile() -> bool:
	return not is_zero_approx(torque)

func get_trail() -> Trail:
	return _trail

func set_data(new_data: BulletData) -> void:
	if new_data == null:
		return queue_free()
	data = new_data
	size = Vector2(50.0, 50.0)
	mass = data.mass
	texture = data.image.get_texture()
	torque = data.torque
	linear_damp = data.linear_damp
	_create_trail()

func begin_death_timer() -> void:
	get_tree().create_timer(data.lifetime_sec).timeout.connect(kill)

func kill() -> void:
	super()
	#
	var explosion := Explosion.create()
	add_sibling(explosion)
	explosion.global_position = global_position

func order_attack() -> void:
	if is_missile():
		track()
	else:
		attack()

func play_sound_effect() -> void:
	var min_pitch_scale := 1.0 - data.sound_variation
	var max_pitch_scale := 1.0 + data.sound_variation
	sound_effect.pitch_scale = randf_range(min_pitch_scale, max_pitch_scale)
	sound_effect.play()

func launch(inertia_velocity := Vector3.ZERO) -> void:
	linear_velocity = inertia_velocity + data.launch_velocity * get_global_forward_direction()
	play_sound_effect()

func _create_trail() -> void:
	if not data.trail_enabled:
		return
	_trail = Trail.create()
	_trail.data = data.trail
	_trail.scale = Vector3(data.trail_width_ratio, 0.0, data.trail_length)
	add_child(_trail)
