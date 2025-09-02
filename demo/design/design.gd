extends Node2D

@export var overlay: CanvasLayer
@export var part_grouping: PartGrouping
@export var mirror_mode_button: TextureButton
@export var mirror_axis: Line2D
@export var info_text: Label
var fleet

@onready var fleets_container = %FleetContainer
@onready var parts_container = %PartsContainer
@onready var fleet_dropdown = %FleetDropdown
@onready var rename_fleet_popup = %RenameFleetPopup
@onready var grid = %Grid
@onready var ship_buttons = %ship_buttons
@onready var ship_button = preload("res://design/fleet_button.tscn")
@onready var testsprite = %test

const UNSAVED_SHIP_ID := -1
const UNSAVED_SHIP_NAME := "Untitled"
const EMPTY_SLOT_NAME := " "
const UNSAVED_FLEET_NAME := "*Unsaved"
const UNSAVED_FLEET_ID := -1
const DEFAULT_SLOT := 0
const FLEET_SIZE := 10

var parts_manager := JSONPartManager.new()
var current_fleet: FleetID
var current_ship: ShipDataID
var rename := "*Unsaved"
var ship_name := EMPTY_SLOT_NAME
var slot_buttons := {}
var unsaved := false

@onready var ship_db: ShipDatabase = $"../modules".db

func resize_grid(size: Vector2)->void:
	size *= PartData.PX_PER_GRID_SQUARE
	grid.region_rect.size = size
	mirror_axis.position.x = 0.5 * size.x
	mirror_axis.points[1].y = size.y

func load_ship(ship: ShipData):
	for part_id in range(1, 1 + ship.count_parts()):
		var part := Part.create_from(ship.get_part_data(part_id))
		var orientation := ship.get_part_orientation(part_id)
		grid.add_child(part)
		part.set_orientation(orientation)
		# No need to snap to grid since the region is a Rect2i
		part.position = ship.get_part_region(part_id).position

func save_ship(ship_id: ShipDataID)->void:
	var ship := ship_id.ship_data
	CPUImageBuilder.build_image(ship)
	ship_db.save_ship(ship_id)
	#var current_id = ship_slots[current_ship_slot]
	#ship.encode_csv(",")
	#var ship_stats := ship.get_csv()
	#if current_id > -1:
		#print("Updating ship stats for ship id: %d" % current_id)
		#db.update_ship_stats(current_id, ship_stats)
		#return
	#var results = db.create_ship(ship_name, ship_stats)

	#if results.size() > 0:
		#print("created new ship with id: %d" % results[0]["id"])
		#var newShip = results[0]
		#db.add_ship_to_fleet(current_fleet, newShip["id"])
		#ship_slots[current_ship_slot] = newShip["id"]
		#print(ship)
		#slot_buttons[current_ship_slot].button.text = "Untitled"
		#slot_buttons[current_ship_slot].delete_button.visible = true

func _input(event)->void:
	if event.is_action_pressed("save"):
		print("saving...")
		part_grouping.clear_parts() # <-- This is VERY important
		var ship := ShipData.create(64, 64)
		for part in grid.get_children():
			ship.add_part_node(part)
			print("->", part.rotation, " | ", part.scale.x < 0, " | ", part.get_class())
		print(ship.count_parts())
		#save_ship(ship)

func clear_grid()->void:
	part_grouping.clear_parts()
	for part in grid.get_children():
		grid.remove_child(part)

func change_slot(slot: String, slot_num: int)->void:
	clear_grid()
	var new_ship_id = current_fleet.slots[slot][slot_num]
	#slot_buttons[current_ship_slot].delete_button.visible = false
	current_ship = new_ship_id
	
	if new_ship_id.ship_data.is_empty():
		ship_db.sync_ship(new_ship_id)
	#slot_buttons[new_slot].delete_button.visible = true
	#data[SHIP_BUTTON].delete_button.connect(clear_current_slot)


func create_ship_button(button_name, method, del_method):
	var new_button = ship_button.instantiate()
	new_button.method = method
	new_button.delete_method = del_method
	new_button.button_name = button_name
	return new_button

func clear_current_slot():
	clear_grid()
	#ship_slots[current_ship_slot] = UNSAVED_SHIP_ID
	#slot_buttons[current_ship_slot].button.text = UNSAVED_SHIP_NAME
	#slot_buttons[current_ship_slot].delete_button.visible = false

