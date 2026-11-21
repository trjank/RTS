extends RigidBody3D

@export var force := Vector3(1.0, 1.0, 1.0)

func _physics_process(_dt: float) -> void:
	if freeze or get_viewport().gui_get_focus_owner() != null or Input.is_action_pressed(&"save"):
		return # (prevent forces from stacking up when frozen)
	var input_xz := Input.get_vector(&"left", &"right", &"up", &"down")
	var input_y := Input.get_axis(&"zoom in", &"zoom out")
	apply_central_force(force * Vector3(input_xz.x, input_y, input_xz.y) )
