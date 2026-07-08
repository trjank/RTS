class_name Gamemode extends RefCounted

static var _modes: Dictionary[String, Gamemode] = {}

var name := ""

static func mode(gamemode_name: String) -> Gamemode:
	return _modes.get(gamemode_name)

func are_teams_balanced() -> bool:
	return true
