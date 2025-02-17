extends Ship

@export var circle: CollisionShape2D
@export var HP_bar: ProgressBar
@export var shield_bar: ProgressBar
@export var energy_bar: ProgressBar

func set_circle_radius(new_radius: float)->void:
	circle.shape.radius = new_radius

func _process(_dt):
	queue_redraw()
	HP_bar.value = get_HP()
	shield_bar.value = get_shield()
	energy_bar.value = get_energy()
