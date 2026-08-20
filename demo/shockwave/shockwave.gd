@tool
class_name Shockwave extends MeshInstance3D

@export_tool_button("propagate") var propagate_button = propagate

const MIN_DURATION_SEC := 0.1

@export var duration_sec := 1.0:
	set = set_duration_sec
@export var start_radius := 0.0
@export var end_radius := 1.0
@export var sound_effect: AudioStreamPlayer3D

static func create() -> Shockwave:
	return preload("res://shockwave/shockwave.tscn").instantiate()

func set_duration_sec(new_duration_sec: float) -> void:
	duration_sec = maxf(new_duration_sec, MIN_DURATION_SEC)

func begin_death_timer() -> void:
	get_tree().create_timer(duration_sec).timeout.connect(queue_free)

func propagate() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", end_radius * Vector3.ONE, duration_sec).from(start_radius * Vector3.ONE)
	#sound_effect.pitch_scale = 1.0 / duration_sec
	#sound_effect.play()

func update_shader() -> void:
	pass
