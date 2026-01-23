class_name Ship extends Unit

@export var bar_hp: PipBar
@export var bar_shield: PipBar
@export var bar_energy: PipBar
@export var always_upright: Node2D

static func create() -> Ship:
	return preload("res://battle/ship.tscn").instantiate()

var data: ShipData:
	set = set_data

func set_data(new_data: ShipData) -> void:
	data = new_data
	texture = data.get_texture()

func _process(_dt: float) -> void:
	always_upright.global_rotation = 0.0
	#HP_bar.value = get_hp()
	#shield_bar.value = get_shield()
	#energy_bar.value = get_energy()
