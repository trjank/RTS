extends Gamemode

func _init() -> void:
	display_name = "Campaign"
	teams.push_front(Team.new("Test") )
