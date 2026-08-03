@tool
class_name Spawnpoint extends Scenery

var team_name := ""
var priority := 0
var spread := 0.0

static func priority_sorter(a: Spawnpoint, b: Spawnpoint) -> bool:
	return a.priority < b.priority

static func get_team_spawnpoints(map_data: Dictionary) -> Dictionary[String, Array]:
	return map_data.get("spawnpoints", {} as Dictionary[String, Array] )

func use_shared_variables(shared_variables := {} ) -> void:
	var teams: Dictionary = shared_variables.get_or_add("spawnpoints", {} as Dictionary[String, Array] )
	var team_spawnpoints: Array[Spawnpoint] = teams.get_or_add(team_name, [] as Array[Spawnpoint] )
	team_spawnpoints.append(self)

func generate_spawn_position() -> Vector3:
	var offset_distance := rng.randf_range(0.0, spread)
	var offset_rotation := rng.randf_range(0.0, TAU)
	var offset := Vector3(offset_distance, 0.0, 0.0).rotated(Vector3.UP, offset_rotation)
	return to_global(offset)
