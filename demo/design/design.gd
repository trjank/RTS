extends Node2D

@export var container: TabContainer
@export var part_grouping: PartGrouping
@export var mirror_mode_button: TextureButton
@export var mirror_axis: Line2D
@export var info_text: Label
#var fleet:Fleet
@onready var fleet_dropdown = %FleetDropdown
@onready var rename_fleet_popup = %RenameFleetPopup
@onready var grid = %Grid
@onready var ship_buttons = %ship_buttons
@onready var manager := JSONPartManager.new()
@onready var ship_button = preload("res://design/fleet_button.tscn")
@onready var testsprite = %test
const UNSAVED_SHIP_ID = -1
const UNSAVED_SHIP_NAME = "Untitled"
const EMPTY_SLOT_NAME = " "
const UNSAVED_FLEET_NAME = "*Unsaved"
const UNSAVED_FLEET_ID  = -1
const DEFAULT_SLOT = 0
const FLEET_SIZE = 10

#var fleet_manager := FleetManager.new()
var rename:String = "*Unsaved"
var ship_name = EMPTY_SLOT_NAME
var current_ship_slot = DEFAULT_SLOT
var current_fleet = 1
var ship_slots = {}
var slot_buttons = {}
var unsaved:bool = false
#@onready var fleet_folder = DirAccess.open("user://fleets")
@onready var db = $"../modules".db

var testStr = "ENT2,35.0,33.0,0
ENT2,35.0,35.0,0
HAS2,36.5,33.0,2
HAS2,36.5,35.0,2
HAF1,34.5,36.5,0
HAF1,35.5,36.5,0
HAF1,36.5,36.5,0"

func load_ship_from_db(ship_id:int):
	var ship_data = db.get_ship(ship_id)
	if not ship_data:
		print("No ship data found for id: %d" % ship_id)
		return false
	var stats = ship_data[0]["stats"]
	print(stats)
	load_ship(stats)
	return true


func load_ship(stats:String):
	var lines = stats.trim_suffix(" ").split("\n")
	for csv_line in lines:
		var line = csv_line.split(",")
		if line.size() < 4:
			continue
		var part:PartData = manager.lookup_code(line[0])
		var partPosition = Vector2(float(line[1]),float(line[2]))
		var partRotation = int(line[3])
		#var mirrored = (int(line[3]) > 3)
		var newPart = Part.create_from(part)
		grid.add_child(newPart)
		#need knowledge of 
		partPosition = partPosition - Vector2(1,1)#- Vector2(Rect2i(Vector2(1,1),Vector2(64,64)).get_center() + Vector2i(1,1))
		partPosition = partPosition*32
		newPart.position =   partPosition
		newPart.rotation = snapped(newPart.rotation,PI/2) + partRotation*PI/2 
		#newPart.set_data(part)

func resize_grid(size: Vector2)->void:
	size *= PartData.PX_PER_GRID_SQUARE
	grid.region_rect.size   = size
	mirror_axis.position.x  = size.x * 0.5
	mirror_axis.points[1].y = size.y

func save_ship(ship: ShipData):
	var current_id = ship_slots[current_ship_slot]
	ship.encode_csv(",")
	var ship_stats := ship.get_csv()
	if current_id > -1:
		print("Updating ship stats for ship id: %d" % current_id)
		db.update_ship_stats(current_id, ship_stats)
		return
	var results = db.create_ship(ship_name, ship_stats)

	if results.size() > 0:
		print("created new ship with id: %d" % results[0]["id"])
		var newShip = results[0]
		db.add_ship_to_fleet(current_fleet, newShip["id"])
		ship_slots[current_ship_slot] = newShip["id"]
		print(ship)
		slot_buttons[current_ship_slot].button.text = "Untitled"
		slot_buttons[current_ship_slot].delete_button.visible = true

func save_ship_img(ship: ShipData):
	var bounds_x = ship.get_ship_bounds_x()
	var bounds_y = ship.get_ship_bounds_y()
	#var bounds = Vector2(bounds_x.x - bounds_x.y, bounds_y.x - bounds_y.y)
	#var square_size = max(bounds.x, bounds.y) + 1
	#var padding = 64
	print(bounds_x)
	print(bounds_y)
	#var img = Image.load_from_file("user://ship.png").get_region(Rect2i(bounds_x.y*32 - 32 -padding/2 ,bounds_y.y*32 - 32 -padding/2, square_size*32 + 32 + padding, square_size*32 + 32 + padding))
	#img.save_png("user://ship2.png")
	#print(bounds)

