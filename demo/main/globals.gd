extends Node

# NOTE: You should keep configs local to avoid code injection
const CONFIG_PATH := "user://settings_DO_NOT_FILESHARE.cfg"
const PARTS_JSON_PATH := "user://part_data.json"
const SHIP_DB_PATH := "user://ship_db.db"

var main: Main
var client := Client.new()
var config := ConfigFile.new()
var ship_db := ShipDatabase.new()

func _init() -> void:
	ship_db.load_file(SHIP_DB_PATH)
	config.load(CONFIG_PATH)
	# Load local account data
	client.name = config.get_value("player", "name", "<unnamed>")
	client.color = config.get_value("player", "color", Color.WHITE)
	#client.fleet = config.get_value("player", "fleet_id", -1)
	# TODO: Load server-side account data

func _notification(what: int) -> void:
	# We need to save account data before the game closes
	if what != NOTIFICATION_WM_CLOSE_REQUEST:
		return
	# NOTE: SQLite autosaves, so we do not need to manually save databases
	config.set_value("player", "name", client.name)
	config.set_value("player", "color", client.color)
	#config.set_value("player", "fleet_id", client.fleet.id)
	config.save(CONFIG_PATH)
