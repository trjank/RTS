class_name ExplosionInstance extends DynamicMultimesh.Instance

const MIN_RADIUS := 0.1

var data := ExplosionData.DEFAULT:
	set = set_data
var age := 0.0
var duration_sec := 1.0
var start_radius := 0.0
var end_radius := 1.0

func get_color() -> Color:
	return data.glow * data.color

func get_custom_data() -> Color:
	return Color(age, data.fade_delay, data.skew, data.volatility)

func get_radius() -> float:
	return maxf(lerpf(start_radius, end_radius, age), MIN_RADIUS)

func set_data(new_data: ExplosionData) -> void:
	data = new_data if new_data != null else ExplosionData.DEFAULT
