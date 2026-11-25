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
enum SaveError {
	OK = 0,
	MISSING_DIRECTORY = 1 << 0,
	METADATA_FAILURE = 1 << 1,
	TABLE_FAILURE = 1 << 2,
	MAP_FAILURE = 1 << 3,
	STATE_FAILURE = 1 << 4,
	MANIFEST_FAILURE = 1 << 5
}

signal started
signal stopped(winners: Array[Team] )
signal host_changed(old_host: Player, new_host: Player)
signal me_changed(old_me: Player, new_me: Player)
signal friendly_fire_changed(enabled: bool)
signal player_joined(player: Player)
signal player_left(player: Player)
signal team_created(team: Team)
signal team_removed(team: Team)

const PARENT_DIRECTORY := "user://"
const MAX_NUM_TEAMS := 10
const MAX_NUM_PLAYERS := 100

static var PROPERTIES: Dictionary[String, Variant.Type] = {
	"seed": TYPE_INT,
	"time": TYPE_FLOAT,
	"time_scale": TYPE_FLOAT,
	"map_data": TYPE_DICTIONARY,
	"friendly_fire_enabled": TYPE_BOOL,
	"retrofits_enabled": TYPE_BOOL,
	"retrofit_cost_multiplier": TYPE_FLOAT
}

@export var world: Node3D
@export var round_timer: Timer
@export var countdown_timer: Timer
@export var players_container: Node3D
@export var fleet_container: FleetContainer
@export var mouse_selection: MouseSelection
@export var resource_counter: ResourceCounter
@export var explosions: Explosions
@export var shockwaves: Shockwaves

var rng := RandomNumberGenerator.new()
var chat_log := ChatLog.new():
	set(__): push_error("(Battle) Do not create a new chat log!")
var scenery: Array[Scenery] = []
var map: Map
var map_data := {}
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
var retrofit_cost_multiplier := 1.0
var retrofits_enabled := true
var friendly_fire_enabled := false:
	set = set_friendly_fire_enabled
var can_pause := false
var state := SaveState.new()
var folder_path := PARENT_DIRECTORY.path_join("temporary_battle/"):
	set = set_folder_path
## NOTE: This value is never null (defaults to ShipManager.TEMPORARY)
var ship_db := ShipManager.TEMPORARY:
	set = set_ship_db
## NOTE: This value is never null (defaults to UnitLogicManager.TEMPORARY)
var unit_logic_db := UnitLogicManager.TEMPORARY:
	set = set_unit_logic_db
var copied_fleets := TwoWayIDMap.new()
var copied_ships := TwoWayIDMap.new()
var copied_unit_logic := TwoWayIDMap.new()

var _default_team: Team
var _teams: Dictionary[String, Team] = {}
var _players: Dictionary[String, Player] = {}
var _id_to_player: Dictionary[int, Player] = {}
var _player_count := 0
var _status := Status.STOPPED
var _map_root: Node3D

func _init() -> void:
	_default_team = create_team("Spectators")
	gamemode = StandardMode
	set_physics_process(false)

func _ready() -> void:
	Account.me.fleet_changed.connect(fleet_container.set_fleet)
	fleet_container.fleet = Account.me.fleet
	mouse_selection.plane = plane
	me = add_player("developer", Color.RED, Player.Icon.SKULL)
	me.fleet = copy_fleet(Account.me.fleet)
	host = me
	bind_commands()
	bind_variables()

func bind_commands() -> void:
	var parser := chat_log.command_parser
	parser.add_command("help", broadcast_help_message, {"<command>": TYPE_STRING}, [""] )
	parser.add_command("echo", broadcast, {"<message>": TYPE_STRING} )
	parser.add_command("start", start_countdown, {} )
	parser.add_command("stop", stop, {} )

