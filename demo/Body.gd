extends Body

func _ready():
	friction = 0
	apply_constant_force(Vector2(5, 5))
