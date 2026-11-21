class_name Gamemode extends Node

enum SpawnError {
	OK = 0,
	INVALID_PLAYER = 1 << 0,
	INVALID_TEAM = 1 << 1,
	INVALID_PLAYER_SPAWN = 1 << 2,
	MISSING_TEAM_SPAWNPOINTS = 1 << 3,
	NO_TEAMS = 1 << 4
}

const INVALID_SPAWNPOINT := Vector3.INF

static var modes: Array[Gamemode] = [StandardMode, CampaignMode, SandboxMode]

var display_name := "Standard"
var teams: Array[Team] = []

func is_map_compatible(_map: Map) -> bool:
	return true

func is_ship_compatible(_ship: ShipData, _slot: int) -> bool:
	return true

func is_dynamic_spawnpoint(target: Target) -> bool:
	return target != null

func is_valid_team(_team: String) -> bool:
	return true

func on_battle_start(_battle: Battle) -> void:
	pass

func setup_bot(bot: Player) -> void:
	bot.icon = preload("res://icons/cpu.png")

func battle_tick(_battle: Battle, _dt: float) -> void:
	pass # (Add any frequent or timed events here)

func spawn_player(_player: Player, position: Vector3) -> SpawnError:
	return SpawnError.OK if position.is_finite() else SpawnError.INVALID_PLAYER_SPAWN

func spawn_team(team: Team, spawnpoints: Array[Spawnpoint] ) -> int:
	if team == null:
		return SpawnError.INVALID_TEAM
	spawnpoints.sort_custom(Spawnpoint.priority_sorter)
	var error: int = SpawnError.OK
	#
	for i in team.count_players():
		error |= spawn_player(team.get_player(i), spawnpoints[i % spawnpoints.size() ].generate_spawn_position() )
	return error

func spawn_teams(battle: Battle) -> int:
	assert(battle != null)
	#
	var spawnpoints := Spawnpoint.get_team_spawnpoints(battle.map_data)
	var team_names := battle.get_alive_team_names()
	if team_names.is_empty():
		return SpawnError.NO_TEAMS
	if spawnpoints.size() < team_names.size():
		return SpawnError.MISSING_TEAM_SPAWNPOINTS
	var spawnpoint_team_names := PackedStringArray(spawnpoints.keys() )
	var error: int = SpawnError.OK
	# Sort to ensure spawnpoints match with the correct team if team names are the same
	team_names.sort()
	spawnpoint_team_names.sort()
	#
	for i in team_names.size():
		error |= spawn_team(battle.get_team(team_names[i] ), spawnpoints[spawnpoint_team_names[i] ] )
	return error

func get_dynamic_spawnpoint(player: Player) -> Vector3:
	# NOTE: We do not need the battle's RandomNumberGenerator since this is a client request
	var spawnpoints := player.selection.filter(is_dynamic_spawnpoint)
	var spawnpoint := spawnpoints.pick_random() as Target
	return spawnpoint.global_position if spawnpoint != null else INVALID_SPAWNPOINT
