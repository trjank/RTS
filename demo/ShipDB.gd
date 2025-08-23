class_name ShipDB extends RefCounted

var db: SQLite

const TABLE_FORMAT := {
	
}

func load_db(path: String)->void:
	db = SQLite.new()
	db.path = path
	db.open_db()

func load_ship()->void:
	return

func load_fleet()->void:
	return
