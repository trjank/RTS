class_name Team extends RefCounted

signal player_joined(player: Player)
signal player_left(player: Player)
signal display_name_changed(old_display_name: String, new_display_name: String)

# These are the main lore-based factions
static var APHELIONS := Team.new("Aphelions", Color.BLUE):
	set(__): push_error("Team.APHELIONS is immutable")
static var FEDERATION = Team.new("Federation", Color.RED):
	set(__): push_error("Team.FEDERATION is immutable")
static var SYZYGYSTS = Team.new("Syzygysts", Color.PURPLE):
	set(__): push_error("Team.SYZYGYSTS is immutable")
static var OCCULTARCHS = Team.new("Occultarchs", Color.BLACK):
	set(__): push_error("Team.OCCULTARCHS is immutable")

var start_resources := StrategicResources.new()
var resource_rate := StrategicResources.new()
var display_name := "":
	set = set_display_name
var color := Color.WHITE
var units_killed := 0
var units_lost := 0
var celestials_owned := 0
var value_killed := StrategicResources.new()
var value_lost := StrategicResources.new()

var _max_players: int
var _players: Array[Player] = []
var _captures: Dictionary[Scenery, bool] = {}

static func is_player_alive(player: Player) -> bool:
	return player.alive

static func is_me(player: Player) -> bool:
	return player.is_me()

func _init(init_name := "", init_color := Color.WHITE, max_players := 10) -> void:
	display_name = init_name
	color = init_color
	_max_players = max_players

func count_players() -> int:
	return _players.size()

func count_captures() -> int:
	return _captures.size()

func is_full() -> bool:
	return _max_players <= _players.size()

func is_alive() -> bool:
	return _players.any(is_player_alive)

func get_player(i: int) -> Player:
	return _players[i]

func get_players() -> Array[Player]:
	return _players.duplicate()

func get_alive_players() -> Array:
	return _players.filter(is_player_alive)

func set_display_name(new_display_name: String) -> void:
	if new_display_name == display_name:
		return
	var old_display_name := display_name
	display_name = new_display_name
	display_name_changed.emit(old_display_name, new_display_name)

func add_player(player: Player) -> bool:
	if is_full() or player == null or player in _players:
		return false
	_players.append(player)
	player.team = self
	player_joined.emit(player)
	return true

func remove_player(player: Player) -> bool:
	if not player in _players:
		return false
	_players.erase(player)
	player.team = null
	player_left.emit(player)
	return true

func contains_me() -> bool:
	return _players.any(is_me)

func copy() -> Team:
	return Team.new(display_name, color, _max_players)

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
