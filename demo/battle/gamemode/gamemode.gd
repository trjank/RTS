class_name Gamemode extends RefCounted

const NO_SPAWNPOINT := Vector3.INF

static var STANDARD := StandardMode.new():
	set(__): push_error("Gamemode.STANDARD is immutable")
static var CAMPAIGN := CampaignMode.new():
	set(__): push_error("Gamemode.CAMPAIGN is immutable")
static var SANDBOX := SandboxMode.new():
	set(__): push_error("Gamemode.SANDBOX is immutable")
static var modes: Array[Gamemode] = [STANDARD, CAMPAIGN, SANDBOX]

var name := "Standard"
var teams: Array[Team] = []

func is_map_compatible(_map: Map) -> bool:
	return true

func is_ship_compatible(_ship: ShipData, _slot: int) -> bool:
	return true

func on_battle_start(_battle: Battle) -> void:
	pass # (Add any start functionality here)

func battle_tick(_battle: Battle, _dt: float) -> void:
	pass # (Add any frequent or timed events here)

func is_spawnpoint(target: Target) -> bool:
	return target != null

func get_map_spawnpoints(battle: Battle) -> Array[Spawnpoint]:
	return battle.get_map_data().get("spawnpoints", [] as Array[Spawnpoint] )

func get_spawnpoint(player: Player) -> Vector3:
	var spawnpoints := player.selection.filter(is_spawnpoint)
	var spawnpoint := spawnpoints.pick_random() as Target
	return spawnpoint.global_position if spawnpoint != null else NO_SPAWNPOINT