func bind_variables() -> void:
	var parser := chat_log.command_parser
	parser.add_var("time", TYPE_FLOAT, func() -> void: broadcast("time = %.1f" % time), func(new_time: float) -> void: time = new_time)
	parser.add_var("time_scale", TYPE_FLOAT, func() -> void: broadcast("time_scale = %.4f" % time_scale), func(new_time_scale: float) -> void: time_scale = new_time_scale)
	parser.add_var("friendly_fire", TYPE_BOOL, func() -> void: broadcast("friendly_fire = %s" % friendly_fire_enabled), func(enable: bool) -> void: friendly_fire_enabled = enable)
	parser.add_var("retrofits", TYPE_BOOL, func() -> void: broadcast("retrofits = %s" % retrofits_enabled), func(enable: bool) -> void: retrofits_enabled = enable)
	parser.failed_command.connect(broadcast_help_message)
	parser.failed_get.connect(broadcast_invalid_var)
	parser.failed_set.connect(broadcast_invalid_var)

func push_message(sender_id: int, sender: String, content: String, type := ChatLogMessage.Type.TEXT) -> bool:
	return chat_log.push_message(ChatLogMessage.new(sender_id, sender, content, type) ) != null

func broadcast(content: String, type := ChatLogMessage.Type.TEXT) -> bool:
	return push_message(-1, "Server", content, type)

func send_message(content: String, type := ChatLogMessage.Type.TEXT) -> bool:
	return me != null and chat_log.push_message(ChatLogMessage.from_player(me, content, type) ) != null

func push_serverwide_message(sender_id: int, sender: String, content: String, type := ChatLogMessage.Type.TEXT) -> void:
	push_message(sender_id, sender, content, type)

func send_serverwide_message(content: String, type := ChatLogMessage.Type.TEXT) -> void:
	send_message(content, type)

func serverwide_broadcast(content: String, type := ChatLogMessage.Type.TEXT) -> void:
	broadcast(content, type)

func broadcast_help_message(command := "") -> void:
	broadcast(chat_log.command_parser.get_help_message(command) )

func broadcast_invalid_var(var_name: String, _value := "") -> void:
	broadcast("Invalid variable '%s' (valid variables: %s)" % [var_name, ", ".join(chat_log.command_parser.get_variable_list() ) ] )

func to_dict() -> Dictionary:
	return TypeChecker.to_dict(self, PROPERTIES)

func players_to_dict() -> Dictionary:
	var dict := {}
	#
	for player in _players:
		dict[player] = _players[player].to_dict()
	return dict

func teams_to_dict() -> Dictionary:
	var dict := {}
	#
	for team in _teams:
		dict[team] = _teams[team].to_dict()
	return dict

func load_dict(dict: Dictionary) -> bool:
	return TypeChecker.load_dict(self, dict, PROPERTIES, TypeChecker.CAST_NUMBERS)

func is_spectator(player: Player) -> bool:
	return player.team == _default_team

func is_team_alive(team: Team) -> bool:
	return team != _default_team and team.is_alive()

func is_player_alive(player: Player) -> bool:
	return player.team != _default_team and player.alive

func is_team_name_alive(team_name: String) -> bool:
	return is_team_alive(_teams[team_name] )

func is_player_name_alive(player_name: String) -> bool:
	return is_player_alive(_players[player_name] )

func count_players() -> int:
	return _players.size()

func count_teams() -> int:
	return _teams.size()

func get_player_from_id(id: int) -> Player:
	return _id_to_player.get(id)

func get_player(player_name: String) -> Player:
	return _players.get(player_name)

func get_team(team_name: String) -> Team:
	return _teams.get(team_name)

func get_default_team() -> Team:
	return _default_team

func get_status() -> Status:
	return _status

func get_team_names() -> Array:
	return _teams.keys()

func get_player_names() -> Array:
	return _players.keys()

func get_alive_team_names() -> Array:
	return _teams.keys().filter(is_team_name_alive)

func get_alive_player_names() -> Array:
	return _players.keys().filter(is_player_name_alive)

func get_alive_teams() -> Array[Team]:
	return _teams.values().filter(is_team_alive)

func get_alive_players() -> Array[Player]:
	return _players.values().filter(is_player_alive)

## This creates a copy (if you can, use get_player instead)
func get_players() -> Array:
	return _players.values()

## This creates a copy (if you can, use get_team instead)
func get_teams() -> Array:
	return _teams.values()

func get_state_path() -> String:
	return folder_path.path_join("state" + SaveState.FILE_EXTENSION)

