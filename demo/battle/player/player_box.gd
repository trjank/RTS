class_name PlayerBox extends HBoxContainer

@export var clan_label: Label
@export var name_label: Label
@export var icon: TextureRect

var player: Player:
	set = set_player

func is_empty() -> bool:
	return player == null

func set_player(new_player: Player) -> void:
	player = new_player
	name_label.text = player.display_name
	clan_label.text = player.clan
	icon.texture = player.icon
