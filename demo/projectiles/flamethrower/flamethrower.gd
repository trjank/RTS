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

func get_length() -> float:
	return _length

func set_data(new_data: FlamethrowerData) -> void:
	if new_data == null:
		return queue_free()
	data = new_data
	hitbox.shape.size = Vector3(data.thickness, data.thickness, 0.0)
	mesh.scale.x = data.thickness
	mesh.scale.z = data.max_range
	mesh.set_instance_shader_parameter("start_color", data.glow * data.start_color)
	mesh.set_instance_shader_parameter("end_color", data.glow * data.end_color)
	mesh.set_instance_shader_parameter("uv_speed", data.speed / data.max_range)
	mesh.set_instance_shader_parameter("uv_ratio", data.max_range / data.thickness)
	mesh.set_instance_shader_parameter("volatility", data.volatility)
	mesh.set_instance_shader_parameter("random_offset", randf() )

func burn() -> void:
	_burn_countdown = data.lifetime_sec
	play_sound_effect()

func play_sound_effect() -> void:
	sound_effect.pitch_scale = sound_effect.stream.get_length() / data.lifetime_sec
	sound_effect.play()

func _set_burn_length(new_length: float) -> void:
	var max_burn_length := data.max_range + data.lifetime_sec * data.fade_speed
	_burn_length = clampf(new_length, 0.0, max_burn_length)
	_length = minf(_burn_length, data.max_range)
	hitbox.shape.size.z = _length
	mesh.set_instance_shader_parameter("uv_length", _length / data.max_range)

func _physics_process(dt: float) -> void:
	if _burn_countdown <= 0.0:
		return _set_burn_length(_burn_length - data.fade_speed * dt)
	_set_burn_length(_burn_length + data.speed * dt)
	_burn_countdown = maxf(_burn_countdown - dt, 0.0)
