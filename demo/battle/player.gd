class_name Player extends Node3D

const MIN_ALLOY := 0.0
const MAX_ALLOY := 100_000.0
const MIN_ENERGY := 0.0
const MAX_ENERGY := 100_000.0

var display_name: String
var color: Color
var alive := false:
	set = set_alive
var energy := 0.0:
	set = set_energy
var alloy := 0.0:
	set = set_alloy
var team: Team:
	set = set_team

func _init(init_display_name := "", init_color := Color.WHITE) -> void:
	display_name = init_display_name
	color = init_color

func _exit_tree() -> void:
	set_team(null)

func set_energy(new_energy: float) -> void:
	energy = clampf(new_energy, MIN_ENERGY, MAX_ENERGY)

func set_alloy(new_alloy: float) -> void:
	alloy = clampf(new_alloy, MIN_ALLOY, MAX_ALLOY)

func set_alive(is_alive: bool) -> void:
	alive = is_alive
	set_physics_process(is_alive)

func set_team(new_team: Team) -> void:
	if team != null:
		team.players.erase(self)
	if new_team != null:
		new_team.players.push_back(self)
	team = new_team

func spawn_ship(ship_data: ShipData, spawnpoint := Vector3.ZERO) -> Ship:
	var ship := Ship.create()
	add_child(ship)
	ship.data = ship_data
	ship.player_owner = self
	ship.position = spawnpoint
	ExplodeTest.explode(ship)
	return ship

func register_death(unit: Unit) -> void:
	if team != null:
		team.register_death(unit)
	# TODO: Additional penalties?

func register_kill(unit: Unit) -> void:
	if team != null:
		team.register_kill(unit)
	# TODO: Bounty system?

func reset_resources() -> void:
	energy = team.initial_energy
	alloy = team.initial_alloy

func _physics_process(dt: float) -> void:
	return
	assert(alive)
	#
	alloy += team.alloy_per_sec * dt
	energy += team.energy_per_sec * dt
