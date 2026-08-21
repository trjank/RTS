class_name Shockwaves extends DynamicMultimesh

const MAX_AGE := 1.0

static func create() -> Shockwaves:
	return preload("res://shockwave/shockwaves.tscn").instantiate()

func _new_instance() -> ShockwaveInstance:
	return ShockwaveInstance.new()

func create_instance() -> ShockwaveInstance:
	return super()

func create_shockwave_at(at: Vector3) -> ShockwaveInstance:
	return create_shockwave(Transform3D(Basis.IDENTITY, at) )

func create_shockwave(init_transform := Transform3D.IDENTITY) -> ShockwaveInstance:
	var instance := create_instance()
	set_instance_transform(instance, init_transform)
	multimesh.set_instance_custom_data(instance._id, instance.get_custom_data() )
	return instance

func _process(dt: float) -> void:
	for instance in _instances:
		_animate_instance(instance, dt)
	assert(_instances.size() == multimesh.visible_instance_count)

func _animate_instance(instance: ShockwaveInstance, dt: float) -> void:
	instance.age += dt / instance.duration_sec
	if MAX_AGE <= instance.age:
		return free_instance(instance)
	resize(instance, instance.get_radius() * Vector3.ONE)
	multimesh.set_instance_custom_data(instance._id, instance.get_custom_data() )