func get_metadata_path() -> String:
	return folder_path.path_join("metadata.json")

func get_ship_table_path() -> String:
	return folder_path.path_join("ship_table.csv")

func get_fleet_table_path() -> String:
	return folder_path.path_join("fleet_table.csv")

func get_unit_logic_table_path() -> String:
	return folder_path.path_join("unit_logic_table.csv")

func get_map_path() -> String:
	return folder_path.path_join("map.json")

func get_ship_db_path() -> String:
	return folder_path.path_join("ships.db")

func get_unit_logic_db_path() -> String:
	return folder_path.path_join("unit_logic.db")

func get_player_manifest_path() -> String:
	return folder_path.path_join("player_manifest.csv")

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
	resource_counter.resources = me.resources
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

func set_ship_db(new_ship_db: ShipManager) -> void:
	ship_db = new_ship_db if new_ship_db != null else ShipManager.TEMPORARY

func set_unit_logic_db(new_unit_logic_db: UnitLogicManager) -> void:
	unit_logic_db = new_unit_logic_db if new_unit_logic_db != null else UnitLogicManager.TEMPORARY

func set_folder_path(new_folder_path: String) -> bool:
	if not new_folder_path.begins_with(PARENT_DIRECTORY) or new_folder_path.contains(".."):
		return false
	folder_path = new_folder_path
	return true

func set_friendly_fire_enabled(enable_friendly_fire: bool) -> void:
	if enable_friendly_fire == friendly_fire_enabled:
		return
	friendly_fire_enabled = enable_friendly_fire
	friendly_fire_changed.emit(enable_friendly_fire)

func make_folder() -> bool:
	return DirAccess.make_dir_recursive_absolute(folder_path) == OK

func open_ship_db(id: int, path := get_ship_db_path() ) -> bool:
	ship_db = ShipDatabase.create(id)
	return ship_db.load_file(path)

func open_unit_logic_db(id: int, path := get_unit_logic_db_path() ) -> bool:
	unit_logic_db = UnitLogicDatabase.create(id)
	return unit_logic_db.load_file(path)

## NOTE: This only copies the ship once (you can call this multiple times on the same ship)
func copy_ship(ship: ShipData) -> ShipData:
	if ship == null or ship.db == ship_db:
		return ship
	var uid := ship.get_uid()
	if copied_ships.has_old_id(uid):
		return ship_db.get_ship(copied_ships.find_new_id(uid) )
	var copy := ShipData.new()
	copy.copy(ship)
	ship_db.create_ship(copy)
	copied_ships.link(uid, copy.id)
	return copy

## NOTE: This only copies the fleet once (you can call this multiple times on the same fleet)
func copy_fleet(fleet: Fleet) -> Fleet:
	if fleet == null or fleet.db == ship_db:
		return fleet
	var uid := fleet.get_uid()
	if copied_fleets.has_old_id(uid):
		return ship_db.get_fleet(copied_fleets.find_new_id(uid) )
	var copy := Fleet.new()
	copy.copy(fleet)
	ship_db.create_fleet(copy)
	copied_fleets.link(uid, copy.id)
	return copy

## NOTE: This only copies the fleet and each ship once (you can call this multiple times on the same fleet)
func copy_fleet_and_ships(fleet: Fleet) -> Fleet:
	var copy := copy_fleet(fleet)
	if copy == null:
		return null
	for i in range(copy.size):
		copy.set_ship(i, copy_ship(copy.get_ship(i) ) )
	return copy

## NOTE: This only copies the unit logic once (you can call this multiple times on the same unit logic)
func copy_unit_logic(unit_logic: UnitLogic) -> UnitLogic:
	if unit_logic == null or unit_logic.db == unit_logic_db:
		return unit_logic
	var uid := unit_logic.get_uid()
	if copied_unit_logic.has_old_id(uid):
		return unit_logic_db.get_unit_logic(copied_unit_logic.find_new_id(uid) )
	var copy := UnitLogic.new()
	copy.copy(unit_logic)
	unit_logic_db.create_unit_logic(copy)
	copied_unit_logic.link(uid, copy.id)
	return copy

