extends Node

var main: Main = null
var config := ConfigFile.new()
var ship_db := ShipDatabase.new()

const CONFIG_PATH := "user://settings_DO_NOT_FILESHARE.cfg"
const SHIP_DB_PATH := "user://ships_db.db"

func _init()->void:
	ship_db.load_file(SHIP_DB_PATH)
	# Unfortunately, as of 4.4, this is subject to code injection
	# This is less of a problem if the file remains local (no sharing)
	config.load(CONFIG_PATH)

func _notification(what: int)->void:
	if what != NOTIFICATION_WM_CLOSE_REQUEST: return
	# SQLite autosaves, so we do not need to manually save ship_db
	config.save(CONFIG_PATH)
