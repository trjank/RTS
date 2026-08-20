class_name AudioPool extends Node3D

const MIN_SIZE := 0

@export var size := 0:
	set = set_size
@export var stream: AudioStream
@export var pitch_scale := 1.0
@export var attenuation := 1.0

var _players: Array[AudioStreamPlayer3D] = []

func set_size(new_size) -> void:
	size = maxi(new_size, MIN_SIZE)
	_players.resize(size)

func get_closest() -> AudioStreamPlayer3D:
	return null

func play(at: Vector3) -> void:
	var player := get_closest()
	player.pitch_scale = pitch_scale
	player.stream = stream
	player.global_position = at
	player.play()
