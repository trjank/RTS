class_name Battle extends Node

enum Status {
	STOPPED,
	STARTING,
	RUNNING
}
enum StartError {
	OK,
	ALREADY_RUNNING,
	UNBALANCED_TEAMS
}

signal started
signal stopped(winners: Array[Team] )
signal player_joined(player: Player)
signal player_left(player: Player)

const MAX_NUM_TEAMS := 10
const MAX_NUM_PLAYERS := 10
# DO NOT DELETE THIS TEAM!
const DEFAULT_TEAM_NAME := "spectators"

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
var players: Dictionary[String, Player] = {}
var teams: Dictionary[String, Team] = {}
var rng := RandomNumberGenerator.new()
var scenery: Array[Scenery] = []
var plane := Plane.PLANE_XZ:
	set = set_plane
var map: Map:
	get = get_map,
	set = set_map
var me: Player

var _status := Status.STOPPED
var _map_root: Node3D
var _state := BattleState.new()

static func is_team_alive(team: Team) -> bool:
	return team.is_alive()

func _init() -> void:
	create_team(DEFAULT_TEAM_NAME)
	set_physics_process(false)

func _ready() -> void:
	globals.client.fleet_changed.connect(fleet_container.set_fleet)
	fleet_container.set_fleet(globals.client.fleet)
	mouse_selection.plane = plane
	me = connect_player("dev")

func are_teams_balanced() -> bool:
	return true

func get_status() -> Status:
	return _status

func get_state() -> BattleState:
	return _state

func get_alive_teams() -> Array[Team]:
	return teams.values().filter(is_team_alive)

func get_map() -> Map:
	return _state.map

func set_plane(new_plane: Plane) -> void:
	plane = new_plane
	mouse_selection.plane = plane

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
	var shared_variables := {}
	var error := _state.map.generate(_map_root, _state, rng, scenery, _state.map_depth_limit, shared_variables)
	print("(Battle) Map generation: %s" % Map.GenerationError.find_key(error) )
	print("(Battle) Generated %d scenery objects" % shared_variables.get("scenery_count", 0) )

func start_countdown() -> StartError:
	if _status != Status.STOPPED:
		return StartError.ALREADY_RUNNING
	if not are_teams_balanced():
		return StartError.UNBALANCED_TEAMS
	_status = Status.STARTING
	countdown_timer.start()
	return StartError.OK

func start() -> StartError:
	if _status == Status.RUNNING:
		return StartError.ALREADY_RUNNING
	if not are_teams_balanced():
		return StartError.UNBALANCED_TEAMS
	reset_teams()
	generate_map()
	set_physics_process(true)
	_status = Status.RUNNING
	_state.time = 0.0
	_state.time_scale = 1.0
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
	assert(DEFAULT_TEAM_NAME in teams)
	#
	if player_name in players:
		return players[player_name]
	if MAX_NUM_PLAYERS <= players.size():
		return null
	var player := Player.new(player_name, color)
	players[player_name] = player
	player.team = teams[DEFAULT_TEAM_NAME]
	players_container.add_child(player, false, Node.INTERNAL_MODE_BACK)
	player_joined.emit(player)
	return player

func disconnect_player(player_name: String) -> bool:
	if not player_name in players:
		return false
	var player := players[player_name]
	player.queue_free()
	player_left.emit(player)
	players.erase(player_name)
	return true

func create_team(team_name: String, color := Color.BLUE) -> Team:
	if team_name in teams:
		return teams[team_name]
	if _status != Status.STOPPED or MAX_NUM_TEAMS <= teams.size():
		return null
	var team := Team.new(team_name, color)
	teams[team_name] = team
	return team

func remove_team(team_name: String) -> bool:
	assert(DEFAULT_TEAM_NAME in teams)
	#
	if team_name == DEFAULT_TEAM_NAME or not team_name in teams:
		return false
	var team := teams[team_name]
	var default_team := teams[DEFAULT_TEAM_NAME]
	#
	for player in team.players:
		player.team = default_team
	return teams.erase(team_name)

func _reset_player(player: Player) -> void:
	player.resources.reset()
	player.resources.add(player.team.start_resources)
	player.alive = true

func reset_teams() -> void:
	for player: Player in players.values():
		_reset_player(player)
	for team: Team in teams.values():
		team.reset_stats()

func _process(_dt: float) -> void:
	alloy_label.text = "%.1f" % me.resources.alloy
	energy_label.text = "%.1f" % me.resources.energy
	military_science_label.text = "%.1f" % me.resources.military_science

func _physics_process(dt: float) -> void:
	_state.time += _state.time_scale * dt

func _on_countdown_timer_timeout() -> void:
	var start_error := start()
	#
	assert(start_error == StartError.OK)

func _on_round_timer_timeout() -> void:
	var can_stop := stop()
	#
	assert(can_stop)

func _on_design_button_pressed() -> void:
	globals.main.state = Main.State.DESIGN

func _on_menu_button_pressed() -> void:
	globals.main.state = Main.State.MAIN_MENU

func _on_fleet_container_button_pressed(slot: int) -> void:
	if globals.client.fleet.get_ship(slot) == null:
		return
	me.spawn_ship(globals.client.fleet.get_ship(slot) )
