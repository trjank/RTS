class_name Explosions extends DynamicMultimesh

const MAX_EXPLOSION_COUNT := 1000
const EXPLOSION_LIFETIME := 1.0

static func create() -> Explosions:
	return preload("res://explosion/explosions.tscn").instantiate()

func _ready() -> void:
	multimesh.instance_count = MAX_EXPLOSION_COUNT

func _new_instance() -> ExplosionInstance:
	return ExplosionInstance.new()

func create_instance() -> ExplosionInstance:
	return super()

func create_explosion(data := ExplosionData.DEFAULT) -> ExplosionInstance:
	var instance := create_instance()
	instance.data = data
	multimesh.set_instance_transform(instance._id, instance.get_transform() )
	multimesh.set_instance_color(instance._id, data.glow * data.color)
	multimesh.set_instance_custom_data(instance._id, instance.get_custom_data() )
	return instance

func _process(dt: float) -> void:
	for instance in _instances:
		_animate_instance(instance, dt)
	assert(_instances.size() == multimesh.visible_instance_count)

func _animate_instance(instance: ExplosionInstance, dt: float) -> void:
	instance.animate(dt)
	if EXPLOSION_LIFETIME <= instance.age:
		return free_instance(instance)
	multimesh.set_instance_transform(instance._id, instance.get_transform() )
	multimesh.set_instance_custom_data(instance._id, instance.get_custom_data() )
