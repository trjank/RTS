class_name DeathRay extends MeshInstance3D

const COLLISION_MASK: int = globals.Layer.SHIPS | globals.Layer.PROJECTILES

@export var sound_effect: AudioStreamPlayer3D

var data: DeathRayData:
	set = set_data
var modifiers := WeaponModifiers.NONE:
	set = set_modifiers
var player_owner: Player

static func create() -> DeathRay:
	return preload("res://projectiles/death_ray/death_ray.tscn").instantiate()

static func axis_sorter(a: Node3D, b: Node3D, sort_axis: Vector3) -> bool:
	return a.global_position.cross(sort_axis) < b.global_position.cross(sort_axis)

func _ready() -> void:
	set_instance_shader_parameter("alpha", 1.0)

func get_ray_direction() -> Vector3:
	return -transform.basis.z

func get_global_ray_direction() -> Vector3:
	return -global_transform.basis.z

func set_modifiers(new_modifiers: WeaponModifiers) -> void:
	modifiers = new_modifiers if new_modifiers != null else WeaponModifiers.NONE

func set_data(new_data: DeathRayData) -> void:
	if new_data == null:
		return queue_free()
	data = new_data
	scale.x = data.thickness
	update_shader()

func begin_death_timer() -> void:
	create_tween().tween_property(self, "instance_shader_parameters/alpha", 0.0, data.lifetime_sec)
	get_tree().create_timer(data.lifetime_sec).timeout.connect(queue_free)

func play_sound_effect() -> void:
	sound_effect.pitch_scale = sound_effect.stream.get_length() / data.lifetime_sec
	sound_effect.play()

func move(from: Vector3, to: Vector3) -> float:
	var length := from.distance_to(to)
	global_position = from
	scale.z = length
	look_at(to)
	return length

func raycast(length: float, exclude: Array[RID] = [] ) -> Array:
	var to_node := func(collider: Dictionary) -> Node: return collider["collider"]
	#
	var shape := BoxShape3D.new()
	var query := PhysicsShapeQueryParameters3D.new()
	shape.size = Vector3(data.thickness, data.thickness, length)
	query.exclude = exclude
	query.shape = shape
	query.transform = Transform3D(basis.orthonormalized(), global_position + 0.5 * get_global_ray_direction() )
	query.collision_mask = COLLISION_MASK
	return get_world_3d().direct_space_state.intersect_shape(query, data.max_hits).map(to_node)

func sorted_raycast(length: float, exclude: Array[RID] = [] ) -> Array:
	var colliders := raycast(length, exclude)
	var sort_axis := get_global_ray_direction()
	colliders.sort_custom(axis_sorter.bind(sort_axis) )
	return colliders

func _penetrate(target: Target, multihit_modifiers: WeaponModifiers) -> void:
	data.hit(target, player_owner, multihit_modifiers)
	multihit_modifiers.add(data.multihit_modifiers)

## Returns number of objects hit
func raycast_and_hit(from: Vector3, to: Vector3, exclude: Array[RID] = [] ) -> int:
	var length := move(from, to)
	var colliders := sorted_raycast(length, exclude)
	var multihit_modifiers := modifiers.copy()
	#
	for node: Node in colliders:
		_penetrate(Target.from_node(node), multihit_modifiers)
	play_sound_effect()
	return colliders.size()

func update_shader() -> void:
	set_instance_shader_parameter("speed", data.drift_speed)
	set_instance_shader_parameter("cohesion", data.cohesion)
	set_instance_shader_parameter("start_color", data.glow * data.start_color)
	set_instance_shader_parameter("end_color", data.glow * data.end_color)
