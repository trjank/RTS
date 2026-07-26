class_name Spawnpoint extends Scenery

var distance := 0.0
var is_linear := true
var team_names := PackedStringArray()

func use_shared_variables(shared_variables := {} ) -> void:
	var spawnpoints := shared_variables.get_or_add("spawnspoints", [] as Array[Spawnpoint] ) as Array[Spawnpoint]
	spawnpoints.append(self)

func get_linear_offset() -> Vector3:
	return Vector3.ZERO

func get_circular_offset() -> Vector3:
	return Vector3.ZERO

func get_player_spawn(_i: int) -> Vector3:
	return global_position
