extends PanelContainer

@export var color_rect: ColorRect
@export var clan_label: Label
@export var name_label: Label

func show_as_player(player: Player)->void:
	color_rect.color = player.color
	name_label.text = player.name
