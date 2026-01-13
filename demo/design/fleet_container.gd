extends PanelContainer

signal changed_ship

@export var ships_container: VBoxContainer

func _on_fleet_swap_button_pressed() -> void:
	globals.main.state = Main.State.FLEET

func add_fleet_divider(ship_type: String) -> void:
	var label := Label.new()
	var divider := HSeparator.new()
	label.text = ship_type
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ships_container.add_child(label)
	ships_container.add_child(divider)

func add_fleet_ship() -> bool:
	return true

func add_fleet_ships(ships: Array) -> void:
	for ship in ships:
		var button := TextureButton.new()
		button.pressed.connect(changed_ship.emit)

func set_fleet(fleet: Fleet) -> void:
	for child in ships_container.get_children():
		ships_container.remove_child(child)
	for ship_type in fleet.slots:
		add_fleet_divider(ship_type)
		add_fleet_ships(fleet.slots[ship_type])

func _ready() -> void:
	var x := Fleet.new()
	x.slots = {"Capital Ship": [], "Normal": []}
	set_fleet(x)
