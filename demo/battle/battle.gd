class_name Battle extends Node

enum Status {
	STOPPED,
	STARTING,
	RUNNING
}
enum StartError {
	OK,
	ALREADY_RUNNING,
	INCOMPATIBLE_MAP
}

signal started
signal stopped(winners: Array[Team] )
signal player_joined(player: Player)
signal player_left(player: Player)
signal team_created(team: Team)
signal team_removed(team: Team)

const DUPLICATE_NAME_SUFFIX := "*"
const MAX_NUM_TEAMS := 10
const MAX_NUM_PLAYERS := 100

@export var world: Node3D
@export var round_timer: Timer
@export var countdown_timer: Timer
@export var players_container: Node3D
@export var fleet_container: FleetContainer
@export var mouse_selection: MouseSelection
@export var alloy_label: Label
@export var energy_label: Label
@export var military_science_label: Label

var can_pause := false
var rng := RandomNumberGenerator.new()
var scenery: Array[Scenery] = []
var map: Map:
	get = get_map,
	set = set_map
var gamemode: Gamemode:
	set = set_gamemode
var plane := Plane.PLANE_XZ:
	set = set_plane
var me: Player
var host: Player

var _default_team: Team
var _players: Dictionary[String, Player] = {}
var _teams: Dictionary[String, Team] = {}
var _status := Status.STOPPED
var _map_root: Node3D
var _state := BattleState.new()
var _shared_variables := {}

static func is_team_alive(team: Team) -> bool:
	return team.is_alive()

func _init() -> void:
	_default_team = create_team("Spectators")
	gamemode = Gamemode.STANDARD
	set_physics_process(false)

func _ready() -> void:
	globals.client.fleet_changed.connect(fleet_container.set_fleet)
	fleet_container.set_fleet(globals.client.fleet)
	mouse_selection.plane = plane
	me = connect_player("dev")

## Returns null if the player does not exist
func get_player(player_name: String) -> Player:
	return _players.get(player_name)

## Returns null if the team does not exist
func get_team(team_name: String) -> Player:
	return _teams.get(team_name)

func get_default_team() -> Team:
	return _default_team

func get_status() -> Status:
	return _status

func get_state() -> BattleState:
	return _state

func get_alive_teams() -> Array[Team]:
	return _teams.values().filter(is_team_alive)

func get_map() -> Map:
	return _state.map

func set_plane(new_plane: Plane) -> void:
	plane = new_plane
	mouse_selection.plane = plane

func set_gamemode(new_gamemode: Gamemode) -> bool:
	if _status != Status.STOPPED or new_gamemode == null:
		return false
	gamemode = new_gamemode
	move_players(_default_team)
	clear_teams()
	#
	for team in gamemode.teams:
		load_team(team)
	return true

func set_map(new_map: Map) -> void:
	_state.map = new_map

func destroy_map() -> void:
	if _map_root == null:
		return
	_map_root.queue_free()
	_map_root = null
	scenery.clear()

func generate_map() -> void:
	assert(_state.map != null)
	#
	destroy_map()
	_map_root = Node3D.new()
	world.add_child(_map_root)
	_shared_variables.clear()
	var error := _state.map.generate(_map_root, _state, rng, scenery, _state.map_depth_limit, _shared_variables)
	print("(Battle) Map generation: %s" % Map.GenerationError.find_key(error) )
	print("(Battle) Generated %d scenery objects" % _shared_variables.get("scenery_count", 0) )

func start_countdown() -> StartError:
	if _status != Status.STOPPED:
		return StartError.ALREADY_RUNNING
	if not _state.gamemode.is_map_compatible(map):
		return StartError.INCOMPATIBLE_MAP
	_status = Status.STARTING
	countdown_timer.start()
	return StartError.OK

func start() -> StartError:
	if _status == Status.RUNNING:
		return StartError.ALREADY_RUNNING
	if not gamemode.is_map_compatible(map):
		return StartError.INCOMPATIBLE_MAP
	reset_teams()
	generate_map()
	set_physics_process(true)
	_status = Status.RUNNING
	_state.time = 0.0
	_state.time_scale = 1.0
	gamemode.on_battle_start(self, _shared_variables)
	round_timer.start()
	started.emit()
	return StartError.OK

