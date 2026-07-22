class_name PlayerBox extends HBoxContainer

@export var clan_label: Label
@export var name_label: Label
@export var icon: TextureRect

var player: Player:
	set = set_player

static func create() -> PlayerBox:
	return preload("res://battle/player/player_box.tscn").instantiate()

func is_empty() -> bool:
	return player == null

func set_player(new_player: Player) -> void:
	player = new_player
	if player != null:
		_set_ui()
	else:
		_clear_ui()

func _set_ui() -> void:
	name_label.text = player.display_name
	clan_label.text = player.clan
	icon.texture = player.icon

func _clear_ui() -> void:
	name_label.text = "--"
	clan_label.text = "N/A"
	icon.texture = player.icon
