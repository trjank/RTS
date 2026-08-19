@tool
class_name Explosion extends MeshInstance3D

@export_tool_button("explode") var explode_button = explode

const MIN_DURATION_SEC := 0.1

@export var duration_sec := 1.0:
	set = set_duration_sec
@export var start_radius := 0.0
@export var end_radius := 1.0
@export var sound_effect: AudioStreamPlayer3D

var data := ExplosionData.DEFAULT:
	set = set_data

static func create() -> Explosion:
	return preload("res://explosion/explosion.tscn").instantiate()

func set_duration_sec(new_duration_sec: float) -> void:
	duration_sec = maxf(new_duration_sec, MIN_DURATION_SEC)

func set_data(new_data: ExplosionData) -> void:
	data = new_data if new_data != null else ExplosionData.DEFAULT
	update_shader()

func randomize_pattern() -> void:
	set_instance_shader_parameter("random_offset", Vector2(randf(), randf() ) )

func begin_death_timer() -> void:
	get_tree().create_timer(duration_sec).timeout.connect(queue_free)

func explode() -> void:
	randomize_pattern()
	var tween := create_tween().set_parallel(true)
	var implodes := start_radius > end_radius
	tween.tween_property(self, "instance_shader_parameters/age", 0.0 if implodes else 1.0, duration_sec).from(1.0 if implodes else 0.0)
	tween.tween_property(self, "scale", end_radius * Vector3.ONE, duration_sec).from(start_radius * Vector3.ONE)
	sound_effect.pitch_scale = 1.0 / duration_sec
	#sound_effect.play()

func update_shader() -> void:
	set_instance_shader_parameter("speed", data.speed)
	set_instance_shader_parameter("color", data.glow * data.color)
	set_instance_shader_parameter("fade_delay", data.fade_delay)
	set_instance_shader_parameter("volatility", data.volatility)
