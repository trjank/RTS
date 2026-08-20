class_name Shockwaves extends DynamicMultimesh

const MAX_SHOCKWAVE_COUNT := 1000
const SHOCKWAVE_LIFETIME := 1.0

static func create() -> Shockwaves:
	return preload("res://shockwave/shockwaves.tscn").instantiate()

func _ready() -> void:
	multimesh.instance_count = MAX_SHOCKWAVE_COUNT

func _new_instance() -> ShockwaveInstance:
	return ShockwaveInstance.new()

func create_instance() -> ShockwaveInstance:
	return super()

func create_shockwave() -> ShockwaveInstance:
	var instance := create_instance()
	multimesh.set_instance_transform(instance._id, instance.get_transform() )
	multimesh.set_instance_custom_data(instance._id, instance.get_custom_data() )
	return instance

func _process(dt: float) -> void:
	for instance in _instances:
		_animate_instance(instance, dt)
	assert(_instances.size() == multimesh.visible_instance_count)

func _animate_instance(instance: ShockwaveInstance, dt: float) -> void:
	instance.animate(dt)
	if SHOCKWAVE_LIFETIME <= instance.age:
		return free_instance(instance)
	multimesh.set_instance_transform(instance._id, instance.get_transform() )
	multimesh.set_instance_custom_data(instance._id, instance.get_custom_data() )
