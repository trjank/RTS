class_name DynamicMultimesh extends MultiMeshInstance3D

class Instance extends RefCounted:
	var _id := -1

var _instances: Array[Instance] = []

func _new_instance() -> Instance:
	return Instance.new()

func clear() -> void:
	_instances.clear()
	multimesh.visible_instance_count = 0

func create_instance() -> Instance:
	if multimesh.instance_count <= _instances.size():
		return null
	var instance := _new_instance()
	instance._id = _instances.size()
	_instances.push_back(instance)
	multimesh.visible_instance_count = _instances.size()
	return instance

func _swap_and_pop(instance: Instance) -> void:
	var back: Instance = _instances.pop_back()
	if instance == back:
		return
	back._id = instance._id
	_instances[instance._id] = back

func free_instance(instance: Instance) -> void:
	assert(_instances[instance._id] == instance)
	# Swap and pop to keep instances packed so visible_instance_count works
	_swap_and_pop(instance)
	multimesh.visible_instance_count = _instances.size()
