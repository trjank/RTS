class_name ThrusterData extends PartData

var trail := TrailData.new()
var trail_data: Dictionary:
	get = get_trail_data,
	set = set_trail_data
var trail_length_speed_ratio := 1.0
var trail_width_ratio := 1.0

func becomes_node_on_ship() -> bool:
	return true

func get_trail_data() -> Dictionary:
	return trail.to_dict()

func set_trail_data(new_trail_data: Dictionary) -> void:
	trail.load_dict(new_trail_data)

func get_rotated_thrust(rotation: Rotation.Discrete) -> float:
	return thrust if rotation == Rotation.Discrete.ROT_0 or rotation == Rotation.Discrete.FLIP_H_ROT_0 else 0.0

func get_rotated_torque(rotation: Rotation.Discrete) -> float:
	return torque if Rotation.is_odd(rotation) else 0.0

func create_part() -> Part:
	var part: Thruster = preload("res://parts/thruster.tscn").instantiate()
	part.data = self
	return part
