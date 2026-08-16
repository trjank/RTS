class_name Laser extends MultiMeshInstance3D

@export var sound_effect: AudioStreamPlayer3D

var data: LaserData:
	set = set_data
var modifiers := WeaponModifiers.NONE:
	set = set_modifiers
var player_owner: Player

static func create() -> Laser:
	return preload("res://projectiles/laser/laser.tscn").instantiate()

func _ready() -> void:
	set_instance_shader_parameter("alpha", 1.0)

func can_chain(from: Ship, to: Ship) -> bool:
	return to.is_friend(from) and from.global_position.distance_to(to.global_position) <= data.multihit_modifiers.flat_range

func set_modifiers(new_modifiers: WeaponModifiers) -> void:
	modifiers = new_modifiers if new_modifiers != null else WeaponModifiers.NONE

func set_data(new_data: LaserData) -> void:
	if new_data == null:
		return queue_free()
	data = new_data
	update_shader()

func begin_death_timer() -> void:
	create_tween().tween_property(self, "instance_shader_parameters/alpha", 0.0, data.lifetime_sec)
	get_tree().create_timer(data.lifetime_sec).timeout.connect(queue_free)

func play_sound_effect() -> void:
	sound_effect.play()

func draw_laser(i: int, from: Vector3, to: Vector3) -> void:
	assert(i < multimesh.instance_count)
	#
	var length := from.distance_to(to)
	var uv_ratio := length / data.thickness
	var mesh_scale := Vector3(data.thickness, 1.0, length)
	var mesh_basis := Basis.looking_at(to - from, Vector3.UP).scaled_local(mesh_scale)
	var mesh_transform := Transform3D(mesh_basis, from)
	multimesh.set_instance_transform(i, mesh_transform)
	multimesh.set_instance_custom_data(i, Color(uv_ratio, 0.0, 0.0, 0.0) )

func _find_targets(at: Target) -> Array[Node]:
	var close_nodes := at.find_near(can_chain)
	var num_chains := mini(close_nodes.size(), data.max_chains)
	multimesh.instance_count = 1 + num_chains
	return close_nodes

func _chain_laser(i: int, from: Target, to: Target, multihit_modifiers: WeaponModifiers) -> void:
	draw_laser(i, from.global_position, to.global_position)
	data.hit(to, player_owner, multihit_modifiers)
	multihit_modifiers.add(data.multihit_modifiers)

## Returns number of objects chained to
func multihit(from: Vector3, to: Target) -> int:
	var nodes := _find_targets(to)
	var multihit_modifiers := modifiers.copy()
	draw_laser(0, from, to.global_position)
	data.hit(to, player_owner, multihit_modifiers)
	#
	for i in nodes.size():
		_chain_laser(i + 1, to, Target.from_node(nodes[i] ), multihit_modifiers)
	play_sound_effect()
	return nodes.size()

func update_shader() -> void:
	set_instance_shader_parameter("inner_color", data.glow * data.inner_color)
	set_instance_shader_parameter("outer_color", data.glow * data.outer_color)
	set_instance_shader_parameter("speed", data.drift_speed)
	set_instance_shader_parameter("volatility", data.volatility)
