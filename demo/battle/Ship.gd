class_name Ship extends Unit

@export var circle: CollisionShape2D
@export var bar_hp: PipBar
@export var bar_shield: PipBar
@export var bar_energy: PipBar

func _process(_dt):
	queue_redraw()
	#HP_bar.value = get_hp()
	#shield_bar.value = get_shield()
	#energy_bar.value = get_energy()
