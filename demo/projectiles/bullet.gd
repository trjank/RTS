class_name Bullet extends Unit

var data: BulletData:
	set = set_data

static func create() -> Bullet:
	return preload("res://projectiles/bullet.tscn").instantiate()

func _init() -> void:
	collision_layer = globals.Layer.PROJECTILES

func set_data(new_data: BulletData) -> void:
	if new_data == null:
		push_warning("Bullet has null data and will be removed")
		return queue_free()
	data = new_data
	size = Vector2(50.0, 50.0)
	mass = data.mass
	texture = data.get_image().get_texture()
	linear_damp = data.linear_damp
	turnrate = data.turn_impulse

func begin_death_timer() -> void:
	get_tree().create_timer(data.lifetime_sec).timeout.connect(queue_free)

func order_attack() -> void:
	assert(data != null)
	#
	if data.is_missile():
		track()
	else:
		attack()
