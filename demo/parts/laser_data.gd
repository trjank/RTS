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
	_create_laser(from.global_position, from.get_ship(), to, max_chains)

func _create_laser(from: Vector2, from_ship: Ship, to: Target, chains_left: int) -> void:
	if from == null or to == null or chains_left < 0:
		return
	# TODO: Reuse nodes?
	var laser := Line2D.new()
	laser.width = Grid.TILE_SIZE * display_width
	#laser.texture = _image.get_texture()
	laser.end_cap_mode = Line2D.LINE_CAP_ROUND
	laser.default_color = color
	laser.add_point(from)
	laser.add_point(to.position)
	from_ship.add_sibling(laser)
	# NOTE: This is intended to allow > 1.0 values because of WorldEnvironment
	laser.modulate = glow * Color.WHITE
	laser.modulate.a = 1.0
	# Fade out and destroy it to conserve memory
	laser.create_tween().tween_property(laser, "modulate", EMPTY_COLOR, lifetime_sec)
	laser.get_tree().create_timer(lifetime_sec).timeout.connect(laser.queue_free)
	# TODO
	#_create_laser(from_ship.global_position, from_ship, chains_left - 1)