func create_ship_buttons():
	var btn_name = EMPTY_SLOT_NAME
	for num in range(FLEET_SIZE):
		var button = create_ship_button(btn_name,change_slot.bind(num),clear_current_slot)
		slot_buttons[num] = button
		ship_buttons.add_child(button)

func set_ships(ships):
	ships.resize(FLEET_SIZE)
	#
	#for num in range(FLEET_SIZE):
		#var cur_ship = ships[num]
		#var btn_name = EMPTY_SLOT_NAME
		#var ship_id = -1
		#if cur_ship:
			#btn_name = "Slot "+str(num)+":"+cur_ship["name"]
			#ship_id = cur_ship["id"]
		#
		#slot_buttons[num].button.text = btn_name
		#ship_slots[num] = ship_id



func setup_part_buttons():
	parts_manager.load_json("user://part_data.json")
	PartButton.part_container = part_grouping
	for atlas_id in range(1, manager.count_parts()):
		var part := manager.lookup_id(atlas_id)
		var tab := part.get_tab()
		var part_display := PartButton.new()
		part_display.part_data = part
		part_display.texture_normal = part.get_texture()
		part_display.set_display_size( part.get_size() )
		#part_display.set_stretch_mode(TextureButton.StretchMode.STRETCH_KEEP_ASPECT_CENTERED)
	
		parts_container.add_part(tab, part_display)
		#if not container:
		#	push_warning("Tab '%s' does not exist" % container)
		#else:
		#	container.add_child(part_display)

func setup_fleet_buttons():
	var fleets = ship_db.get_fleets(100)
	if not fleets:
		print("No fleets found in database.")
		return
	print(fleets)
	fleet_dropdown.set_fleets(fleets)
	fleet_dropdown.item_selected.connect(on_selected_fleet)
	rename_fleet_popup.valid_rename.connect(on_valid_rename)
	

func resize(new_size: Vector2)->void:
	grid.region_rect.size = new_size * PartData.PX_PER_GRID_SQUARE

func _ready():
	ship_db.part_manager = parts_manager
	#setup global db connection?
	#resize(Vector2(64, 64))
	var ships = db.get_ships_in_fleet(current_fleet)
	print(ships)
	#create_ship_buttons()
	setup_part_buttons()
	#setup_fleet_buttons()
	#set_fleet(1)


func set_fleet(new_fleet):
	#var ships = db.get_ships_in_fleet(new_fleet)
	current_fleet = new_fleet
	#set_ships(ships)


const NEW_FLEET_OPTION := 0
const RENAME_FLEET_OPTION := 1
const DELETE_FLEET_OPTION := 2
const NO_OPTION := 3

func update_fleet_dropdown():
	var fleets := ship_db.get_fleets(100)
	fleet_dropdown.clear()
	fleet_dropdown.add_item("New Fleet")
	fleet_dropdown.add_item("Rename Fleet")
	fleet_dropdown.add_item("Delete Fleet")
	fleet_dropdown.add_item(" ")
	fleet_dropdown.set_fleets(fleets)

func on_selected_fleet(option):
	match option:
		RENAME_FLEET_OPTION:
			# Open a popup window with a textbox
			#select(previous_option)
			#option_to_rename = selected
			rename_fleet_popup.show()
		DELETE_FLEET_OPTION:
			fleet_dropdown.remove_item(option)
			#db.remove_fleet_and_ships(current_fleet)
		NEW_FLEET_OPTION:
			var new_fleet = ship_db.create_fleet(Fleet.new())
			fleet_dropdown.fleets.append(new_fleet)
			fleet_dropdown.add_item("Untitled Fleet", true)
			fleet_dropdown.select(fleet_dropdown.item_count - 1)
			
			#add_item(NO_NAME, 0)
			#select(item_count - 1)
			#option_to_rename = selected
			rename_fleet_popup.show()
		_:
			if(option < 4):
				return
			
			var fleet_index = option - 4
			var fleet_selected = fleet_dropdown.fleets[fleet_index]
			print("Selected fleet:")
			print(fleet_selected)
			set_fleet(fleet_selected["id"])

func on_valid_rename(new_name: String)->void:
	current_fleet.name = new_name
	ship_db.save_fleet(current_fleet)
	update_fleet_dropdown()
