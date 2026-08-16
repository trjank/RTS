class_name Wing extends Part

@export var upper_wing: MeshInstance3D
@export var lower_wing: MeshInstance3D

func _ready() -> void:
	var z: float = Measurement.METERS_PER_TILE * data.z
	var x: float = -Measurement.METERS_PER_TILE * (0.5 * data.get_width() )
	lower_wing.position.z = z
	upper_wing.position.z = z
	lower_wing.position.x = x
	upper_wing.position.x = x

func _process(_dt: float) -> void:
	var speed_ratio := _ship.get_speed() / _ship.get_max_speed() if _ship != null else 0.0
	var tilt := deg_to_rad(lerpf(data.max_wing_tilt, data.min_wing_tilt, speed_ratio) )
	upper_wing.rotation.z = -tilt
	lower_wing.rotation.z = tilt
