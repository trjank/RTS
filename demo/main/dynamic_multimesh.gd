class_name DynamicMultimesh extends MultiMeshInstance3D

class Instance extends RefCounted:
	var _id := -1

@export_range(1, 100_000, 1) var max_instance_count := 1000

var _instances: Array[Instance] = []

func _ready() -> void:
	multimesh.instance_count = max_instance_count

func _new_instance() -> Instance:
	return Instance.new()

func clear() -> void:
	_instances.clear()
	multimesh.visible_instance_count = 0

func get_instance_transform(instance: Instance) -> Transform3D:
	return multimesh.get_instance_transform(instance._id)

func set_instance_transform(instance: Instance, new_transform: Transform3D) -> void:
	multimesh.set_instance_transform(instance._id, new_transform)

func resize(instance: Instance, new_scale: Vector3) -> void:
	set_instance_transform(instance, get_instance_transform(instance).orthonormalized().scaled_local(new_scale) )

func move(instance: Instance, to: Vector3) -> void:
	set_instance_transform(instance, Transform3D(get_instance_transform(instance).basis, to) )

func create_instance() -> Instance:
	if multimesh.instance_count <= _instances.size():
		return null
	var instance := _new_instance()
	instance._id = _instances.size()
	_instances.push_back(instance)
	multimesh.visible_instance_count = _instances.size()
	return instance

func free_instance(instance: Instance) -> void:
	assert(_instances[instance._id] == instance)
	# Swap and pop to keep instances packed so visible_instance_count works
	_swap_and_pop(instance)
	multimesh.visible_instance_count = _instances.size()

func _swap_and_pop(instance: Instance) -> void:
	var back: Instance = _instances.pop_back()
	if instance == back:
		return
	_swap_data(back._id, instance._id)
	back._id = instance._id
	_instances[instance._id] = back

func _swap_data(from_id: int, to_id: int) -> void:
	if multimesh.use_custom_data:
		multimesh.set_instance_custom_data(to_id, multimesh.get_instance_custom_data(from_id) )
	if multimesh.use_colors:
		multimesh.set_instance_color(to_id, multimesh.get_instance_color(from_id) )
	multimesh.set_instance_transform(to_id, multimesh.get_instance_transform(from_id) )
