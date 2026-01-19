extends Node

# NOTE: You should keep configs local to avoid code injection
const CONFIG_PATH := "user://settings_DO_NOT_FILESHARE.cfg"
const PARTS_JSON_PATH := "user://part_data.json"
const SHIP_DB_PATH := "user://ship_db.db"
const LOAD_LIMIT_SHIPS := 100
const LOAD_LIMIT_FLEETS := 100

var main: Main
var client := Client.new()
var config := ConfigFile.new()
var ship_db := ShipDatabase.new()
var part_manager := PartManager.new()

func _init() -> void:
	_load_json()
	config.load(CONFIG_PATH)
	ship_db.part_manager = part_manager
	ship_db.load_file(SHIP_DB_PATH)
	# Load local account data
	ship_db.load_ships(LOAD_LIMIT_SHIPS)
	var fleets := ship_db.load_fleets(LOAD_LIMIT_FLEETS)
	var fleet := ship_db.get_fleet(config.get_value("player", "fleet_id", -1) )
	client.name = config.get_value("player", "name", "Unnamed")
	client.color = config.get_value("player", "color", Color.WHITE)
	if fleet != null:
		client.fleet = fleet
	elif fleets.is_empty():
		client.fleet = ship_db.create_fleet(Fleet.new() )
	else:
		client.fleet = fleets[0]

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

func _notification(what: int) -> void:
	# We need to save account data before the game closes
	if what != NOTIFICATION_WM_CLOSE_REQUEST:
		return
	# NOTE: SQLite autosaves, so we do not need to manually save databases
	config.set_value("player", "name", client.name)
	config.set_value("player", "color", client.color)
	#config.set_value("player", "fleet_id", client.fleet.id)
	config.save(CONFIG_PATH)

func benchmark(f: Callable, iterations := 100) -> float:
	var start := Time.get_ticks_usec()
	for i in iterations:
		await f.call()
	var end := Time.get_ticks_usec()
	var dt := float(end - start)
	# Return average time in microseconds
	return dt / iterations