func _can_afford_retrofit(player: Player, copied: ShipData, cost: StrategicResources) -> bool:
	return player.resources.can_afford(cost, player.count_ships(copied) )

func retrofit_ship(ship_data: ShipData) -> bool:
	if not retrofits_enabled:
		return false
	var copied := copy_ship(ship_data)
	var cost := ship_data.cost.copy()
	var players := get_alive_players()
	cost.subtract(copied.cost)
	cost.multiply(retrofit_cost_multiplier)
	#
	if not players.all(_can_afford_retrofit.bind(copied, cost) ):
		return false
	for player: Player in players:
		player.resources.subtract(cost, player.count_ships(copied) )
	copied.retrofit(ship_data)
	return true

func retrofit_fleet(fleet: Fleet) -> void:
	copy_fleet(fleet).copy(fleet)

func retrofit_unit_logic(unit_logic: UnitLogic) -> void:
	copy_unit_logic(unit_logic).copy(unit_logic)

func validate_ships() -> bool:
	return copied_ships.keys().any(func (uid: int) -> bool: return ShipData.from_uid(uid) == null)

func validate_fleets() -> bool:
	return copied_fleets.keys().any(func (uid: int) -> bool: return Fleet.from_uid(uid) == null)

func validate_unit_logic() -> bool:
	return copied_unit_logic.keys().any(func (uid: int) -> bool: return UnitLogic.from_uid(uid) == null)

func destroy_map() -> void:
	if _map_root == null:
		return
	map_data.clear()
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
	var error_flags := map.generate(_map_root, self, rng, scenery, map_depth_limit, map_data)
	print("(Battle) Map generation: %s" % TypeChecker.format_enum(error_flags, Map.GenerationError) )
	print("(Battle) Generated %d scenery objects" % map_data.get("scenery_count", 0) )

func start_countdown() -> StartError:
	if _status != Status.STOPPED:
		return StartError.ALREADY_RUNNING
	if not gamemode.is_map_compatible(map):
		return StartError.INCOMPATIBLE_MAP
	_status = Status.STARTING
	countdown_timer.start()
	broadcast("Starting game in %s seconds" % int(countdown_timer.wait_time) )
	return StartError.OK

func start() -> StartError:
	if _status == Status.RUNNING:
		return StartError.ALREADY_RUNNING
	if not gamemode.is_map_compatible(map):
		return StartError.INCOMPATIBLE_MAP
	state.clear()
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
	broadcast("Game has started!")
	return StartError.OK

func stop() -> bool:
	if _status != Status.RUNNING:
		return false
	var winners := get_alive_teams()
	_status = Status.STOPPED
	round_timer.stop()
	set_physics_process(false)
	stopped.emit(winners)
	broadcast("Game has ended.")
	return true

## Override this method to use subclasses of Player
func _new_player(player_name: String, color: Color, icon: Player.Icon) -> Player:
	return Player.new(player_name, color, icon)

func add_player(player_name: String, color := Color.WHITE, icon := Player.Icon.NONE) -> Player:
	assert(_default_team != null)
	#
	if MAX_NUM_PLAYERS <= _players.size() or not Player.is_name_valid(player_name):
		return null
	player_name = _find_unique_name(player_name, _players)
	#
	var player := _new_player(player_name, color, icon)
	players_container.add_child(player, false, Node.INTERNAL_MODE_BACK)
	_players[player_name] = player
	player.display_name_changed.connect(_handle_player_rename.bind(player) )
	player._battle = self
	player.team = _default_team
	player.id = _player_count
	_player_count += 1
	_id_to_player[player.id] = player
	player_joined.emit(player)
	return player

func remove_player(player_name: String) -> bool:
	if not player_name in _players:
		return false
	var player := _players[player_name]
	player.queue_free()
	player_left.emit(player)
	_players.erase(player_name)
	_id_to_player.erase(player.id)
	return true

func add_bot(team: Team) -> Player:
	if team.is_full():
		return null
	var bot := add_player("bot")
	if bot == null:
		return null
	bot.team = team
	bot.is_bot = true
	gamemode.setup_bot(bot)
	return bot

func deserialize_state() -> SaveState.LoadError:
	var error := SaveState.LoadError.OK
	#
	while error == SaveState.LoadError.OK:
		error = state.deserialize_node(self)
	return error

