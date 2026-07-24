class_name SandboxMode extends Gamemode

func _init() -> void:
	name = "Sandbox"
	teams = [Team.APHELIONS, Team.FEDERATION]

func get_spawnpoint(player: Player) -> Vector3:
	return player.mouse_position
