class_name StatsBox extends MarginContainer

@export var hp_label: Label
@export var cost_label: Label
@export var mass_label: Label
@export var thrust_label: Label
@export var torque_label: Label
@export var energy_label: Label

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
	hp_label.text = "--"
	cost_label.text = "--"
	mass_label.text = "--"
	thrust_label.text = "--"
	torque_label.text = "--"
	energy_label.text = "--"

func _show_stats() -> void:
	hp_label.text = "%.0f" % ship.max_hp
	cost_label.text = "$%.0f" % ship.cost.alloy
	mass_label.text = "%.0f kg" % ship.mass
	thrust_label.text = "%.0f N" % ship.thrust
	torque_label.text = "%.0f" % ship.torque
	energy_label.text = "%.0f at %.0f/s" % [ship.max_energy, ship.energy_per_sec]
