class_name Team extends RefCounted

var display_name := ""
var color := Color.WHITE
var units_killed := 0
var units_lost := 0
var celestials_owned := 0
var initial_alloy := 0.0
var initial_energy := 0.0
var alloy_per_sec := 0.0
var energy_per_sec := 0.0
var value_killed := 0.0
var value_lost := 0.0
var players: Array[Player] = []

static func is_player_alive(player: Player) -> bool:
	return player.alive

func _init(init_name := "", init_color := Color.WHITE) -> void:
	display_name = init_name
	color = init_color

func is_alive() -> bool:
	return players.any(is_player_alive)

func get_alive_players() -> Array:
	return players.filter(is_player_alive)

func register_kill(unit: Unit) -> void:
	units_killed += 1
	value_killed += unit.value

func register_loss(unit: Unit) -> void:
	units_lost += 1
	value_lost += unit.value

func reset_stats() -> void:
	celestials_owned = 0
	units_killed = 0
	units_lost = 0
	value_killed = 0.0
	value_lost = 0.0
