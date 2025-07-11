extends Node2D

@export var overlay: CanvasLayer
@export var container: TabContainer
@export var part_grouping: PartGrouping
@export var mirror_mode_button: TextureButton
@export var mirror_axis: Line2D
@export var grid: Sprite2D
@export var info_text: Label
var fleet:Fleet
@onready var fleet_dropdown = %FleetDropdown
@onready var rename_fleet_popup = %RenameFleetPopup
var fleet_manager := FleetManager.new()
var rename:String = "*default"
var unsaved:bool = false
@onready var fleet_folder = DirAccess.open("user://fleets")

#how im thinking the flow should be:
	#load some default fleet (defined in settings) (or load last worked on fleet)
	#fleets are just saved ship by ship

func show_overlay()->void:
	overlay.show()

func hide_overlay()->void:
	overlay.hide()

func resize(size: Vector2)->void:
	size *= PartData.PX_PER_GRID_SQUARE
	grid.region_rect.size   = size
	mirror_axis.position.x  = size.x * 0.5
	mirror_axis.points[1].y = size.y

func _input(event):
	if (event.is_action_pressed("save")):
		# Testing some shipbuilding
		print("saving...")
		part_grouping.clear_parts() # <-- This is VERY important
		#var ship_manager := ShipManager.new()
		var ship := ShipData.assemble(Vector2i(64, 64), grid.get_children())
		print(fleet.get_name())
		print(fleet.get_num_slots(Fleet.CAPITAL_SHIP))
		fleet.set_slot(Fleet.CAPITAL_SHIP,0, ship)

		fleet_manager.save_fleet_slot(fleet, Fleet.CAPITAL_SHIP,0)
		print("IS CONNECTED: ", ship.is_connected())
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




func _ready():
	resize(Vector2i(64, 64))
	var manager := PartManager.new()
	manager.load_csv("user://parts.csv")
	fleet_manager.set_fleet_folder()
	print(fleet_manager.fleet_exists("default"))
	fleet = Fleet.new()
	fleet.set_name("default")
	fleet_dropdown.item_selected.connect(selected_fleet)
	rename_fleet_popup.valid_rename.connect(on_valid_rename)
	#fleet.resize()
	#manager.new_atlas("res://test_atlas.png")
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
	if unsaved:
		if(!fleet_manager.fleet_exists(new_rename)):
			fleet = Fleet.new()
			fleet.set_name(new_rename)
			fleet_folder.make_dir(new_rename)
			unsaved = false



			
