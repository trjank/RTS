class_name LaserData extends ProjectileData

var color := Color.WHITE
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
	_create_laser(from.get_ship(), to, max_chains)

func _create_laser(from: Ship, to: Target, chains_left: int) -> void:
	if from == null or to == null or chains_left < 0:
		return
	var laser := Line2D.new()
	laser.width = Grid.TILE_SIZE * get_width()
	laser.texture = _image.get_texture()
	laser.default_color = color
	laser.add_point(from.global_position)
	laser.add_point(to.position)
	from.get_ship().add_sibling(laser)
	# NOTE: This is intended to allow > 1.0 values because of WorldEnvironment
	laser.modulate.a = glow
	# Fade out and destroy it to conserve memory
	laser.create_tween().tween_property(laser, "modulate:a", 0.0, lifetime_sec)
	laser.get_tree().create_timer(lifetime_sec).timeout.connect(laser.queue_free)
	# TODO
	_create_laser(null, null, chains_left - 1)
