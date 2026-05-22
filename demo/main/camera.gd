extends CharacterBody3D

@export var speed := Vector3(1.0, 1.0, 1.0)

func _physics_process(_dt: float) -> void:
	var input_xz := Input.get_vector("left", "right", "up", "down")
	var input_y := Input.get_axis("zoom_in", "zoom_out")
	velocity = speed * Vector3(input_xz.x, input_y, input_xz.y)
	move_and_slide()
