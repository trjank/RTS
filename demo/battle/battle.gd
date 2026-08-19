class_name Battle extends Node

enum Status {
	STOPPED,
	STARTING,
	RUNNING
}
enum StartError {
	OK,
	ALREADY_RUNNING,
	INCOMPATIBLE_MAP,
	SPAWN_FAILURE
}

signal started
signal stopped(winners: Array[Team] )
signal host_changed(old_host: Player, new_host: Player)
signal me_changed(old_me: Player, new_me: Player)
signal player_joined(player: Player)
signal player_left(player: Player)
signal team_created(team: Team)
signal team_removed(team: Team)

const MAX_NUM_TEAMS := 10
const MAX_NUM_PLAYERS := 100

@export var world: Node3D
@export var round_timer: Timer
@export var countdown_timer: Timer
@export var players_container: Node3D
@export var fleet_container: FleetContainer
@export var mouse_selection: MouseSelection
@export var alloy_label: Label
@export var crystal_label: Label
@export var military_science_label: Label
@export var time_left: Label
@export var explosions: Explosions

var rng := RandomNumberGenerator.new()
var scenery: Array[Scenery] = []
var map: Map
var map_depth_limit := 5
var gamemode: Gamemode:
	set = set_gamemode
var plane := Plane.PLANE_XZ:
	set = set_plane
var me: Player:
	set = set_me
var host: Player:
	set = set_host
var time := 0.0
var time_scale := 1.0
var friendly_fire_enabled := false
var can_pause := false

var _default_team: Team
var _players: Dictionary[String, Player] = {}
var _teams: Dictionary[String, Team] = {}
var _status := Status.STOPPED
var _map_root: Node3D
var _map_data := {}

func _init() -> void:
	_default_team = create_team("Spectators")
	gamemode = StandardMode
	set_physics_process(false)

func _ready() -> void:
	Globals.client.fleet_changed.connect(fleet_container.set_fleet)
	fleet_container.set_fleet(Globals.client.fleet)
	mouse_selection.plane = plane
	me = connect_player("dev")
	me.fleet = Globals.client.fleet
	host = me

func is_team_alive(team: Team) -> bool:
	return team != _default_team and team.is_alive()

func is_team_name_alive(team_name: String) -> bool:
	return is_team_alive(_teams[team_name] )

func count_players() -> int:
	return _players.size()

func count_teams() -> int:
	return _teams.size()

func get_player(player_name: String) -> Player:
	return _players.get(player_name)

func get_team(team_name: String) -> Team:
	return _teams.get(team_name)

func get_default_team() -> Team:
	return _default_team

func get_status() -> Status:
	return _status

func get_map_data() -> Dictionary:
	return _map_data

func get_team_names() -> PackedStringArray:
	return PackedStringArray(_teams.keys() )

func get_alive_team_names() -> PackedStringArray:
	return PackedStringArray(_teams.keys().filter(is_team_name_alive) )

func get_player_names() -> PackedStringArray:
	return PackedStringArray(_players.keys() )

func get_alive_teams() -> Array[Team]:
	return _teams.values().filter(is_team_alive)

## This creates a copy (if you can, use get_player instead)
func get_players() -> Array[Player]:
	var copy := [] as Array[Player]
	copy.assign(_players.values() )
	return copy

## This creates a copy (if you can, use get_team instead)
func get_teams() -> Array[Team]:
	var copy := [] as Array[Team]
	copy.assign(_teams.values() )
	return copy

func set_plane(new_plane: Plane) -> void:
	plane = new_plane
	mouse_selection.plane = plane

func set_host(new_host: Player) -> bool:
	if new_host == host or new_host.get_battle() != self:
		return false
	var old_host = host
	host = new_host
	host_changed.emit(old_host, new_host)
	return true

func set_me(new_me: Player) -> bool:
	if new_me == me or new_me.get_battle() != self:
		return false
	if me != null:
		me.selection.clear()
	var old_me := me
	me = new_me
	me_changed.emit(old_me, new_me)
	return true

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

func destroy_map() -> void:
	if _map_root == null:
		return
	_map_data.clear()
	_map_root.queue_free()
	_map_root = null
	scenery.clear()

func generate_map() -> void:
	if map == null:
		return push_error("(Battle) No map to generate!")
	destroy_map()
	rng.seed = rng.seed
	_map_root = Node3D.new()
	world.add_child(_map_root)
	var error := map.generate(_map_root, self, rng, scenery, map_depth_limit, _map_data)
	#
	print("(Battle) Map generation: %s" % Map.GenerationError.find_key(error) )
	print("(Battle) Generated %d scenery objects" % _map_data.get("scenery_count", 0) )

