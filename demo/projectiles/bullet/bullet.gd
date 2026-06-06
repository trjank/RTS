class_name Bullet extends Unit

var data: BulletData:
	set = set_data

static func create() -> Bullet:
	return preload("res://projectiles/bullet/bullet.tscn").instantiate()

func _init() -> void:
	collision_layer = globals.Layer.PROJECTILES

func set_data(new_data: BulletData) -> void:
	if new_data == null:
		return queue_free()
	data = new_data
	size = Vector2(50.0, 50.0)
	mass = data.mass
	texture = data.get_image().get_texture()
	linear_damp = data.linear_damp
	torque = data.torque

func begin_death_timer() -> void:
	get_tree().create_timer(data.lifetime_sec).timeout.connect(queue_free)

func order_attack() -> void:
	assert(data != null)
	#
	if data.is_missile():
		track()
	else:
		attack()
