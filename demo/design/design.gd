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

func save_ship(size: Vector2i = grid.region_rect.size)->void:
	var ship_data := ShipData.create(size.x, size.y)
	part_grouping.clear_parts()
	for n in range(2, grid.get_child_count()):
		var part: Part = grid.get_child(n)
		var error := ship_data.add_part_node(part)
		print(error)
	print(ship_data.is_connected())

func _input(event):
	if event.is_action_pressed("save"):
		print("saving...")
		save_ship()

var ship_db := ShipDB.new()
func load_ship_db()->void:
	ship_db.load_db()
	print(ship_db.get_ship(1))

func _ready():
	load_ship_db()
	resize(Vector2i(64, 64))
	var manager := JSONPartManager.new()
	manager.load_json("user://part_data.json")
	#manager.new_atlas("res://test_atlas.png")
	PartButton.part_container = part_grouping
	for atlas_id in range(manager.count_parts()):
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
