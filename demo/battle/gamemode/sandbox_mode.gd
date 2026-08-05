class_name SandboxMode extends Gamemode

static var TESTERS := Team.new("Testers"):
	set(__): push_error("(SandboxMode) SandboxMode.TESTERS is immutable!")

func _init() -> void:
	name = "Sandbox"
	TESTERS.start_resources = StrategicResources.INFINITE
	teams = [TESTERS]

func get_spawnpoint(player: Player) -> Vector3:
	return player.mouse_position
