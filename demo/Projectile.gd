extends Projectile

func _ready():
	position = Vector2(1000, 0)
	set_target($%Body)
	speed = 70
	turnrate = 1
	print(get_target())
	print(speed)
