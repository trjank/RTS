class_name FlamethrowerData extends ProjectileData

var max_range := 0.0
var thickness := 0.0
var speed := 1.0
var fade_speed := 1.0
var glow := 1.0
var volatility := 0.5
var start_color := Color.ORANGE
var end_color := Color.RED

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
	flames.burn()
