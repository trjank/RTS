class_name ThrusterData extends PartData

func becomes_node_on_ship() -> bool:
	return true # <- MUST BE CONSTANT

func create_part() -> Part:
	var part: Thruster = preload("res://parts/thruster.tscn").instantiate()
	part.data = self
	return part
