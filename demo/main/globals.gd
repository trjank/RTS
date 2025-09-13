extends Node

const CONFIG_PATH := "user://settings_DO_NOT_FILESHARE.cfg"
const SHIP_DB_PATH := "user://ship_db.db"

var main: Main = null
var config := ConfigFile.new()
var ship_db := ShipDatabase.new()
var player_color: Color: set = set_player_color
var player_name: String: set = set_player_name

func set_player_color(new_color: Color)->void:
	player_color = new_color
	config.set_value("player", "color", new_color)

func set_player_name(new_name: String)->void:
	# Length limits are only imposed in battles (see Player.MAX_NAME_LENGTH)
	player_name = new_name
	config.set_value("player", "name", new_name)

func _init()->void:
	ship_db.load_file(SHIP_DB_PATH)
	# Unfortunately, as of 4.4, configs are subject to code injection
	# This is less of a problem if the file remains local (no sharing)
	config.load(CONFIG_PATH)
	player_color = config.get_value("player", "color", Color.WHITE)
	player_name  = config.get_value("player", "name", "Commander")

func _notification(what: int)->void:
	if what != NOTIFICATION_WM_CLOSE_REQUEST: return
	# SQLite autosaves, so we do not need to manually save databases
	config.save(CONFIG_PATH)
