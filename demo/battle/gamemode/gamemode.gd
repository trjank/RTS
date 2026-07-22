class_name Gamemode extends RefCounted

static var STANDARD := Gamemode.new():
	set(__): push_error("Gamemode.STANDARD is immutable")
static var CAMPAIGN := CampaignMode.new():
	set(__): push_error("Gamemode.CAMPAIGN is immutable")
static var modes: Array[Gamemode] = [STANDARD]

var name := "Standard"
var teams: Array[Team] = [Team.APHELIONS, Team.FEDERATION, Team.SYZYGYSTS, Team.OCCULTARCHS]

func is_map_compatible(_map: Map) -> bool:
	return true

func on_battle_start(_battle: Battle, _shared_variables: Dictionary) -> void:
	pass
	#battle.for_each_player(func player: player.)

func check_win_condition() -> void:
	pass

func battle_tick(_battle: Battle, _dt: float) -> void:
	# Put gamemode logic here
	pass
