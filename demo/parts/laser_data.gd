class_name LaserData extends ProjectileData

const EMPTY_COLOR := Color(0.0, 0.0, 0.0, 0.0)

var display_width := 1.0
var color := Color.RED
var glow := 1.0
var lifetime_sec := 0.5
var max_chains := 0
var chain_multiplier := 0.5

func get_net_multiplier(num_chains := max_chains) -> float:
	assert(0.0 <= chain_multiplier and chain_multiplier < 1.0)
	# NOTE: This is just the geometric series formula
	return (1.0 - chain_multiplier ** (num_chains + 1) ) / (1.0 - chain_multiplier)

func get_net_damage(num_chains := max_chains) -> float:
	return get_net_multiplier(num_chains) * damage

func get_net_energy_drain(num_chains := max_chains) -> float:
	return get_net_multiplier(num_chains) * energy_drain

func create_projectile(from: Part, to: Target) -> void:
	assert(from != null)
	#
	var ship := from.get_ship()
	if to is RadarSignature:
		_split_beam(ship, to.as_unit(), [], max_chains, 1.0)
		#_chain_laser(ship, to.as_unit(), 1.0, [] )
	else:
		_create_laser(ship, to.position, 1.0, from.global_position)

func _create_laser(from: Ship, to: Vector2, multiplier := 1.0, from_position := from.global_position) -> void:
	var laser := Line2D.new()
	laser.width = Grid.TILE_SIZE * display_width * multiplier
	laser.texture = _image.get_texture()
	laser.end_cap_mode = Line2D.LINE_CAP_ROUND
	laser.texture_mode = Line2D.LINE_TEXTURE_TILE
	laser.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	laser.default_color = color
	laser.add_point(from_position)
	laser.add_point(to)
	laser.modulate = Color(glow, glow, glow, 1.0)
	#
	from.add_sibling(laser)
	laser.global_transform = Transform2D.IDENTITY
	# Fade out and destroy it to conserve memory
	laser.create_tween().tween_property(laser, "modulate", EMPTY_COLOR, lifetime_sec)
	laser.get_tree().create_timer(lifetime_sec).timeout.connect(laser.queue_free)

func _chain_laser(from: Ship, to: Ship, multiplier: float, visited: Array[Ship] ) -> void:
	if to == null or max_chains <= visited.size() or to in visited:
		return
	var nearest_enemy := to.get_nearest(func (ship: Ship) -> bool:
		return to.is_friend(ship) and not ship in visited
	)
	_create_laser(from, to.global_position, multiplier)
	to.hit(damage * multiplier, from.player_owner, shield_penetration)
	#to.drain_energy(energy_drain * multiplier)
	visited.push_back(to)
	_chain_laser(to, nearest_enemy, multiplier * chain_multiplier, visited)

func _split_beam(from: Ship, to: Ship, visited: Array[Ship], depth_left: int, multiplier: float) -> void:
	if depth_left <= 0:
		return
	var ships := to.filter_nearest(func (ship: Ship) -> bool:
		return to.is_friend(ship) and not ship in visited
	)
	from.hit(damage * multiplier, from.player_owner, shield_penetration)
	from.energy -= energy_drain * multiplier
	multiplier *= chain_multiplier
	_create_laser(from, to.global_position, multiplier)
	for ship in ships:
		visited.append(ship)
		_split_beam(to, ship, visited, depth_left - 1, multiplier)
