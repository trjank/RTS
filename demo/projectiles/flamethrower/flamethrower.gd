class_name Flamethrower extends Area3D

@export var mesh: MeshInstance3D
@export var hitbox: CollisionShape3D
@export var sound_effect: AudioStreamPlayer3D

var data: FlamethrowerData:
	set = set_data

var _burn_countdown := 0.0
var _burn_length := 0.0
var _length := 0.0

static func create() -> Flamethrower:
	return preload("res://projectiles/flamethrower/flamethrower.tscn").instantiate()

func _ready() -> void:
	collision_layer = 0
	collision_mask = globals.Layer.SHIPS

func get_length() -> float:
	return _length

func set_data(new_data: FlamethrowerData) -> void:
	if new_data == null:
		return queue_free()
	data = new_data
	hitbox.shape.size = Vector3(data.thickness, data.thickness, 0.0)
	mesh.scale.x = data.thickness
	mesh.scale.z = data.max_range
	_update_shader()

func burn() -> void:
	_burn_countdown = data.lifetime_sec
	play_sound_effect()

func play_sound_effect() -> void:
	sound_effect.pitch_scale = sound_effect.stream.get_length() / data.lifetime_sec
	sound_effect.play()

func burn_ship(ship: Ship, dt: float) -> void:
	if ship == null or ship.is_ancestor_of(self):
		return
	ship.drain_energy(data.energy_drain * dt)
	ship.hit(data.damage * dt, null, data.shield_penetration)

func _set_burn_length(new_length: float) -> void:
	var max_burn_length := data.max_range + data.lifetime_sec * data.fade_speed
	_burn_length = clampf(new_length, 0.0, max_burn_length)
	_length = minf(_burn_length, data.max_range)
	hitbox.shape.size.z = _length
	hitbox.position.z = -0.5 * _length
	mesh.set_instance_shader_parameter("uv_length", _length / data.max_range)

func _physics_process(dt: float) -> void:
	if _burn_countdown <= 0.0:
		return _set_burn_length(_burn_length - data.fade_speed * dt)
	for node in get_overlapping_bodies():
		burn_ship(node as Ship, dt)
	_set_burn_length(_burn_length + data.speed * dt)
	_burn_countdown = maxf(_burn_countdown - dt, 0.0)

func _update_shader() -> void:
	mesh.set_instance_shader_parameter("start_color", data.glow * data.start_color)
	mesh.set_instance_shader_parameter("end_color", data.glow * data.end_color)
	mesh.set_instance_shader_parameter("uv_speed", data.speed / data.max_range)
	mesh.set_instance_shader_parameter("uv_ratio", data.max_range / data.thickness)
	mesh.set_instance_shader_parameter("volatility", data.volatility)
	mesh.set_instance_shader_parameter("random_offset", randf() )
