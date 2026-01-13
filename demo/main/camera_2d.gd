extends Camera2D

const MIN_Z := 0.1
const MAX_Z := 10.0

@export var speed: Vector3
@export var z := 1.0

func _physics_process(dt: float) -> void:
	var input_xy := Input.get_vector("left", "right", "up", "down")
	var input_z := Input.get_axis("zoom_in", "zoom_out")
	z = clamp(z + input_z * speed.z * dt, MIN_Z, MAX_Z)
	position += Vector2(speed.x, speed.y) * input_xy * dt
	# NOTE: This is just a perspective trick (nothing is truly 3D)
	zoom = Vector2.ONE / z
