extends RigidBody2D

const DEFAULT_ZOOM := Vector2(1.0, 1.0)

var speed_xy := 10000
var speed_z := 1.0
var min_z := 0.2
var max_z := 3.0
var z := 1.0

@export var camera_node: Camera2D

func _physics_process(delta):
	var input_xy = Input.get_vector("left", "right", "up", "down")
	var input_z = Input.get_axis("in", "out")
	apply_force(input_xy * speed_xy)
	z = clamp(z + input_z * speed_z * delta, min_z, max_z)
	camera_node.zoom = DEFAULT_ZOOM / z