func _input(event):
	if event.is_action_pressed("save"):
		print("saving...")
		part_grouping.clear_parts() # <-- This is VERY important
		var ship := ShipData.create(64, 64)
		for part in grid.get_children():
			ship.add_part_node(part)
			print("->", part.rotation, " | ", part.scale.x < 0, " | ", part.get_class())
		print(ship.count_parts())
		save_ship(ship)
		#save_ship_img(ship)

func clear_grid():
	print("clearing!")
	part_grouping.clear_parts()
	for part in grid.get_children():
		grid.remove_child(part)
	grid.add_child(part_grouping)

func change_slot(new_slot):
	clear_grid()
	#var current_button = 
	var new_ship_id = ship_slots[new_slot]
	print("changing to button with ship_id: %d" % new_ship_id)
	slot_buttons[current_ship_slot].delete_button.visible = false
	current_ship_slot = new_slot
	
	#
	if new_ship_id < 0:
		return
	var ship_data = db.get_ship(new_ship_id)
	if not ship_data:
		print("No ship data found for id: %d" % new_ship_id)
		return
	#if load_ship_from_db(new_ship_id)
	
	load_ship(ship_data[0]["stats"])
	#	print("Loaded ship with id: %d" % new_ship_id)
	slot_buttons[new_slot].delete_button.visible = true
	#data[SHIP_BUTTON].delete_button.connect(clear_current_slot)


func create_ship_button(button_name, method, del_method):
	var new_button = ship_button.instantiate()
	new_button.method = method
	new_button.delete_method = del_method
	new_button.button_name = button_name
	return new_button  
func clear_current_slot():
	clear_grid()
	ship_slots[current_ship_slot] = UNSAVED_SHIP_ID
	slot_buttons[current_ship_slot].button.text = UNSAVED_SHIP_NAME
	slot_buttons[current_ship_slot].delete_button.visible = false


func create_ship_buttons():
	var btn_name = EMPTY_SLOT_NAME
	for num in range(FLEET_SIZE):
		var button = create_ship_button(btn_name,change_slot.bind(num),clear_current_slot)
		slot_buttons[num] = button
		ship_buttons.add_child(button)

func set_ships(ships):
	ships.resize(FLEET_SIZE)
	
	for num in range(FLEET_SIZE):
		var cur_ship = ships[num]
		var btn_name = EMPTY_SLOT_NAME
		var ship_id = -1
		if cur_ship:
			btn_name = "Slot "+str(num)+":"+cur_ship["name"]
			ship_id = cur_ship["id"]
		
		slot_buttons[num].button.text = btn_name
		ship_slots[num] = ship_id



func setup_part_buttons():
	manager.load_json("user://part_data.json")
	PartButton.part_container = part_grouping
	for atlas_id in range(1, manager.count_parts()):
		var part := manager.lookup_id(atlas_id)
		var part_container := container.get_node(part.get_tab())
		var part_display := PartButton.new()
		part_display.part_data = part
		part_display.texture_normal = part.get_texture()
		part_display.set_display_size( part.get_size() )
		if not part_container:
			push_warning("Tab '%s' does not exist" % part_container)
		else:
			part_container.add_child(part_display)

func setup_fleet_buttons():
	var fleets = db.get_fleets()
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
	#setup global db connection?
	resize(Vector2(64, 64))
	var ships = db.get_ships_in_fleet(current_fleet)
	print(ships)
	create_ship_buttons()
	setup_part_buttons()
	setup_fleet_buttons()
	#set_fleet(1)


func set_fleet(new_fleet):
	var ships = db.get_ships_in_fleet(new_fleet)
	current_fleet = new_fleet
	set_ships(ships)

	
const NEW_FLEET_OPTION := 0
const RENAME_FLEET_OPTION := 1
const DELETE_FLEET_OPTION := 2
const NO_OPTION := 3

func update_fleet_dropdown():
	var fleets = db.get_fleets()
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
			db.remove_fleet_and_ships(current_fleet)
		NEW_FLEET_OPTION:
			var new_fleet = db.create_fleet("Untitled Fleet")
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



func on_valid_rename(new_rename):
	db.rename_fleet(current_fleet,new_rename)
	update_fleet_dropdown()
	# if unsaved:
	# 	if(!fleet_manager.fleet_exists(new_rename)):
	# 		fleet = Fleet.new()
	# 		fleet.set_name(new_rename)
	# 		fleet_folder.make_dir(new_rename)
	# 		unsaved = false



			
