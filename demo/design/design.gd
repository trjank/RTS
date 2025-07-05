extends Node2D

@export var overlay: CanvasLayer
@export var container: TabContainer
@export var part_grouping: PartGrouping
@export var grid: Sprite2D
@export var info_text: Label
var fleet:Fleet
@onready var fleet_dropdown = %FleetDropdown
@onready var rename_fleet_popup = %RenameFleetPopup
@onready var design_grid = %Grid
@onready var ship_buttons = %ship_buttons
@onready var manager := PartManager.new()
@onready var ship_button = preload("res://fleet_button.tscn")
const UNSAVED_SHIP_ID = -1
const UNSAVED_SHIP_NAME = "Untitled"
const UNSAVED_FLEET_NAME = "*Unsaved"
const UNSAVED_FLEET_ID  = -1

#var fleet_manager := FleetManager.new()
var rename:String = "*Unsaved"
var ship_name = UNSAVED_SHIP_NAME
var current_ship_id = UNSAVED_SHIP_ID
var unsaved:bool = false
#@onready var fleet_folder = DirAccess.open("user://fleets")
var db:DB

var testStr = "ENT2,35.0,33.0,0
ENT2,35.0,35.0,0
HAS2,36.5,33.0,2
HAS2,36.5,35.0,2
HAF1,34.5,36.5,0
HAF1,35.5,36.5,0
HAF1,36.5,36.5,0"


"""

schizo notes
sortof a stateful things happening..

- NO_SHIP: ship id is -1

- SHIP: ship id is some real id

- NO_FLEET: fleet id is -1

- FLEET: fleet id is some real id


state transitions: 
	- clicking a ship button with an empty ship will turn into SHIP state

	- picking an existing fleet will turn into FLEET state

	- creating a new fleet will turn into NO_FLEET state
"""


func load_ship(stats:String):
	var lines = stats.trim_suffix(" ").split("\n")
	for csv_line in lines:
		var line = csv_line.split(",")
		if line.size() < 4:
			continue
		var part:PartData = manager.lookup_code(line[0])
		var partPosition = Vector2(float(line[1]),float(line[2]))
		var partRotation = int(line[3])
		var mirrored = (int(line[3]) > 3)
		var newPart = Part.new()
		newPart.set_data(part)
		grid.add_child(newPart)
		#need knowledge of 
		partPosition = partPosition- Vector2(Rect2i(Vector2(1,1),Vector2(64,64)).get_center() + Vector2i(1,1))
		partPosition = partPosition*32
		newPart.position =   partPosition
		newPart.rotation = snapped(newPart.rotation,PI/2) + partRotation*PI/2 
		#newPart.set_data(part)

func show_overlay()->void:
	overlay.show()

func hide_overlay()->void:
	overlay.hide()

func set_grid_size(size: Vector2)->void:
	grid.region_rect.size = PartData.PX_PER_GRID_SQUARE * size
	info_text.position.y = -0.5 * grid.region_rect.size.y - 200

func save_ship(ship:ShipData, ship_manager:ShipManager):
	var ship_stats = ship_manager.save_ship_string(ship)
	if current_ship_id != -1:
		db.update_ship_stats(current_ship_id,ship_stats)
		return
	var results = db.create_ship(ship_name, ship_stats)
	if results.size() > 0:
		current_ship_id = results[0]["id"]
		


func save_ship_img(ship:ShipData):
		var bounds_x = ship.get_ship_bounds_x()
		var bounds_y = ship.get_ship_bounds_y()
		var bounds = Vector2(bounds_x.x - bounds_x.y, bounds_y.x - bounds_y.y)
		var square_size = max(bounds.x, bounds.y)+1
		var padding = 64
		print(bounds_x)
		print(bounds_y)
		#var img = Image.load_from_file("user://ship.png").get_region(Rect2i(bounds_x.y*32 - 32 -padding/2 ,bounds_y.y*32 - 32 -padding/2, square_size*32 + 32 + padding, square_size*32 + 32 + padding))
		#img.save_png("user://ship2.png")
		#print(bounds)

func _input(event):
	if (event.is_action_pressed("save")):
		# Testing some shipbuilding
		print("saving...")
		part_grouping.clear_parts() # <-- This is VERY important
		var ship_manager := ShipManager.new()
		var ship := ShipData.assemble(Vector2i(64, 64), grid.get_children())
		save_ship(ship,ship_manager)
		save_ship_img(ship)

func setup_ship_buttons(ships):
	for ship in ships:
		var new_button = ship_button.instantiate()
		new_button.button_name = "Untitled "+str(ship["id"])
		new_button.method = load_ship.bind(ship["stats"])
		ship_buttons.add_child(new_button)

func _ready():
	set_grid_size(Vector2(64, 64))
	db = DB.new()
	manager.load_csv("user://parts.csv")
	var ships = db.get_ships_in_fleet(1)
	setup_ship_buttons(ships)
	PartButton.part_container = part_grouping
	for atlas_id in range(manager.count_parts()):
		var part := manager.lookup_id(atlas_id)
		var part_container := container.get_node(part.get_tab())
		var part_display := PartButton.new()
		part_display.part_data = part
		part_display.texture_normal = part.get_texture()
		part_display.set_display_size(part.get_size())
		if not part_container:
			push_warning("Tab '%s' does not exist" % part_container)
		else:
			part_container.add_child(part_display)

func selected_fleet(option):
	match option: 
		fleet_dropdown.NEW_FLEET_OPTION:
			unsaved = true

func on_valid_rename(new_rename):
	pass
	# if unsaved:
	# 	if(!fleet_manager.fleet_exists(new_rename)):
	# 		fleet = Fleet.new()
	# 		fleet.set_name(new_rename)
	# 		fleet_folder.make_dir(new_rename)
	# 		unsaved = false



			
