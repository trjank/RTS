class_name BattleState extends RefCounted

var date_created := Time.get_date_string_from_system()
var time_scale := 1.0
var time := 0.0
var map: Map
var map_seed := 0
var map_depth_limit := 5
var units := []

var _empty := true
#var _ship_db := ShipDatabase.new()

static func from_dict() -> BattleState:
	return null

func is_empty() -> bool:
	return _empty

func to_dict() -> Dictionary:
	return {
		"date_created": date_created,
		"time_scale": time_scale,
		"time": time,
		"map": map.to_dict(),
		"map_seed": map_seed,
		"map_depth_limit": map_depth_limit
	}

func _serialize_unit() -> void:
	pass

func _deserialize_unit() -> void:
	pass

func load_dict() -> void:
	pass

func save_json(_path: String) -> void:
	pass

func load_json(_path: String) -> void:
	pass
