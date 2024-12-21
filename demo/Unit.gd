extends Unit

func _ready():
	position = Vector2(1000, 0)
	set_target($%Body)
	thrust = 1000
	turnrate = 1
	print(get_target())
	print(get_top_speed())
