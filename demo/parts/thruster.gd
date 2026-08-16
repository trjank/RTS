class_name Thruster extends Part

@export var trail: Trail

func _ready() -> void:
	var thruster_data: ThrusterData = data
	trail.data = thruster_data.trail
	trail.update_shader()
	trail.randomize_flicker()

func set_data(new_data: PartData) -> void:
	super(new_data as ThrusterData)

func _process(_dt: float) -> void:
	var thruster_data: ThrusterData = data
	var speed := maxf(_ship.linear_velocity.dot(get_global_forward_direction() ), 0.0) if _ship != null else 1.0
	var turn_speed := maxf(_ship.angular_velocity.y * get_forward_direction().cross(position).y, 0.0) if _ship != null else 0.0
	trail.scale.x = thruster_data.trail_width_ratio * get_size_2d().x
	trail.scale.z = thruster_data.trail_length_speed_ratio * (speed + turn_speed)
