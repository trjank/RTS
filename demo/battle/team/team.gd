class_name Team extends RefCounted

var start_resources := StrategicResources.new()
var resource_rate := StrategicResources.new()
var display_name := ""
var color := Color.WHITE
var units_killed := 0
var units_lost := 0
var celestials_owned := 0
var value_killed := StrategicResources.new()
var value_lost := StrategicResources.new()
var players: Array[Player] = []

var _captures: Dictionary[Scenery, bool] = {}

static func is_player_alive(player: Player) -> bool:
	return player.alive

func _init(init_name := "", init_color := Color.WHITE) -> void:
	display_name = init_name
	color = init_color

func count_captures() -> int:
	return _captures.size()

func is_alive() -> bool:
	return players.any(is_player_alive)

func get_alive_players() -> Array:
	return players.filter(is_player_alive)

func register_capture(scenery: Scenery) -> void:
	_captures[scenery] = true

func register_loss(scenery: Scenery) -> void:
	_captures.erase(scenery)

func register_kill(unit: Unit) -> void:
	units_killed += 1
	value_killed.add(unit.value)

func register_death(unit: Unit) -> void:
	units_lost += 1
	value_lost.add(unit.value)

func reset_stats() -> void:
	celestials_owned = 0
	units_killed = 0
	units_lost = 0
	value_killed.reset()
	value_lost.reset()
