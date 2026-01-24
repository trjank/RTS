class_name Ship extends Unit

@export var bar_hp: PipBar
@export var bar_shield: PipBar
@export var bar_energy: PipBar
@export var always_upright: Node2D
@export var behavior_indicator: Label

static func create() -> Ship:
	return preload("res://battle/ship.tscn").instantiate()

var data: ShipData:
	set = set_data

func set_data(new_data: ShipData) -> void:
	data = new_data
	texture = data.get_texture()

func _process(_dt: float) -> void:
	var behavior := get_behavior_flags()
	var text := ""
	if behavior & BehaviorFlags.KITE:
		text += " KITE "
	if behavior & BehaviorFlags.BROADSIDE:
		text += " BROADSIDE "
	if behavior & BehaviorFlags.TRACK:
		text += " TRACK "
	if behavior & BehaviorFlags.FLEE:
		text += " FLEE "
	if behavior & BehaviorFlags.ATTACK:
		text += " ATTACK "
	behavior_indicator.text = text
	always_upright.global_rotation = 0.0
	#HP_bar.value = get_hp()
	#shield_bar.value = get_shield()
	#energy_bar.value = get_energy()