func load_state(path := get_state_path() ) -> bool:
	return state.load_binary(path) and deserialize_state() == SaveState.LoadError.NO_MORE_DATA

func load_metadata(path := get_metadata_path() ) -> bool:
	var text := FileAccess.get_file_as_string(path)
	var json = JSON.parse_string(text)
	return json is Dictionary and load_dict(json)

func load_map(path := get_map_path() ) -> bool:
	map = Map.from_json(path)
	return map != null

func load_ship_table(path := get_ship_table_path(), delimeter := ",") -> bool:
	return copied_ships.load_csv(path, delimeter)

func load_fleet_table(path := get_fleet_table_path(), delimeter := ",") -> bool:
	return copied_fleets.load_csv(path, delimeter)

func load_unit_logic_table(path := get_unit_logic_table_path(), delimeter := ",") -> bool:
	return copied_unit_logic.load_csv(path, delimeter)

func save_state(path := get_state_path() ) -> bool:
	var error_flags: int = SaveState.SaveError.OK
	#
	for player in _players:
		error_flags |= _players[player].save_to(state)
	return state.save_binary(path) and error_flags == SaveState.SaveError.OK

func save_metadata(path := get_metadata_path(), indent := "\t") -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	return file != null and file.store_string(JSON.stringify(to_dict(), indent) )

func save_map(path := get_map_path(), indent := "\t") -> bool:
	return map != null and map.save_json(path, false, indent)

func save_ship_table(path := get_ship_table_path(), delimeter := ",") -> bool:
	return copied_ships.save_csv(path, delimeter)

func save_fleet_table(path := get_fleet_table_path(), delimeter := ",") -> bool:
	return copied_fleets.save_csv(path, delimeter)

func save_unit_logic_table(path := get_unit_logic_table_path(), delimeter := ",") -> bool:
	return copied_unit_logic.save_csv(path, delimeter)

## Requires folder_path to be set as a precondition
func load_files() -> int:
	var error_flags: int = SaveError.OK
	if not make_folder(): error_flags |= SaveError.MISSING_DIRECTORY
	if not load_metadata(): error_flags |= SaveError.METADATA_FAILURE
	if not load_state(): error_flags |= SaveError.STATE_FAILURE
	if not load_map(): error_flags |= SaveError.MAP_FAILURE
	if not load_ship_table() or not load_fleet_table() or not load_unit_logic_table(): error_flags |= SaveError.TABLE_FAILURE
	return error_flags

## Requires folder_path to be set as a precondition
func save_files() -> int:
	var error_flags: int = SaveError.OK
	if not make_folder(): error_flags |= SaveError.MISSING_DIRECTORY
	if not save_metadata(): error_flags |= SaveError.METADATA_FAILURE
	if not save_state(): error_flags |= SaveError.STATE_FAILURE
	if not save_map(): error_flags |= SaveError.MAP_FAILURE
	if not save_ship_table() or not save_fleet_table() or not save_unit_logic_table(): error_flags |= SaveError.TABLE_FAILURE
	return error_flags

func can_join_team(team: Team, player := me) -> bool:
	return _status == Status.STOPPED or (player != null and player.is_admin) and team != null

func can_team_kick(from := me) -> bool:
	return (from == host and _status == Status.STOPPED) or (from != null and from.is_admin)

func join_team(team: Team, player := me) -> bool:
	return can_join_team(team, player) and team.add_player(player)

func team_kick(player: Player, from := me) -> bool:
	return can_team_kick(from) and _default_team.add_player(player)

func kick(player: Player, from := me) -> bool:
	if player == null:
		return false
	if player.is_bot or (from != null and from.is_admin):
		return remove_player(player.display_name)
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
	resource_counter.time_sec = int(round_timer.time_left)
	resource_counter.update()

func _physics_process(dt: float) -> void:
	dt *= time_scale
	time += dt
	gamemode.battle_tick(self, dt)

func _on_countdown_timer_timeout() -> void:
	var start_error := start()
	assert(start_error == StartError.OK)

func _on_round_timer_timeout() -> void:
	var can_stop := stop()
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
