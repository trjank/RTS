extends Node2D

@export var overlay: CanvasLayer
@export var container: TabContainer
@export var part_grouping: PartGrouping
@export var mirror_mode_button: TextureButton
@export var mirror_axis: Line2D
@export var grid: Sprite2D

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
		var ship_manager := ShipManager.new()
		var ship := ShipData.create(64, 64)
		for part in grid.get_children():
			ship.add_part_node(part)
			print("->", part.rotation, " | ", part.scale.x < 0, " | ", part.get_class())
		ship_manager.save_ship_image(ship, "user://ship.png")
		ship_manager.save_ship_csv(ship, "user://ship.csv")
		print(ship.count_parts())
		print("IS CONNECTED: ", ship.is_connected())

func _ready():
	resize(Vector2i(64, 64))
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
