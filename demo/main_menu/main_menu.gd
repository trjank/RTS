class_name MainMenu extends Battle

enum Submenu {
	NONE,
	SINGLEPLAYER,
	SETTINGS
}

@export var submenus: TabContainer

const MAP_PRESET_PATH := "res://map/presets/black_hole.json"

var submenu: Submenu:
	get = get_submenu,
	set = set_submenu

func get_submenu() -> Submenu:
	return submenus.current_tab as Submenu

func set_submenu(new_submenu: Submenu) -> void:
	submenus.current_tab = new_submenu

func _on_singleplayer_button_pressed() -> void:
	submenu = Submenu.SINGLEPLAYER

func _on_multiplayer_button_pressed() -> void:
	globals.main.state = Main.State.BATTLE

func _on_design_button_pressed() -> void:
	globals.main.state = Main.State.DESIGN

func _on_fleets_button_pressed() -> void:
	globals.main.state = Main.State.FLEET

func _on_settings_button_pressed() -> void:
	submenu = Submenu.SETTINGS

func _on_singleplayer_submenu_back_button_pressed() -> void:
	submenu = Submenu.NONE

func _on_settings_submenu_back_button_pressed() -> void:
	submenu = Submenu.NONE

func _ready() -> void:
	super()
	#
	map = Map.new()
	map.load_json(MAP_PRESET_PATH)
	start()
	print(_map_root.get_child(0).global_position)
