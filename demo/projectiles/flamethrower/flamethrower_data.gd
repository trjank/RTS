class_name FlamethrowerData extends ProjectileData

const MIN_PARTICULATES := 0.0
const MAX_PARTICULATES := 1.0

var thickness := 1.0
var speed := 1.0
var glow := 1.0
var volatility := 0.5
var pitch_scale := 1.0:
	set = set_pitch_scale
var particulates := 0.3:
	set = set_particulates
var start_color := Color.ORANGE
var end_color := Color.RED

func get_speed() -> float:
	return speed

func set_pitch_scale(new_pitch_scale: float) -> void:
	pitch_scale = absf(new_pitch_scale)

func set_particulates(new_particulates: float) -> void:
	particulates = clampf(new_particulates, MIN_PARTICULATES, MAX_PARTICULATES)

func _reuse_flamethrower(cache: Array[Node3D] ) -> void:
	assert(cache[0] is Flamethrower)
	#
	cache[0].burn()

func create_projectile(from: Weapon, _to: Target, cache: Array[Node3D] ) -> void:
	assert(from != null)
	#
	if not cache.is_empty():
		return _reuse_flamethrower(cache)
	var flames := Flamethrower.create()
	from.add_child(flames)
	cache.push_back(flames)
	flames.data = self
	flames.excluded = [from.get_ship().get_radar_signature() ]
	flames.modifiers = from.modifiers
	flames.player_owner = from.get_player_owner()
	flames.position = from.get_barrel_position()
	flames.burn()
