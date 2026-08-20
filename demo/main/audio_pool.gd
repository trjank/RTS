class_name AudioPool extends Node3D

const MIN_SIZE := 0

@export var size := 0:
	set = set_size
@export var stream: AudioStream
@export var pitch_scale := 1.0
@export var attenuation := 1.0

var _audio_players: Array[AudioStreamPlayer3D] = []

func set_size(new_size) -> void:
	for audio_player in _audio_players:
		audio_player.queue_free()
	size = maxi(new_size, MIN_SIZE)
	_audio_players.resize(size)
	#
	for i in size:
		_audio_players[i] = _create_audio_player()

func _create_audio_player() -> AudioStreamPlayer3D:
	var audio_player := AudioStreamPlayer3D.new()
	add_child(audio_player, false, Node.INTERNAL_MODE_BACK)
	return audio_player

func get_closest() -> AudioStreamPlayer3D:
	return null

func play(at: Vector3) -> void:
	var player := get_closest()
	player.pitch_scale = pitch_scale
	player.stream = stream
	player.global_position = at
	player.play()
