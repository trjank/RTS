class_name Explosions extends DynamicMultimesh

class ExplosionInstance extends Instance:
	var data := ExplosionData.DEFAULT:
		set(new_data): data = new_data if new_data != null else ExplosionData.DEFAULT
	var center := Vector3.ZERO
	var age := 0.0
	var time_scale := 1.0
	var start_radius := 0.0
	var end_radius := 1.0
	var radius := 0.0

const MAX_AGE := 1.0

static func create() -> Explosions:
	return preload("res://explosion/explosions.tscn").instantiate()

static func format_custom_data(instance: ExplosionInstance) -> Color:
	# NOTE: This must match the shader's INSTANCE_CUSTOM format!
	return Color(instance.age, instance.data.fade_delay, instance.data.speed, instance.data.volatility)

func _new_instance() -> ExplosionInstance:
	return ExplosionInstance.new()

func create_instance() -> ExplosionInstance:
	return super()

func create_instance_with_data(center: Vector3, start_radius: float, end_radius: float, duration_sec: float, data: ExplosionData) -> ExplosionInstance:
	var instance := create_instance()
	instance.center = center
	instance.data = data
	instance.start_radius = start_radius
	instance.end_radius = end_radius
	instance.time_scale = 1.0 / duration_sec
	return instance

func create_explosion(center: Vector3, start_radius: float, end_radius: float, duration_sec: float, data: ExplosionData) -> ExplosionInstance:
	var instance := create_instance_with_data(center, start_radius, end_radius, duration_sec, data)
	multimesh.set_instance_transform(instance._id, Transform3D(Basis.from_scale(Vector3.ZERO), instance.center) )
	multimesh.set_instance_color(instance._id, data.glow * data.color)
	multimesh.set_instance_custom_data(instance._id, format_custom_data(instance) )
	return instance

func _process(dt: float) -> void:
	for instance in _instances:
		_animate_instance(instance, dt)

func _animate_instance(instance: ExplosionInstance, dt: float) -> void:
	instance.age += dt * instance.time_scale
	if MAX_AGE <= instance.age:
		return free_instance(instance)
	instance.radius = lerpf(instance.start_radius, instance.end_radius, instance.age)
	multimesh.set_instance_transform(instance._id, Transform3D(Basis.from_scale(instance.radius * Vector3.ONE), instance.center) )
	multimesh.set_instance_custom_data(instance._id, format_custom_data(instance) )
