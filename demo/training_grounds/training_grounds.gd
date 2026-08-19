class_name TrainingGrounds extends Battle

const MAP_PRESET_PATH := "res://map/presets/empty.json"
const SHIP_DB := null

func _ready() -> void:
	super()
	#
	gamemode = SandboxMode
	map = Map.from_json(MAP_PRESET_PATH)
	#me.spawn_ship(globals.client.fleet.)
	me.team = get_team("Testers")
	# TODO: Spawn a brick, a shielded brick, and a fast ship
	#var training_dummy := connect_player("Training Dummy")
	#training_dummy.spawn_ship()

func _on_main_state_changed(new_state: Main.State) -> void:
	if new_state != Main.State.TRAINING_GROUNDS:
		return stop()
	var error := start()
	assert(error != StartError.INCOMPATIBLE_MAP)
