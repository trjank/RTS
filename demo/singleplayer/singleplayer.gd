class_name Singleplayer extends Battle

signal save_slot_changed(new_save_slot: int)

@export var tech_tree: TechTree

const MAP_PRESET_PATH := "res://map/presets/solar_system.json"
const SAVE_DIRECTORY := "user://singleplayer/"

var save_slot := -1:
	set = set_save_slot

static func get_save_slot_path(slot: int) -> String:
	return SAVE_DIRECTORY.path_join("battle_%d/" % slot)

static func get_save_slot_metadata(slot: int) -> Dictionary:
	var text := FileAccess.get_file_as_string(get_save_slot_path(slot) )
	var json = JSON.parse_string(text)
	return json if json is Dictionary else {}

func _ready() -> void:
	super()
	#
	map = Map.from_json(MAP_PRESET_PATH)
	chat_log.command_parser.add_command("save", save_files_and_print, {} )

func set_save_slot(new_save_slot: int) -> bool:
	if save_slot == new_save_slot:
		return true
	save_slot = new_save_slot
	folder_path = get_save_slot_path(new_save_slot)
	save_slot_changed.emit(new_save_slot)
	return load_json() and load_state()

func load_files_and_print() -> void:
	var error_flags := load_files()
	broadcast("Load status: %s" % TypeChecker.format_enum(error_flags, Battle.SaveError) )

func save_files_and_print() -> void:
	var error_flags := save_files()
	broadcast("Save status: %s" % TypeChecker.format_enum(error_flags, Battle.SaveError) )

func _on_tech_tree_button_pressed() -> void:
	tech_tree.visible = true
