class_name Spawnpoint extends Scenery

var distance := 0.0
var angle := 0.0
var arc := 0.0:
	set = set_arc
var team := "A"
var spawn_order := PackedInt32Array()

func get_max_players() -> int:
	return spawn_order.size()

func set_arc(new_arc: float) -> void:
	arc = absf(new_arc)

func use_shared_variables(shared_variables := {} ) -> void:
	var spawnpoints := shared_variables.get_or_add("spawnpoints", [] as Array[Spawnpoint] ) as Array[Spawnpoint]
	spawnpoints.append(self)

func get_player_angle(i: int) -> float:
	var separation := arc / get_max_players()
	return (angle + i * separation + 0.5 * arc) if i > 0 else angle

func get_player_spawn(i: int) -> Vector3:
	var radians := deg_to_rad(get_player_angle(i) )
	return Vector3.RIGHT.rotated(Vector3.UP, radians)

func get_global_player_spawn(i: int) -> Vector3:
	return to_global(get_player_spawn(i) )
