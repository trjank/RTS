class_name TrainingGrounds extends Battle

const MAP_PRESET_PATH := "res://map/presets/black_hole.json"
const SHIP_DB := null

func _ready() -> void:
	super()
	#
	gamemode = Gamemode.SANDBOX
	map = Map.from_json(MAP_PRESET_PATH)
	#me.spawn_ship()
	create_team("Cannon Fodder")

func _on_main_state_changed(new_state: Main.State) -> void:
	if new_state != Main.State.TRAINING_GROUNDS:
		return stop()
	var error := start()
	assert(error == StartError.OK)
