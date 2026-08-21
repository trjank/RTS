class_name ShockwaveInstance extends DynamicMultimesh.Instance

const MIN_RADIUS := 0.1

var age := 0.0
var duration_sec := 1.0
var distortion := 1.0
var start_radius := 0.0
var end_radius := 1.0

func get_custom_data() -> Color:
	return Color(distortion, 0.0, 0.0, 0.0)

func get_radius() -> float:
	return maxf(lerpf(start_radius, end_radius, age), MIN_RADIUS)
