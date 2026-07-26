class_name ThrusterData extends PartData

var trail_inner_color := Color.ORANGE
var trail_outer_color := Color.RED
var trail_flicker_strength := 0.2
var trail_roundness := 1.0
var trail_glow := 2.0
var trail_force := 0.5
var trail_width_ratio := 1.0

func becomes_node_on_ship() -> bool:
	return true # <- MUST BE CONSTANT

func create_part() -> Part:
	var part: Thruster = preload("res://parts/thruster.tscn").instantiate()
	part.data = self
	return part
