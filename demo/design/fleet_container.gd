extends PanelContainer

signal changed_ship(new_ship: ShipDataID)

@export var ships_container: VBoxContainer

func _on_fleet_swap_button_pressed() -> void:
	globals.main.state = Main.State.FLEET

func add_fleet_ship() -> bool:
	return true

func add_fleet_ships(ships: Array) -> void:
	for ship in ships:
		var button := TextureButton.new()
		button.pressed.connect(changed_ship.emit)

func set_fleet(fleet: Fleet) -> void:
	for child in ships_container.get_children():
		ships_container.remove_child(child)
	for ship in fleet.ships:
		#add_fleet_divider(ship_type)
		add_fleet_ships( [ship] )

func _ready() -> void:
	var x := Fleet.new()
	#set_fleet(x)
