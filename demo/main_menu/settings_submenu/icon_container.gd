extends TabBar

func _ready() -> void:
	for icon in Player.Icon:
		add_tab(icon, Player.ICONS[Player.Icon[icon] ] )