func stop() -> bool:
	if _status != Status.RUNNING:
		return false
	var winners := get_alive_teams()
	_status = Status.STOPPED
	set_physics_process(false)
	stopped.emit(winners)
	return true

func connect_player(player_name: String, color := Color.WHITE) -> Player:
	assert(_default_team != null)
	#
	if MAX_NUM_PLAYERS <= _players.size():
		return null
	player_name = _find_unique_name(player_name, _players)
	#
	var player := Player.new(player_name, color)
	_players[player_name] = player
	player.display_name_changed.connect(_handle_player_rename.bind(player) )
	player.team = _default_team
	players_container.add_child(player, false, Node.INTERNAL_MODE_BACK)
	player_joined.emit(player)
	return player

func disconnect_player(player_name: String) -> bool:
	if not player_name in _players:
		return false
	# NOTE: queue_free disconnects all signals
	var player := _players[player_name]
	player.queue_free()
	player_left.emit(player)
	_players.erase(player_name)
	return true

func request_join_team(team: Team, player := me) -> bool:
	return (_status == Status.STOPPED or player.is_admin) and team.add_player(player)

func load_team(team: Team) -> Team:
	if _status != Status.STOPPED or MAX_NUM_TEAMS <= _teams.size():
		return null
	team = team.copy()
	team.display_name = _find_unique_name(team.display_name, _teams)
	#
	_teams[team.display_name] = team
	team.display_name_changed.connect(_handle_team_rename.bind(team) )
	team_created.emit(team)
	return team

func create_team(team_name: String, color := Color.WHITE, max_players := 10) -> Team:
	return load_team(Team.new(team_name, color, max_players) )

func remove_team(team_name: String) -> bool:
	if team_name == _default_team.display_name or not team_name in _teams:
		return false
	var team := _teams[team_name]
	move_players(_default_team)
	team.display_name_changed.disconnect(_handle_team_rename)
	_teams.erase(team_name)
	team_removed.emit(team)
	return true

func move_players(team := _default_team) -> void:
	for player in _players:
		_players[player].team = team

func clear_teams() -> void:
	move_players(_default_team)
	_teams = {_default_team.display_name: _default_team}

func reset_teams() -> void:
	for player in _players:
		_reset_player(_players[player] )
	for team in _teams:
		_teams[team].reset_stats()

func for_each_player(f: Callable) -> void:
	for player in _players:
		f.call(_players[player] )

func for_each_team(f: Callable) -> void:
	for team in _teams:
		f.call(_teams[team] )

func _reset_player(player: Player) -> void:
	player.resources.reset()
	player.resources.add(player.team.start_resources)
	player.alive = true

func _find_unique_name(key: String, dictionary: Dictionary) -> String:
	while key in dictionary:
		key += DUPLICATE_NAME_SUFFIX
	return key

func _handle_player_rename(old_name: String, new_name: String, player: Player) -> void:
	if _players.get(old_name, player) != player:
		return
	new_name = _find_unique_name(new_name, _players)
	_players[new_name] = player
	_players.erase(old_name)
	player.display_name = new_name

func _handle_team_rename(old_name: String, new_name: String, team: Team) -> void:
	if _teams.get(old_name, team) != team:
		return
	new_name = _find_unique_name(new_name, _teams)
	_teams[new_name] = team
	_teams.erase(old_name)
	team.display_name = new_name

func _process(_dt: float) -> void:
	alloy_label.text = "%.1f" % me.resources.alloy
	energy_label.text = "%.1f" % me.resources.energy
	military_science_label.text = "%.1f" % me.resources.military_science

func _physics_process(dt: float) -> void:
	_state.time += _state.time_scale * dt
	gamemode.battle_tick(self, dt)

func _on_countdown_timer_timeout() -> void:
	var start_error := start()
	#
	assert(start_error == StartError.OK)

func _on_round_timer_timeout() -> void:
	var can_stop := stop()
	#
	assert(can_stop)

func _on_fleet_container_button_pressed(slot: int) -> void:
	if globals.client.fleet.get_ship(slot) != null:
		me.spawn_ship(globals.client.fleet.get_ship(slot) )

func _on_design_button_pressed() -> void:
	globals.main.state = Main.State.DESIGN

func _on_menu_button_pressed() -> void:
	globals.main.state = Main.State.MAIN_MENU