func start_countdown() -> StartError:
	if _status != Status.STOPPED:
		return StartError.ALREADY_RUNNING
	if not gamemode.is_map_compatible(map):
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
	if gamemode.spawn_teams(self) != Gamemode.SpawnError.OK:
		return StartError.SPAWN_FAILURE
	set_physics_process(true)
	_status = Status.RUNNING
	time = 0.0
	time_scale = 1.0
	gamemode.on_battle_start(self)
	round_timer.start()
	started.emit()
	return StartError.OK

func stop() -> bool:
	if _status != Status.RUNNING:
		return false
	var winners := get_alive_teams()
	_status = Status.STOPPED
	round_timer.stop()
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
	players_container.add_child(player, false, Node.INTERNAL_MODE_BACK)
	_players[player_name] = player
	player.display_name_changed.connect(_handle_player_rename.bind(player) )
	player._battle = self
	player.team = _default_team
	player_joined.emit(player)
	return player

func disconnect_player(player_name: String) -> bool:
	if not player_name in _players:
		return false
	var player := _players[player_name]
	player.queue_free()
	player_left.emit(player)
	_players.erase(player_name)
	return true

func request_add_bot(team: Team) -> Player:
	if team.is_full():
		return null
	var bot := connect_player("bot")
	if bot == null:
		return null
	bot.team = team
	bot.is_bot = true
	gamemode.setup_bot(bot)
	return bot

func can_join_team(team: Team, player := me) -> bool:
	return _status == Status.STOPPED or (player != null and player.is_admin) and team != null

func can_team_kick(from := me) -> bool:
	return (from == host and _status == Status.STOPPED) or (from != null and from.is_admin)

func request_join_team(team: Team, player := me) -> bool:
	return can_join_team(team, player) and team.add_player(player)

func request_team_kick(player: Player, from := me) -> bool:
	return can_team_kick(from) and _default_team.add_player(player)

func request_kick(player: Player, from := me) -> bool:
	if player == null:
		return false
	if player.is_bot or (from != null and from.is_admin):
		return disconnect_player(player.display_name)
	cast_vote()
	return false

func repick_host() -> void:
	cast_vote()

func cast_vote() -> void:
	pass

func load_team(team: Team) -> Team:
	if _status != Status.STOPPED or team == null or MAX_NUM_TEAMS <= _teams.size():
		return null
	team = team.copy()
	team.display_name = _find_unique_name(team.display_name, _teams)
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

func _reset_player(player: Player) -> void:
	player.get_battle_data().clear()
	player.resources.reset()
	player.resources.add(player.team.start_resources)
	player.alive = true
	player.clear_ships()

func _find_unique_name(key: String, dictionary: Dictionary) -> String:
	var count := 1
	var unique_key := key
	#
	while unique_key in dictionary:
		count += 1
		unique_key = key + " %d" % count
	return unique_key

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
	var seconds := int(round_timer.time_left)
	alloy_label.text = StrategicResources.to_str(me.resources.alloy)
	crystal_label.text = StrategicResources.to_str(me.resources.crystals)
	military_science_label.text = StrategicResources.to_str(me.resources.military_science)
	time_left.text = "%dm %02ds" % [int(seconds / 60.0), seconds % 60]

func _physics_process(dt: float) -> void:
	dt *= time_scale
	time += dt
	gamemode.battle_tick(self, dt)

func _on_countdown_timer_timeout() -> void:
	var start_error := start()
	#
	assert(start_error == StartError.OK)

func _on_round_timer_timeout() -> void:
	var can_stop := stop()
	#
	assert(can_stop)

func _on_design_button_pressed() -> void:
	Globals.main.state = Main.State.DESIGN

func _on_menu_button_pressed() -> void:
	Globals.main.state = Main.State.MAIN_MENU

func _on_mouse_selection_mouse_moved(new_position: Vector3) -> void:
	if me != null:
		me.mouse_position = new_position

func _on_fleet_container_button_pressed(slot: int) -> void:
	if me == null:
		return push_error("(Battle) No player found to spawn ship slot %d for!" % slot)
	me.build_ship_slot(slot)

func _on_mouse_selection_selected(bodies: Array[Node3D], _center: Vector3, _span: Vector2) -> void:
	if me == null:
		return
	var valid_targets := bodies.map(Target.from_node).filter(Target.is_valid)
	me.selection.assign(valid_targets)
