class_name ShockwaveInstance extends DynamicMultimesh.Instance

var age := 0.0:
	set = set_age
var duration_sec := 1.0
var distortion := 1.0
var start_radius := 0.0
var end_radius := 1.0
var radius := 0.0
var position := Vector3.ZERO

func get_custom_data() -> Color:
	return Color(distortion, 0.0, 0.0, 0.0)

func get_transform() -> Transform3D:
	return Transform3D(Basis.from_scale(radius * Vector3.ONE), position)

func set_age(new_age: float) -> void:
	age = new_age
	radius = lerpf(start_radius, end_radius, age)

func animate(dt: float) -> void:
	age += dt / duration_sec
