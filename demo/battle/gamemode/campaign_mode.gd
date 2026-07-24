class_name CampaignMode extends Gamemode

func _init() -> void:
	name = "Campaign"
	teams.push_front(Team.new("Test") )
