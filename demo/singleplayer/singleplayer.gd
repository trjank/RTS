class_name Singleplayer extends Battle

@export var tech_tree: TechTree

const MAP_PRESET_PATH := "res://map/presets/solar_system.json"

func _on_tech_tree_button_pressed() -> void:
	tech_tree.visible = true

func _ready() -> void:
	super()
	#
	map = Map.new()
	map.load_json(MAP_PRESET_PATH)
	start()
