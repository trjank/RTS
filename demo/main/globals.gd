extends Node

signal main_ready

enum Layer {
	NONE = 0,
	CAMERA = 1 << 0,
	UNITS = 1 << 1,
	SHIPS = 1 << 2,
	PROJECTILES = 1 << 3,
	SCENERY = 1 << 4,
	PARTS = 1 << 5,
	EVERYTHING = CAMERA | UNITS | SHIPS | PROJECTILES | SCENERY | PARTS
}

# NOTE: You should keep configs local to avoid code injection
const CONFIG_PATH := "user://settings_DO_NOT_FILESHARE.cfg"
const SHIP_DB_PATH := "user://ship_db.db"
const UNIT_LOGIC_DB_PATH := "user://unit_logic_db.db"
const LOAD_LIMIT_SHIPS := 10
const LOAD_LIMIT_FLEETS := 10
const LOAD_LIMIT_UNIT_LOGIC := 100
const MIN_VOLUME := 0.0
const MAX_VOLUME := 100.0
const DEFAULT_VOLUME := 50.0

var main: Main:
	set = set_main
var config := ConfigFile.new()
var ship_db := ShipDatabase.new(0)
var unit_logic_db := UnitLogicDatabase.new(0)

var volume := DEFAULT_VOLUME:
	set = set_volume
var music_volume := DEFAULT_VOLUME:
	set = set_music_volume

func set_main(new_main: Main) -> void:
	main = new_main
	main_ready.emit()

func set_volume(new_volume: float) -> void:
	volume = clampf(new_volume, MIN_VOLUME, MAX_VOLUME)

func set_music_volume(new_music_volume: float) -> void:
	music_volume = clampf(new_music_volume, MIN_VOLUME, MAX_VOLUME)

func _init() -> void:
	config.load(CONFIG_PATH)
	load_ships()
	load_fleets()
	load_unit_logic()
	load_input_map()
	load_config_data()

func load_ships() -> void:
	ship_db.load_file(SHIP_DB_PATH)
	ship_db.load_ships(LOAD_LIMIT_SHIPS)

func load_fleets() -> void:
	var fleets := ship_db.load_fleets(LOAD_LIMIT_FLEETS)
	var fleet := ship_db.get_fleet(config.get_value("player", "fleet_id", -1) )
	if fleet != null:
		Account.me.fleet = fleet
	elif fleets.is_empty():
		Account.me.fleet = Fleet.new()
		ship_db.create_fleet(Account.me.fleet)
	else:
		Account.me.fleet = fleets[0]
	print("(Globals) Loaded %d fleets" % fleets.size() )

func load_unit_logic() -> void:
	unit_logic_db.load_file(UNIT_LOGIC_DB_PATH)
	unit_logic_db.load_unit_logic(LOAD_LIMIT_UNIT_LOGIC)

func load_config_data() -> void:
	Account.me.name = config.get_value("player", "name", "Unnamed")
	Account.me.color = config.get_value("player", "color", Color.WHITE)
	volume = config.get_value("sound", "volume", DEFAULT_VOLUME)
	music_volume = config.get_value("sound", "music_volume", DEFAULT_VOLUME)

func save_config_data() -> void:
	config.set_value("player", "name", Account.me.name)
	config.set_value("player", "color", Account.me.color)
	config.set_value("player", "fleet_id", Account.me.fleet.id if Account.me.fleet != null else -1)
	config.set_value("sound", "volume", volume)
	config.set_value("sound", "music_volume", music_volume)

func _load_input_map_actions(action: StringName, events: Array) -> void:
	for event in events:
		InputMap.action_add_event(action, event)

func load_input_map() -> void:
	if not config.has_section("keybinds"):
		return
	for action in config.get_section_keys("keybinds"):
		InputMap.action_erase_events(action)
		_load_input_map_actions(action, config.get_value("keybinds", action) )

func save_input_map() -> void:
	config.erase_section("keybinds")
	#
	for action in KeybindRow.get_custom_actions():
		config.set_value("keybinds", action, InputMap.action_get_events(action) )

## Returns time in microseconds
func benchmark(function: Callable) -> int:
	var start := Time.get_ticks_usec()
	await function.call()
	var end := Time.get_ticks_usec()
	return end - start

func _notification(what: int) -> void:
	if what != NOTIFICATION_WM_CLOSE_REQUEST:
		return
	save_input_map()
	save_config_data()
	config.save(CONFIG_PATH)
