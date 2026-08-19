class_name Flamethrower extends Area3D

const COLLISION_MASK: int = Globals.Layer.SHIPS
const COLLISION_LAYER: int = Globals.Layer.NONE
const MIN_PITCH_SCALE := 0.01

@export var mesh: MeshInstance3D
@export var hitbox: CollisionShape3D
@export var sound_effect: AudioStreamPlayer3D

var data: FlamethrowerData:
	set = set_data
var modifiers := WeaponModifiers.NONE:
	set = set_modifiers
var player_owner: Player
var length := 0.0:
	set = set_length
var excluded: Array[Target] = []

var _burn_countdown := 0.0

static func create() -> Flamethrower:
	return preload("res://projectiles/flamethrower/flamethrower.tscn").instantiate()

func _ready() -> void:
	collision_mask = COLLISION_MASK
	collision_layer = COLLISION_LAYER

func get_burn_countdown() -> float:
	return _burn_countdown

func set_modifiers(new_modifiers: WeaponModifiers) -> void:
	modifiers = new_modifiers if new_modifiers != null else WeaponModifiers.NONE

func set_data(new_data: FlamethrowerData) -> void:
	if new_data == null:
		return queue_free()
	data = new_data
	hitbox.shape.size = Vector3(data.thickness, data.thickness, 0.0)
	mesh.scale = Vector3(data.thickness, 1.0, data.effective_range)
	update_shader()
	randomize_flame()

func set_length(new_length: float) -> void:
	var burn_ratio := _burn_countdown / data.lifetime_sec
	length = clampf(new_length, 0.0, data.effective_range)
	hitbox.shape.size.z = length
	hitbox.position.z = -0.5 * length
	sound_effect.pitch_scale = MIN_PITCH_SCALE + data.pitch_scale * sqrt(burn_ratio)
	mesh.set_instance_shader_parameter("uv_length", length / data.effective_range)
	mesh.set_instance_shader_parameter("alpha", burn_ratio)

func burn() -> void:
	_burn_countdown = data.lifetime_sec

func reset() -> void:
	length = 0.0
	stop_sound_effect()

func stop_sound_effect() -> void:
	sound_effect.stop()

func play_sound_effect() -> void:
	if not sound_effect.playing:
		sound_effect.play()

func hit(target: Target, dt: float) -> void:
	if target != null and not target in excluded:
		data.hit(target, player_owner, modifiers, dt)

func _physics_process(dt: float) -> void:
	if _burn_countdown <= 0.0:
		return reset()
	for node in get_overlapping_bodies():
		hit(Target.from_node(node), dt)
	length += data.speed * dt
	_burn_countdown = maxf(_burn_countdown - dt, 0.0)
	play_sound_effect()

func randomize_flame() -> void:
	mesh.set_instance_shader_parameter("random_offset", randf() )

func update_shader() -> void:
	mesh.set_instance_shader_parameter("start_color", data.glow * data.start_color)
	mesh.set_instance_shader_parameter("end_color", data.glow * data.end_color)
	mesh.set_instance_shader_parameter("uv_speed", data.speed / data.effective_range)
	mesh.set_instance_shader_parameter("uv_ratio", data.effective_range / data.thickness)
	mesh.set_instance_shader_parameter("volatility", data.volatility)
	mesh.set_instance_shader_parameter("texture_scale", data.particulates)
