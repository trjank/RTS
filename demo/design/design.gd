extends Node2D

@export var overlay: CanvasLayer
@export var container: TabContainer
@export var part_grouping: PartGrouping
@export var grid: Sprite2D
@export var info_text: Label

func show_overlay()->void:
	overlay.show()

func hide_overlay()->void:
	overlay.hide()

func set_grid_size(size: Vector2)->void:
	grid.region_rect.size = PartData.PX_PER_GRID_SQUARE * size
	info_text.position.y = -0.5 * grid.region_rect.size.y - 200

func _input(event):
	if (event.is_action_pressed("save")):
		# Testing some shipbuilding
		print("saving...")
		part_grouping.clear_parts() # <-- This is VERY important
		var ship_manager := ShipManager.new()
		var ship := ShipData.assemble(Vector2i(64, 64), grid.get_children())
		ship_manager.save_ship_image(ship, "user://ship.png")
		ship_manager.save_ship_csv(ship, "user://ship.csv")
		print("IS CONNECTED: ", ship.is_connected())
		var bounds_x = ship.get_ship_bounds_x()
		var bounds_y = ship.get_ship_bounds_y()
		var bounds = Vector2(bounds_x.x - bounds_x.y, bounds_y.x - bounds_y.y)
		var square_size = max(bounds.x, bounds.y)+1
		var padding = 64
		print(bounds_x)
		print(bounds_y)
		
		var img = Image.load_from_file("user://ship.png").get_region(Rect2i(bounds_x.y*32 - 32 -padding/2 ,bounds_y.y*32 - 32 -padding/2, square_size*32 + 32 + padding, square_size*32 + 32 + padding))
		img.save_png("user://ship2.png")
		
		#print(bounds)

func _ready():
	set_grid_size(Vector2(64, 64))
	var manager := PartManager.new()
	manager.load_csv("user://parts.csv")
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
