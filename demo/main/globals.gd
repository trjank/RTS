extends Node

signal main_ready

enum Layer {
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
const PARTS_JSON_PATH := "res://parts/part_data.json"
const SHIP_DB_PATH := "user://ship_db.db"
const LOAD_LIMIT_SHIPS := 100
const LOAD_LIMIT_FLEETS := 100
const MIN_VOLUME := 0.0
const DEFAULT_VOLUME := 50.0
const MAX_VOLUME := 100.0

var main: Main:
	set = set_main
var client := Client2.new()
var config := ConfigFile.new()
var ship_db := ShipDatabase.new()
var part_manager := PartManager.new()

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
	_load_json()
	config.load(CONFIG_PATH)
	ship_db.part_manager = part_manager
	ship_db.load_file(SHIP_DB_PATH)
	# Load local account data
	ship_db.load_ships(LOAD_LIMIT_SHIPS)
	var fleets := ship_db.load_fleets(LOAD_LIMIT_FLEETS)
	var fleet := ship_db.get_fleet(config.get_value("player", "fleet_id", -1) )
	_load_config_data()
	if fleet != null:
		client.fleet = fleet
	elif fleets.is_empty():
		client.fleet = Fleet.new()
		ship_db.create_fleet(client.fleet)
	else:
		client.fleet = fleets[0]

func _load_config_data() -> void:
	_load_input_map()
	client.name = config.get_value("player", "name", "Unnamed")
	client.color = config.get_value("player", "color", Color.WHITE)
	volume = config.get_value("sound", "volume", DEFAULT_VOLUME)
	music_volume = config.get_value("sound", "music_volume", DEFAULT_VOLUME)

func _load_json() -> void:
	var error_flags := part_manager.load_json(PARTS_JSON_PATH)
	if error_flags & PartManager.LoadError.FILE_NOT_FOUND:
		push_error("File %s does not exist" % PARTS_JSON_PATH)
	if error_flags & PartManager.LoadError.INCORRECT_FORMAT:
		push_error("JSON is setup incorrectly")
	if error_flags & PartManager.LoadError.INVALID_PART:
		push_error("Invalid part")
	if error_flags & PartManager.LoadError.INVALID_PART_PROPERTIES:
		push_error("Invalid part properties")

func _load_input_map_actions(action: StringName, events: Array) -> void:
	for event in events:
		InputMap.action_add_event(action, event)

func _load_input_map() -> void:
	if not config.has_section("keybinds"):
		return
	for action in config.get_section_keys("keybinds"):
		InputMap.action_erase_events(action)
		_load_input_map_actions(action, config.get_value("keybinds", action) )

func _save_input_map() -> void:
	config.erase_section("keybinds")
	for action in KeybindRow.get_custom_actions():
		config.set_value("keybinds", action, InputMap.action_get_events(action) )

func _notification(what: int) -> void:
	# We need to save account data before the game closes
	if what != NOTIFICATION_WM_CLOSE_REQUEST:
		return
	# NOTE: SQLite autosaves, so we do not need to manually save databases
	config.set_value("player", "name", client.name)
	config.set_value("player", "color", client.color)
	config.set_value("sound", "volume", volume)
	config.set_value("sound", "music_volume", music_volume)
	_save_input_map()
	#config.set_value("player", "fleet_id", client.fleet.id)
	config.save(CONFIG_PATH)

## Returns average time in microseconds
func benchmark(f: Callable, iterations := 1) -> float:
	var start := Time.get_ticks_usec()
	#
	for i in iterations:
		await f.call()
	var end := Time.get_ticks_usec()
	var dt := float(end - start)
	return dt / iterations
