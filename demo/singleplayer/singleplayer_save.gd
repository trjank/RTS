class_name SingleplayerSave extends RefCounted

static var saves: Array[SingleplayerSave] = []

# TODO: Settings stored and loaded from file

var difficulty := 0.0
var date_created := ""
var units

func is_empty() -> bool:
	return true

func save_json(_path: String) -> void:
	pass

func load_json(_path: String) -> void:
	pass
