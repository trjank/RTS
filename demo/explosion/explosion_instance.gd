class_name ExplosionInstance extends DynamicMultimesh.Instance

var data := ExplosionData.DEFAULT:
	set = set_data
var age := 0.0:
	set = set_age
var duration_sec := 1.0
var start_radius := 0.0
var end_radius := 1.0
var radius := 0.0
var position := Vector3.ZERO

func get_custom_data() -> Color:
	return Color(age, data.fade_delay, data.speed, data.volatility)

func get_transform() -> Transform3D:
	return Transform3D(Basis.from_scale(radius * Vector3.ONE), position)

func set_age(new_age: float) -> void:
	age = new_age
	radius = lerpf(start_radius, end_radius, age)

func set_data(new_data: ExplosionData) -> void:
	data = new_data if new_data != null else ExplosionData.DEFAULT

func animate(dt: float) -> void:
	age += dt / duration_sec
