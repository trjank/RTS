class_name ThrusterData extends PartData

var trail_color := Color.WHITE
var trail_width := 0.0
var trail_height := 0.0

func becomes_node_on_ship() -> bool:
	return true # <- MUST BE CONSTANT

func create_part() -> Part:
	var part: Thruster = preload("res://parts/thruster.tscn").instantiate()
	part.data = self
	return part
