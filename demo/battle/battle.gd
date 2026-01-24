class_name Battle extends Node

enum State {
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

const DEFAULT_TEAM_NAME := "spectators"
const MAX_NUM_TEAMS := 10
const MAX_NUM_PLAYERS := 10

@export var world: Node2D
@export var round_timer: Timer
@export var countdown_timer: Timer
@export var players_container: Node2D
@export var fleet_container: FleetContainer

var players: Dictionary[String, Player] = {}
var teams: Dictionary[String, Team] = {}
var rng := RandomNumberGenerator.new()
var scenery: Array[Scenery] = []
var map: Map
var map_depth_limit := 5
var me: Player

var _state := State.STOPPED
var _map_root: Scenery

static func is_team_alive(team: Team) -> bool:
	return team.is_alive()

func _init() -> void:
	create_team(DEFAULT_TEAM_NAME)
	set_physics_process(false)

func _ready() -> void:
	globals.client.fleet_changed.connect(fleet_container.set_fleet)
	fleet_container.set_fleet(globals.client.fleet)
	fleet_container.get_button(Fleet.CAPITAL_SHIP_SLOT).hide()
	me = connect_player("dev")

func are_teams_balanced() -> bool:
	return true

func get_state() -> State:
	return _state

func get_alive_teams() -> Array[Team]:
	return teams.values().filter(is_team_alive)

func destroy_map() -> void:
	if _map_root == null:
		return
	_map_root.queue_free()
	_map_root = null
	scenery.clear()

func set_map(new_map:Map) -> void: 
	destroy_map()
	map = new_map
	
func generate_map() -> void:
	assert(map != null)
	destroy_map()
	_map_root = map.generate(world, rng, scenery, map_depth_limit)

func start_countdown() -> StartError:
	if _state != State.STOPPED:
		return StartError.ALREADY_RUNNING
	if not are_teams_balanced():
		return StartError.UNBALANCED_TEAMS
	_state = State.STARTING
	countdown_timer.start()
	return StartError.OK

func start() -> StartError:
	if _state == State.RUNNING:
		return StartError.ALREADY_RUNNING
	if not are_teams_balanced():
		return StartError.UNBALANCED_TEAMS
	reset_teams()
	generate_map()
	set_physics_process(true)
	_state = State.RUNNING
	round_timer.start()
	started.emit()
	return StartError.OK

func stop() -> bool:
	if _state != State.RUNNING:
		return false
	var winners := get_alive_teams()
	_state = State.STOPPED
	set_physics_process(false)
	stopped.emit(winners)
	return true

func connect_player(player_name: String, color := Color.WHITE) -> Player:
	assert(DEFAULT_TEAM_NAME in teams)
	#      ^^^^^^^^^^^^^^^^^ DO NOT DELETE THIS TEAM!
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

func create_team(team_name: String, color := Color.WHITE) -> Team:
	if team_name in teams:
		return teams[team_name]
	if _state != State.STOPPED or MAX_NUM_TEAMS <= teams.size():
		return null
	var team := Team.new(team_name, color)
	teams[team_name] = team
	return team

func remove_team(team_name: String) -> bool:
	assert(DEFAULT_TEAM_NAME in teams)
	#      ^^^^^^^^^^^^^^^^^ DO NOT DELETE THIS TEAM!
	if team_name == DEFAULT_TEAM_NAME or not team_name in teams:
		return false
	var team := teams[team_name]
	var default_team := teams[DEFAULT_TEAM_NAME]
	for player in team.players:
		player.team = default_team
	return teams.erase(team_name)

func reset_teams() -> void:
	for player in players.values():
		player.reset_resources()
		player.alive = true
	for team in teams.values():
		team.reset_stats()

func _on_countdown_timer_timeout() -> void:
	var start_error := start()
	assert(start_error == StartError.OK)

func _on_round_timer_timeout() -> void:
	var can_stop := stop()
	assert(can_stop)

func _on_design_button_pressed() -> void:
	globals.main.state = Main.State.DESIGN

func _on_menu_button_pressed() -> void:
	globals.main.state = Main.State.MAIN_MENU

func _on_fleet_container_button_pressed(slot: int) -> void:
	var ship := me.spawn_ship(globals.client.fleet.get_ship(slot) )
	ship.queue_waypoint(Target.new(Vector2(2000, 500)))
	ship.queue_waypoint(Target.new(Vector2(-2000, -500)))
