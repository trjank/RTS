class_name Explosions extends DynamicMultimesh

const MAX_AGE := 1.0

static func create() -> Explosions:
	return preload("res://explosion/explosions.tscn").instantiate()

func _new_instance() -> ExplosionInstance:
	return ExplosionInstance.new()

func create_instance() -> ExplosionInstance:
	return super()

func create_explosion_at(at: Vector3, data := ExplosionData.DEFAULT) -> ExplosionInstance:
	return create_explosion(data, Transform3D(Basis.IDENTITY, at) )

func create_explosion(data := ExplosionData.DEFAULT, init_transform := Transform3D.IDENTITY) -> ExplosionInstance:
	var instance := create_instance()
	instance.data = data
	set_instance_transform(instance, init_transform)
	multimesh.set_instance_color(instance._id, instance.get_color() )
	multimesh.set_instance_custom_data(instance._id, instance.get_custom_data() )
	return instance

func _process(dt: float) -> void:
	for instance in _instances:
		_animate_instance(instance, dt)
	assert(_instances.size() == multimesh.visible_instance_count)

func _animate_instance(instance: ExplosionInstance, dt: float) -> void:
	instance.age += dt / instance.duration_sec
	if MAX_AGE <= instance.age:
		return free_instance(instance)
	resize(instance, instance.get_radius() * Vector3.ONE)
	multimesh.set_instance_custom_data(instance._id, instance.get_custom_data() )
