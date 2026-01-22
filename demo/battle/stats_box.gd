class_name StatsBox extends MarginContainer

@export var hp: Label
@export var cost: Label
@export var mass: Label
@export var thrust: Label
@export var turn_impulse: Label

var ship: ShipData:
	set = set_ship

func _ready() -> void:
	update_stats()

func set_ship(new_ship: ShipData) -> void:
	if ship != null:
		ship.stats_updated.disconnect(update_stats)
	if new_ship != null:
		new_ship.stats_updated.connect(update_stats)
	ship = new_ship
	update_stats()

func update_stats() -> void:
	if not is_node_ready():
		return
	if ship == null:
		_clear_stats()
	else:
		_show_stats()

func _clear_stats() -> void:
	hp.text = "--"
	cost.text = "--"
	mass.text = "--"
	thrust.text = "--"
	turn_impulse.text = "--"

func _show_stats() -> void:
	hp.text = str(ship.max_hp)
	cost.text = str(ship.cost)
	mass.text = str(ship.mass)
	thrust.text = str(ship.thrust)
	turn_impulse.text = str(ship.turn_impulse)
