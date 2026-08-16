class_name WingData extends PartData

var min_wing_tilt := 20.0
var max_wing_tilt := 45.0
var z := 0.0

func becomes_node_on_ship() -> bool:
	return true

func create_part() -> Part:
	var part: Part = preload("res://parts/wing.tscn").instantiate()
	part.data = self
	return part
